import { ConfigService } from '@nestjs/config';

import { HealthController } from './health.controller';
import type { DatabaseService } from '../database/database.service';

describe('HealthController', () => {
  it('returns deployment-safe local service status without a database call', async () => {
    const config = new ConfigService({ NODE_ENV: 'test' });
    const database = { ping: jest.fn() } as unknown as DatabaseService;
    const controller = new HealthController(config, database);

    await expect(controller.getHealth()).resolves.toEqual({
      status: 'ok',
      service: 'cameroon-bus-api',
      environment: 'test',
      database: 'not_connected',
    });
    expect(database.ping).not.toHaveBeenCalled();
  });

  it('reports hosted database reachability without connection details', async () => {
    const config = new ConfigService({ NODE_ENV: 'staging' });
    const database = { ping: jest.fn().mockResolvedValue(true) } as unknown as DatabaseService;
    const controller = new HealthController(config, database);

    await expect(controller.getHealth()).resolves.toEqual({
      status: 'ok',
      service: 'cameroon-bus-api',
      environment: 'staging',
      database: 'reachable',
    });
  });

  it('reports a degraded hosted service when the database cannot be reached', async () => {
    const config = new ConfigService({ NODE_ENV: 'production' });
    const database = { ping: jest.fn().mockRejectedValue(new Error('hidden')) } as unknown as DatabaseService;
    const controller = new HealthController(config, database);

    await expect(controller.getHealth()).resolves.toEqual({
      status: 'degraded',
      service: 'cameroon-bus-api',
      environment: 'production',
      database: 'unreachable',
    });
  });
});
