import { BadRequestException, Injectable } from '@nestjs/common';

import { LocationRepository } from '../data/location.repository';
import { TripRepository } from '../data/trip.repository';
import type { SearchTripsDto } from './dto/search-trips.dto';

@Injectable()
export class TripsService {
  constructor(
    private readonly trips: TripRepository,
    private readonly locations: LocationRepository,
  ) {}
  async search(query: SearchTripsDto) {
    if (query.originCity.trim().toLowerCase() === query.destinationCity.trim().toLowerCase()) {
      throw new BadRequestException('Origin and destination cities must be different.');
    }
    const cities = await this.locations.listCities();
    const resolveCity = (value: string) => cities.find(
      (city) => city.id === value || city.name.toLowerCase() === value.trim().toLowerCase(),
    );
    const origin = resolveCity(query.originCity);
    const destination = resolveCity(query.destinationCity);
    if (!origin || !destination) return [];
    return this.trips.searchTrips(origin.id, destination.id, query.travelDate);
  }
}
