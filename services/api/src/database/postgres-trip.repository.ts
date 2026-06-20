import { Injectable } from '@nestjs/common';

import type { Trip } from '../data/domain.models';
import type { TripRepository } from '../data/trip.repository';
import { DatabaseService } from './database.service';

interface TripRow {
  id: string;
  origin_city_id: string;
  destination_city_id: string;
  origin_city: string;
  destination_city: string;
  origin_terminal_id: string;
  origin_terminal_name: string;
  destination_terminal_id: string;
  destination_terminal_name: string;
  departure_time: Date;
  expected_arrival_time: Date;
  agency_id: string;
  agency_name: string;
  fare_xaf: number;
  base_fare_xaf: number;
  available_seats: string[];
}

@Injectable()
export class PostgresTripRepository implements TripRepository {
  constructor(private readonly database: DatabaseService) {}

  async searchTrips(originCityId: string, destinationCityId: string, travelDate?: string): Promise<Trip[]> {
    const result = await this.database.query<TripRow>(
      `${this.selectSql()}
       WHERE oc.id = $1 AND dc.id = $2
         AND ti.status = 'scheduled'
         AND ($3::date IS NULL OR (ti.departure_time >= $3::date AND ti.departure_time < $3::date + interval '1 day'))
       GROUP BY ti.id, oc.id, dc.id, ot.id, dt.id, a.id, r.id
       ORDER BY ti.departure_time`,
      [originCityId, destinationCityId, travelDate ?? null],
    );
    return result.rows.map((row) => this.mapTrip(row));
  }

  async getTrip(id: string): Promise<Trip | undefined> {
    const result = await this.database.query<TripRow>(
      `${this.selectSql()}
       WHERE ti.id = $1
       GROUP BY ti.id, oc.id, dc.id, ot.id, dt.id, a.id, r.id`,
      [id],
    );
    const row = result.rows[0];
    return row ? this.mapTrip(row) : undefined;
  }

  private selectSql(): string {
    return `SELECT ti.id::text, oc.id::text AS origin_city_id,
                   dc.id::text AS destination_city_id, oc.name AS origin_city,
                   dc.name AS destination_city, ot.id::text AS origin_terminal_id,
                   ot.name AS origin_terminal_name, dt.id::text AS destination_terminal_id,
                   dt.name AS destination_terminal_name, ti.departure_time,
                   ti.expected_arrival_time, a.id::text AS agency_id,
                   a.display_name AS agency_name, ti.fare_xaf, r.base_fare_xaf,
                   COALESCE(array_agg(bs.seat_number ORDER BY bs.seat_number)
                     FILTER (WHERE bs.active = true AND
                       (tsl.id IS NULL OR (tsl.confirmed_at IS NULL AND tsl.expires_at <= now()))), '{}') AS available_seats
            FROM trip_instances ti
            JOIN routes r ON r.id = ti.route_id
            JOIN terminals ot ON ot.id = r.origin_terminal_id
            JOIN terminals dt ON dt.id = r.destination_terminal_id
            JOIN cities oc ON oc.id = ot.city_id
            JOIN cities dc ON dc.id = dt.city_id
            JOIN agencies a ON a.id = r.agency_id
            JOIN bus_seats bs ON bs.bus_id = ti.bus_id
            LEFT JOIN trip_seat_locks tsl ON tsl.trip_instance_id = ti.id AND tsl.seat_id = bs.id`;
  }

  private mapTrip(row: TripRow): Trip {
    return {
      id: row.id,
      originCityId: row.origin_city_id,
      destinationCityId: row.destination_city_id,
      originCity: row.origin_city,
      destinationCity: row.destination_city,
      originTerminal: { id: row.origin_terminal_id, name: row.origin_terminal_name },
      destinationTerminal: { id: row.destination_terminal_id, name: row.destination_terminal_name },
      arrivalTerminalId: row.destination_terminal_id,
      departureTime: row.departure_time.toISOString(),
      arrivalEstimate: row.expected_arrival_time.toISOString(),
      agency: { id: row.agency_id, name: row.agency_name },
      busClass: 'standard',
      fareXaf: row.fare_xaf,
      basePriceXaf: row.base_fare_xaf,
      availableSeats: row.available_seats,
      availableSeatCount: row.available_seats.length,
    };
  }
}
