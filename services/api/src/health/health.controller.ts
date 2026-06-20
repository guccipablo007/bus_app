import { Controller, Get } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

import { DatabaseService } from '../database/database.service';

export interface HealthResponse {
  status: 'ok' | 'degraded';
  service: 'cameroon-bus-api';
  environment: string;
  database: 'not_connected' | 'reachable' | 'unreachable';
}

@Controller('health')
export class HealthController {
  constructor(
    private readonly config: ConfigService,
    private readonly database: DatabaseService,
  ) {}

  @Get()
  async getHealth(): Promise<HealthResponse> {
    const environment = this.config.get<string>('NODE_ENV', 'development');
    let databaseStatus: HealthResponse['database'] = 'not_connected';

    if (environment === 'staging' || environment === 'production') {
      try {
        databaseStatus = (await this.database.ping()) ? 'reachable' : 'unreachable';
      } catch {
        databaseStatus = 'unreachable';
      }
    }

    return {
      status: databaseStatus === 'unreachable' ? 'degraded' : 'ok',
      service: 'cameroon-bus-api',
      environment,
      database: databaseStatus,
    };
  }
}
