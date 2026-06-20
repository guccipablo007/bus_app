import { ConfigModule } from '@nestjs/config';
import { Test } from '@nestjs/testing';

import { DatabaseModule } from '../src/database/database.module';
import { DatabaseService } from '../src/database/database.service';
import { PostgresLocationRepository } from '../src/database/postgres-location.repository';
import { PostgresTripRepository } from '../src/database/postgres-trip.repository';

describe('PostgreSQL repository adapters (integration)', () => {
  let database: DatabaseService;
  let locations: PostgresLocationRepository;
  let trips: PostgresTripRepository;

  beforeAll(async () => {
    if (!process.env.DATABASE_URL) throw new Error('DATABASE_URL is required for integration tests.');
    const moduleRef = await Test.createTestingModule({
      imports: [ConfigModule.forRoot({ isGlobal: true }), DatabaseModule],
      providers: [PostgresLocationRepository, PostgresTripRepository],
    }).compile();
    database = moduleRef.get(DatabaseService);
    locations = moduleRef.get(PostgresLocationRepository);
    trips = moduleRef.get(PostgresTripRepository);
  });

  afterAll(async () => {
    await database?.onModuleDestroy();
  });

  it('connects and reads seeded locations', async () => {
    await expect(database.ping()).resolves.toBe(true);
    const regions = await locations.listRegions();
    const cities = await locations.listCities();
    expect(regions).toHaveLength(5);
    expect(cities).toHaveLength(8);
  });

  it('maps seeded future trips through the adapter', async () => {
    const cities = await locations.listCities();
    const buea = cities.find((city) => city.name === 'Buea');
    const bamenda = cities.find((city) => city.name === 'Bamenda');
    expect(buea).toBeDefined();
    expect(bamenda).toBeDefined();
    const results = await trips.searchTrips(buea!.id, bamenda!.id);
    expect(results.length).toBeGreaterThan(0);
    expect(results[0]).toMatchObject({ originCity: 'Buea', destinationCity: 'Bamenda' });
  });
});
