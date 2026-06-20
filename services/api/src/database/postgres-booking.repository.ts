import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import type { PoolClient } from 'pg';

import type { Booking, BookingStatus } from '../data/domain.models';
import type { BookingRepository } from '../data/booking.repository';
import { DatabaseService } from './database.service';
import { isPostgresError } from './postgres-error';

interface BookingRow {
  id: string;
  passenger_id: string;
  trip_instance_id: string;
  status: BookingStatus;
  seat_number: string;
  ticket_id: string | null;
}

@Injectable()
export class PostgresBookingRepository implements BookingRepository {
  constructor(private readonly database: DatabaseService) {}

  async createBooking(booking: Booking): Promise<Booking> {
    try {
      return await this.database.transaction(async (client) => {
        const selection = await client.query<{ seat_id: string; fare_xaf: number }>(
          `SELECT bs.id::text AS seat_id, ti.fare_xaf
           FROM trip_instances ti
           JOIN bus_seats bs ON bs.bus_id = ti.bus_id AND bs.seat_number = $2 AND bs.active = true
           WHERE ti.id = $1
           FOR SHARE OF ti, bs`,
          [booking.tripId, booking.seatNumber],
        );
        const selected = selection.rows[0];
        if (!selected) throw new NotFoundException('Trip seat not found.');

        await client.query(
          `DELETE FROM trip_seat_locks
           WHERE trip_instance_id = $1 AND seat_id = $2
             AND confirmed_at IS NULL AND expires_at <= now()`,
          [booking.tripId, selected.seat_id],
        );

        await client.query(
          `INSERT INTO bookings
             (id, booking_reference, passenger_id, trip_instance_id, status, total_amount_xaf, expires_at)
           VALUES ($1, $2, $3, $4, $5, $6, now() + interval '15 minutes')`,
          [booking.id, this.bookingReference(booking.id), booking.passengerId, booking.tripId, booking.status, selected.fare_xaf],
        );
        const passenger = await client.query<{ id: string }>(
          `INSERT INTO booking_passengers (booking_id, passenger_user_id, full_name, phone)
           SELECT $1, u.id, u.full_name, u.phone FROM users u WHERE u.id = $2
           RETURNING id::text`,
          [booking.id, booking.passengerId],
        );
        if (!passenger.rows[0]) throw new NotFoundException('Passenger not found.');
        await client.query(
          `INSERT INTO trip_seat_locks
             (trip_instance_id, seat_id, booking_id, booking_passenger_id, locked_by_user_id, expires_at)
           VALUES ($1, $2, $3, $4, $5, now() + interval '15 minutes')`,
          [booking.tripId, selected.seat_id, booking.id, passenger.rows[0].id, booking.passengerId],
        );
        return booking;
      });
    } catch (error) {
      if (isPostgresError(error, '23505')) {
        throw new ConflictException('That seat is no longer available for this trip.');
      }
      throw error;
    }
  }

  async getBooking(id: string): Promise<Booking | undefined> {
    const result = await this.database.query<BookingRow>(this.selectSql(), [id]);
    return result.rows[0] ? this.mapBooking(result.rows[0]) : undefined;
  }

  async updateBooking(booking: Booking): Promise<Booking> {
    await this.database.query(
      'UPDATE bookings SET status = $2 WHERE id = $1',
      [booking.id, booking.status],
    );
    const updated = await this.getBooking(booking.id);
    if (!updated) throw new NotFoundException('Booking not found.');
    return updated;
  }

  private selectSql(): string {
    return `SELECT b.id::text, b.passenger_id::text, b.trip_instance_id::text,
                   b.status, bs.seat_number, t.id::text AS ticket_id
            FROM bookings b
            JOIN trip_seat_locks tsl ON tsl.booking_id = b.id
            JOIN bus_seats bs ON bs.id = tsl.seat_id
            LEFT JOIN tickets t ON t.booking_id = b.id
            WHERE b.id = $1
            LIMIT 1`;
  }

  private mapBooking(row: BookingRow): Booking {
    return {
      id: row.id,
      passengerId: row.passenger_id,
      tripId: row.trip_instance_id,
      seatNumber: row.seat_number,
      status: row.status,
      ticketId: row.ticket_id ?? undefined,
    };
  }

  private bookingReference(id: string): string {
    return `CB-${id.replaceAll('-', '').slice(0, 16).toUpperCase()}`;
  }
}
