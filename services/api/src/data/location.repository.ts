import type { City, Region } from './domain.models';

export abstract class LocationRepository {
  abstract listRegions(): Promise<Region[]>;
  abstract listCities(regionId?: string): Promise<City[]>;
  abstract getCity(id: string): Promise<City | undefined>;
}
