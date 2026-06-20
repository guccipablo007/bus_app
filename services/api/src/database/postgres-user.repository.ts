import { ConflictException, Injectable } from '@nestjs/common';

import type { AuthRepository } from '../auth/auth.repository';
import type { AppRole } from '../auth/app-role';
import type { StoredUser, UserRepository } from '../auth/user.repository';
import { DatabaseService } from './database.service';
import { isPostgresError } from './postgres-error';

interface UserRow {
  id: string;
  full_name: string;
  phone: string | null;
  email: string | null;
  password_hash: string | null;
  roles: AppRole[];
  agency_ids: string[];
  driver_id: string | null;
}

@Injectable()
export class PostgresUserRepository implements UserRepository, AuthRepository {
  constructor(private readonly database: DatabaseService) {}

  async create(user: StoredUser): Promise<StoredUser> {
    try {
      await this.database.transaction(async (client) => {
        await client.query(
          `INSERT INTO users (id, full_name, phone, email, password_hash, status)
           VALUES ($1, $2, $3, $4, $5, 'active')`,
          [user.id, user.fullName, user.phone, user.email, user.passwordHash],
        );
        await client.query(
          `INSERT INTO user_roles (user_id, role_id)
           SELECT $1, id FROM roles WHERE code = ANY($2::text[])
           ON CONFLICT (user_id, role_id) DO NOTHING`,
          [user.id, user.roles],
        );
        if (user.roles.includes('passenger')) {
          await client.query(
            'INSERT INTO passenger_profiles (user_id) VALUES ($1) ON CONFLICT (user_id) DO NOTHING',
            [user.id],
          );
        }
      });
      return user;
    } catch (error) {
      if (isPostgresError(error, '23505')) {
        throw new ConflictException('A user with that email or phone already exists.');
      }
      throw error;
    }
  }

  async findByIdentifier(identifier: string): Promise<StoredUser | undefined> {
    const result = await this.database.query<UserRow>(
      `SELECT u.id, u.full_name, u.phone, u.email, u.password_hash,
              COALESCE(array_agg(DISTINCT r.code) FILTER (WHERE r.code IS NOT NULL), '{}') AS roles,
              COALESCE(array_agg(DISTINCT ast.agency_id::text) FILTER (WHERE ast.agency_id IS NOT NULL), '{}') AS agency_ids,
              min(td.id::text) AS driver_id
       FROM users u
       LEFT JOIN user_roles ur ON ur.user_id = u.id AND ur.revoked_at IS NULL
       LEFT JOIN roles r ON r.id = ur.role_id
       LEFT JOIN agency_staff ast ON ast.user_id = u.id AND ast.active = true
       LEFT JOIN taxi_drivers td ON td.user_id = u.id
       WHERE (lower(u.email) = lower($1) OR u.phone = $1) AND u.status = 'active'
       GROUP BY u.id`,
      [identifier.trim()],
    );
    const row = result.rows[0];
    if (!row || !row.password_hash || !row.email) return undefined;
    return {
      id: row.id,
      fullName: row.full_name,
      phone: row.phone ?? '',
      email: row.email,
      passwordHash: row.password_hash,
      roles: row.roles,
      agencyIds: row.agency_ids,
      driverId: row.driver_id ?? undefined,
    };
  }
}
