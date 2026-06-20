import { Injectable } from '@nestjs/common';

import type { City, Region } from '../data/domain.models';
import type { LocationRepository } from '../data/location.repository';
import { DatabaseService } from './database.service';

@Injectable()
export class PostgresLocationRepository implements LocationRepository {
  constructor(private readonly database: DatabaseService) {}

  async listRegions(): Promise<Region[]> {
    const result = await this.database.query<{ id: string; name: string }>(
      'SELECT id::text, name FROM regions WHERE active = true ORDER BY name',
    );
    return result.rows;
  }

  async listCities(regionId?: string): Promise<City[]> {
    const result = await this.database.query<{ id: string; region_id: string; name: string }>(
      `SELECT id::text, region_id::text, name FROM cities
       WHERE active = true AND ($1::uuid IS NULL OR region_id = $1::uuid)
       ORDER BY name`,
      [regionId ?? null],
    );
    return result.rows.map((row) => ({ id: row.id, regionId: row.region_id, name: row.name }));
  }

  async getCity(id: string): Promise<City | undefined> {
    const result = await this.database.query<{ id: string; region_id: string; name: string }>(
      'SELECT id::text, region_id::text, name FROM cities WHERE id = $1 AND active = true',
      [id],
    );
    const row = result.rows[0];
    return row ? { id: row.id, regionId: row.region_id, name: row.name } : undefined;
  }
}
