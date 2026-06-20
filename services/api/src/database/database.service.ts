import { Injectable, OnModuleDestroy } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Pool, type PoolClient, type QueryResult, type QueryResultRow } from 'pg';

import { normalizePgConnectionString } from './pg-connection';

@Injectable()
export class DatabaseService implements OnModuleDestroy {
  private pool?: Pool;

  constructor(private readonly config: ConfigService) {}

  query<T extends QueryResultRow>(text: string, values: unknown[] = []): Promise<QueryResult<T>> {
    return this.getPool().query<T>(text, values);
  }

  async transaction<T>(work: (client: PoolClient) => Promise<T>): Promise<T> {
    const client = await this.getPool().connect();
    try {
      await client.query('BEGIN');
      const result = await work(client);
      await client.query('COMMIT');
      return result;
    } catch (error) {
      await client.query('ROLLBACK').catch(() => undefined);
      throw error;
    } finally {
      client.release();
    }
  }

  async ping(): Promise<boolean> {
    const result = await this.query<{ ok: number }>('SELECT 1::integer AS ok');
    return result.rows[0]?.ok === 1;
  }

  async onModuleDestroy(): Promise<void> {
    await this.pool?.end();
  }

  private getPool(): Pool {
    if (!this.pool) {
      const connectionString = this.config.get<string>('DATABASE_URL');
      if (!connectionString) throw new Error('DATABASE_URL is not configured.');
      this.pool = new Pool({
        connectionString: normalizePgConnectionString(connectionString),
        connectionTimeoutMillis: 15000,
        max: 10,
      });
    }
    return this.pool;
  }
}
