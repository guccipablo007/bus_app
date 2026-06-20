import { randomUUID } from 'node:crypto';

import { Injectable, NotFoundException } from '@nestjs/common';

import type { AuthenticatedUser } from '../auth/authenticated-user';
import { BookingsService } from '../bookings/bookings.service';
import { BusinessRuleException } from '../common/http/business-rule.exception';
import { LocationRepository } from '../data/location.repository';
import { TaxiRepository } from '../data/taxi.repository';
import { TripRepository } from '../data/trip.repository';
import type { CreateTaxiRideDto } from './dto/create-taxi-ride.dto';
import { TaxiFareService } from './taxi-fare.service';

@Injectable()
export class TaxiService {
  static readonly distanceLimitMeters = 15000;

  constructor(
    private readonly trips: TripRepository,
    private readonly locations: LocationRepository,
    private readonly taxi: TaxiRepository,
    private readonly bookings: BookingsService,
    private readonly fares: TaxiFareService,
  ) {}

  async eligibleAreas(user: AuthenticatedUser, bookingId: string) {
    const booking = await this.bookings.getOwnedBooking(user, bookingId);
    if (booking.status !== 'paid' && booking.status !== 'confirmed') {
      throw new BusinessRuleException('Taxi add-on is only available after the bus booking is paid or confirmed.');
    }
    const trip = await this.trips.getTrip(booking.tripId);
    if (!trip) throw new NotFoundException('Trip not found.');
    const city = await this.locations.getCity(trip.destinationCityId);
    if (!city) throw new NotFoundException('Destination city not found.');
    const areas = (await this.taxi.listAreas(city.id, trip.arrivalTerminalId))
      .filter((area) => area.active && area.verifiedByAdmin && area.distanceMeters <= TaxiService.distanceLimitMeters)
      .map((area) => ({
        id: area.id,
        name: area.name,
        distanceMeters: area.distanceMeters,
        estimatedFareXaf: this.fares.calculate(area.distanceMeters),
      }));
    return {
      bookingId: booking.id,
      arrivalTerminal: { id: trip.arrivalTerminalId, name: `${city.name} Demo Terminal`, city: city.name },
      distanceLimitMeters: TaxiService.distanceLimitMeters,
      eligibleAreas: areas,
    };
  }

  async createRide(user: AuthenticatedUser, bookingId: string, dto: CreateTaxiRideDto) {
    const eligibility = await this.eligibleAreas(user, bookingId);
    const eligibleArea = eligibility.eligibleAreas.find((area) => area.id === dto.destinationAreaId);
    if (!eligibleArea) {
      throw new BusinessRuleException('Destination area is not eligible for this booking.');
    }
    return this.taxi.createTaxiRide({
      id: randomUUID(),
      bookingId,
      passengerId: user.id,
      pickupTerminalId: eligibility.arrivalTerminal.id,
      destinationAreaId: eligibleArea.id,
      destinationLandmark: dto.destinationLandmark.trim(),
      estimatedFareXaf: eligibleArea.estimatedFareXaf,
      status: 'requested',
    });
  }
}
