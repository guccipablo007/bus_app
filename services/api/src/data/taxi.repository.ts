import type { ResidentialArea, TaxiRide } from './domain.models';

export abstract class TaxiRepository {
  abstract listAreas(cityId: string, terminalId?: string): Promise<ResidentialArea[]>;
  abstract getArea(id: string): Promise<ResidentialArea | undefined>;
  abstract createTaxiRide(ride: TaxiRide): Promise<TaxiRide>;
}
