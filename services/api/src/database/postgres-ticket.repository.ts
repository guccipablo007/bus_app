import { ConflictException, Injectable } from '@nestjs/common';

import type { Ticket } from '../data/domain.models';
import type { TicketRepository } from '../data/ticket.repository';
import { DatabaseService } from './database.service';
import { isPostgresError } from './postgres-error';

interface TicketRow {
  id: string;
  booking_id: string;
  qr_value: string;
  issued_at: Date;
}

@Injectable()
export class PostgresTicketRepository implements TicketRepository {
  constructor(private readonly database: DatabaseService) {}

  async getTicketByBooking(bookingId: string): Promise<Ticket | undefined> {
    const result = await this.database.query<TicketRow>(
      `SELECT id::text, booking_id::text, qr_value, issued_at
       FROM tickets WHERE booking_id = $1 ORDER BY issued_at LIMIT 1`,
      [bookingId],
    );
    return result.rows[0] ? this.mapTicket(result.rows[0]) : undefined;
  }

  async createTicket(ticket: Ticket): Promise<Ticket> {
    try {
      const result = await this.database.query<TicketRow>(
        `INSERT INTO tickets (id, booking_id, booking_passenger_id, qr_value)
         SELECT $1, bp.booking_id, bp.id, $3
         FROM booking_passengers bp
         WHERE bp.booking_id = $2
         ORDER BY bp.created_at
         LIMIT 1
         ON CONFLICT (booking_passenger_id) DO NOTHING
         RETURNING id::text, booking_id::text, qr_value, issued_at`,
        [ticket.id, ticket.bookingId, ticket.ticketCode],
      );
      if (result.rows[0]) return this.mapTicket(result.rows[0]);
      const existing = await this.getTicketByBooking(ticket.bookingId);
      if (existing) return existing;
      throw new ConflictException('Ticket could not be created.');
    } catch (error) {
      if (isPostgresError(error, '23505')) throw new ConflictException('Ticket code already exists.');
      throw error;
    }
  }

  private mapTicket(row: TicketRow): Ticket {
    return { id: row.id, bookingId: row.booking_id, ticketCode: row.qr_value, createdAt: row.issued_at.toISOString() };
  }
}
