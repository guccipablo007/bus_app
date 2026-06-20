import { Injectable } from '@nestjs/common';

import type { ResidentialArea, TaxiRide } from '../data/domain.models';
import type { TaxiRepository } from '../data/taxi.repository';
import { DatabaseService } from './database.service';

interface AreaRow {
  id: string;
  city_id: string;
  name: string;
  active: boolean;
  verified_by_admin: boolean;
  distance_meters: number;
}

@Injectable()
export class PostgresTaxiRepository implements TaxiRepository {
  constructor(private readonly database: DatabaseService) {}

  async listAreas(cityId: string, terminalId?: string): Promise<ResidentialArea[]> {
    const result = await this.database.query<AreaRow>(
      `SELECT ra.id::text, ra.city_id::text, ra.name, ra.active,
              ra.verified_by_admin,
              COALESCE(tad.straight_line_meters, 2147483647)::integer AS distance_meters
       FROM residential_areas ra
       LEFT JOIN terminal_area_distances tad
         ON tad.residential_area_id = ra.id AND tad.terminal_id = $2::uuid
       WHERE ra.city_id = $1
       ORDER BY ra.name`,
      [cityId, terminalId ?? null],
    );
    return result.rows.map((row) => this.mapArea(row));
  }

  async getArea(id: string): Promise<ResidentialArea | undefined> {
    const result = await this.database.query<AreaRow>(
      `SELECT ra.id::text, ra.city_id::text, ra.name, ra.active,
              ra.verified_by_admin, 2147483647::integer AS distance_meters
       FROM residential_areas ra WHERE ra.id = $1`,
      [id],
    );
    return result.rows[0] ? this.mapArea(result.rows[0]) : undefined;
  }

  async createTaxiRide(ride: TaxiRide): Promise<TaxiRide> {
    await this.database.query(
      `INSERT INTO taxi_rides
         (id, agency_id, booking_id, passenger_id, pickup_terminal_id,
          destination_area_id, destination_landmark, estimated_fare_xaf, status)
       SELECT $1, r.agency_id, $2, $3, $4, $5, $6, $7, 'requested'
       FROM bookings b
       JOIN trip_instances ti ON ti.id = b.trip_instance_id
       JOIN routes r ON r.id = ti.route_id
       WHERE b.id = $2`,
      [ride.id, ride.bookingId, ride.passengerId, ride.pickupTerminalId,
        ride.destinationAreaId, ride.destinationLandmark, ride.estimatedFareXaf],
    );
    return ride;
  }

  private mapArea(row: AreaRow): ResidentialArea {
    return {
      id: row.id,
      cityId: row.city_id,
      name: row.name,
      active: row.active,
      verifiedByAdmin: row.verified_by_admin,
      distanceMeters: row.distance_meters,
    };
  }
}
