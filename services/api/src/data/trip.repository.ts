import type { Trip } from './domain.models';

export abstract class TripRepository {
  abstract searchTrips(originCityId: string, destinationCityId: string, travelDate?: string): Promise<Trip[]>;
  abstract getTrip(id: string): Promise<Trip | undefined>;
}
