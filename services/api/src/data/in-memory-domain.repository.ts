import { ConflictException, Injectable } from '@nestjs/common';

import { BookingRepository } from './booking.repository';
import type { Booking, City, Region, ResidentialArea, TaxiRide, Ticket, Trip } from './domain.models';
import { LocationRepository } from './location.repository';
import { TaxiRepository } from './taxi.repository';
import { TicketRepository } from './ticket.repository';
import { TripRepository } from './trip.repository';

export const DEMO_IDS = {
  regionSouthWest: 'region-south-west',
  regionNorthWest: 'region-north-west',
  regionLittoral: 'region-littoral',
  buea: 'city-buea',
  bamenda: 'city-bamenda',
  douala: 'city-douala',
  tripBueaBamenda: 'trip-buea-bamenda',
  tripBueaDouala: 'trip-buea-douala',
  bamendaTerminal: 'terminal-bamenda',
  doualaTerminal: 'terminal-douala',
  nkwen: 'area-nkwen',
  akwa: 'area-akwa',
} as const;

@Injectable()
export class InMemoryDomainRepository implements LocationRepository, TripRepository, BookingRepository, TicketRepository, TaxiRepository {
  private readonly regions: Region[] = [
    { id: DEMO_IDS.regionSouthWest, name: 'South West' },
    { id: DEMO_IDS.regionNorthWest, name: 'North West' },
    { id: DEMO_IDS.regionLittoral, name: 'Littoral' },
    { id: 'region-west', name: 'West' },
    { id: 'region-centre', name: 'Centre' },
  ];
  private readonly cities: City[] = [
    { id: DEMO_IDS.buea, regionId: DEMO_IDS.regionSouthWest, name: 'Buea' },
    { id: DEMO_IDS.bamenda, regionId: DEMO_IDS.regionNorthWest, name: 'Bamenda' },
    { id: DEMO_IDS.douala, regionId: DEMO_IDS.regionLittoral, name: 'Douala' },
  ];
  private readonly trips: Trip[] = [
    this.demoTrip(DEMO_IDS.tripBueaBamenda, DEMO_IDS.bamenda, 'Bamenda', DEMO_IDS.bamendaTerminal, 7500, 6),
    this.demoTrip(DEMO_IDS.tripBueaDouala, DEMO_IDS.douala, 'Douala', DEMO_IDS.doualaTerminal, 5000, 4),
  ];
  private readonly areas: ResidentialArea[] = [
    { id: DEMO_IDS.nkwen, cityId: DEMO_IDS.bamenda, name: 'Nkwen', active: true, verifiedByAdmin: true, distanceMeters: 2400 },
    { id: 'area-bamenda-unverified', cityId: DEMO_IDS.bamenda, name: 'Unverified Area', active: true, verifiedByAdmin: false, distanceMeters: 2000 },
    { id: 'area-bamenda-inactive', cityId: DEMO_IDS.bamenda, name: 'Inactive Area', active: false, verifiedByAdmin: true, distanceMeters: 2000 },
    { id: 'area-bamenda-far', cityId: DEMO_IDS.bamenda, name: 'Far Area', active: true, verifiedByAdmin: true, distanceMeters: 16001 },
    { id: DEMO_IDS.akwa, cityId: DEMO_IDS.douala, name: 'Akwa', active: true, verifiedByAdmin: true, distanceMeters: 4200 },
  ];
  private readonly bookings = new Map<string, Booking>();
  private readonly seatLocks = new Set<string>();
  private readonly tickets = new Map<string, Ticket>();
  private readonly ticketCodes = new Set<string>();
  private readonly taxiRides = new Map<string, TaxiRide>();

  async listRegions(): Promise<Region[]> { return [...this.regions]; }
  async listCities(regionId?: string): Promise<City[]> { return this.cities.filter((city) => !regionId || city.regionId === regionId); }
  async getCity(id: string): Promise<City | undefined> { return this.cities.find((city) => city.id === id); }
  async searchTrips(originCityId: string, destinationCityId: string, travelDate?: string): Promise<Trip[]> {
    return this.trips.filter((trip) => {
      const routeMatches = trip.originCityId === originCityId && trip.destinationCityId === destinationCityId;
      return routeMatches && (!travelDate || trip.departureTime.startsWith(travelDate));
    });
  }
  async getTrip(id: string): Promise<Trip | undefined> { return this.trips.find((trip) => trip.id === id); }
  async createBooking(booking: Booking): Promise<Booking> {
    const lockKey = `${booking.tripId}:${booking.seatNumber}`;
    if (this.seatLocks.has(lockKey)) throw new ConflictException('That seat is no longer available for this trip.');
    this.seatLocks.add(lockKey);
    this.bookings.set(booking.id, booking);
    return booking;
  }
  async getBooking(id: string): Promise<Booking | undefined> { return this.bookings.get(id); }
  async updateBooking(booking: Booking): Promise<Booking> { this.bookings.set(booking.id, booking); return booking; }
  async getTicketByBooking(bookingId: string): Promise<Ticket | undefined> { return this.tickets.get(bookingId); }
  async createTicket(ticket: Ticket): Promise<Ticket> {
    const existing = this.tickets.get(ticket.bookingId);
    if (existing) return existing;
    if (this.ticketCodes.has(ticket.ticketCode)) throw new ConflictException('Ticket code already exists.');
    this.tickets.set(ticket.bookingId, ticket);
    this.ticketCodes.add(ticket.ticketCode);
    return ticket;
  }
  async listAreas(cityId: string, _terminalId?: string): Promise<ResidentialArea[]> { return this.areas.filter((area) => area.cityId === cityId); }
  async getArea(id: string): Promise<ResidentialArea | undefined> { return this.areas.find((area) => area.id === id); }
  async createTaxiRide(ride: TaxiRide): Promise<TaxiRide> { this.taxiRides.set(ride.id, ride); return ride; }

  getSeatLockCount(): number { return this.seatLocks.size; }
  getTicketCount(): number { return this.tickets.size; }

  private demoTrip(id: string, destinationCityId: string, destinationCity: string, arrivalTerminalId: string, fareXaf: number, durationHours: number): Trip {
    const departure = new Date();
    departure.setUTCDate(departure.getUTCDate() + 1);
    departure.setUTCHours(7, 0, 0, 0);
    const arrival = new Date(departure.getTime() + durationHours * 60 * 60 * 1000);
    const seats = ['S01', 'S02', 'S03', 'S04'];
    return {
      id,
      originCityId: DEMO_IDS.buea,
      destinationCityId,
      originCity: 'Buea',
      destinationCity,
      originTerminal: { id: 'terminal-buea', name: 'Buea Demo Terminal' },
      destinationTerminal: { id: arrivalTerminalId, name: `${destinationCity} Demo Terminal` },
      arrivalTerminalId,
      departureTime: departure.toISOString(),
      arrivalEstimate: arrival.toISOString(),
      agency: { id: 'agency-unity-express', name: 'Unity Express Demo' },
      busClass: 'standard',
      fareXaf,
      basePriceXaf: fareXaf,
      availableSeats: seats,
      availableSeatCount: seats.length,
    };
  }
}
