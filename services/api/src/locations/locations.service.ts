import { Injectable } from '@nestjs/common';

import { LocationRepository } from '../data/location.repository';

@Injectable()
export class LocationsService {
  constructor(private readonly repository: LocationRepository) {}
  listRegions() { return this.repository.listRegions(); }
  listCities(regionId?: string) { return this.repository.listCities(regionId); }
}
