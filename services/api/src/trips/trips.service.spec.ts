import { BadRequestException } from '@nestjs/common';

import { InMemoryDomainRepository, DEMO_IDS } from '../data/in-memory-domain.repository';
import { TripsService } from './trips.service';

describe('TripsService', () => {
  const repository = new InMemoryDomainRepository();
  const service = new TripsService(repository, repository);

  it('finds only trips for the requested route', async () => {
    const trips = await service.search({ originCity: 'Buea', destinationCity: 'Bamenda' });
    expect(trips).toHaveLength(1);
    expect(trips[0].destinationCityId).toBe(DEMO_IDS.bamenda);
    expect(trips[0]).toMatchObject({ destinationCity: 'Bamenda', busClass: 'standard', availableSeatCount: 4 });
  });

  it('rejects a route whose origin equals destination', async () => {
    await expect(service.search({ originCity: 'Buea', destinationCity: 'Buea' })).rejects.toBeInstanceOf(BadRequestException);
  });
});
