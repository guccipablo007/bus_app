import { BadRequestException, ConflictException, ForbiddenException } from '@nestjs/common';

import type { AuthenticatedUser } from '../auth/authenticated-user';
import { BusinessRuleException } from '../common/http/business-rule.exception';
import { InMemoryDomainRepository, DEMO_IDS } from '../data/in-memory-domain.repository';
import { TaxiFareService } from '../taxi/taxi-fare.service';
import { TaxiService } from '../taxi/taxi.service';
import { BookingsService } from './bookings.service';

describe('booking and taxi business rules', () => {
  let repository: InMemoryDomainRepository;
  let bookings: BookingsService;
  let taxi: TaxiService;
  const passenger: AuthenticatedUser = { id: 'passenger-1', fullName: 'Passenger One', phone: null, email: 'p1@example.com', roles: ['passenger'] };
  const otherPassenger: AuthenticatedUser = { ...passenger, id: 'passenger-2', email: 'p2@example.com' };

  beforeEach(() => {
    repository = new InMemoryDomainRepository();
    bookings = new BookingsService(repository, repository, repository);
    taxi = new TaxiService(repository, repository, repository, bookings, new TaxiFareService());
  });

  it('allows an authenticated passenger to create a pending booking', async () => {
    const booking = await bookings.create(passenger, { tripId: DEMO_IDS.tripBueaBamenda, seatNumber: 'S01' });
    expect(booking).toMatchObject({ passengerId: passenger.id, status: 'pending_payment', seatNumber: 'S01' });
  });

  it('prevents the same seat from being booked twice on one trip', async () => {
    await bookings.create(passenger, { tripId: DEMO_IDS.tripBueaBamenda, seatNumber: 'S01' });
    await expect(bookings.create(otherPassenger, { tripId: DEMO_IDS.tripBueaBamenda, seatNumber: 'S01' })).rejects.toBeInstanceOf(ConflictException);
  });

  it('enforces booking ownership', async () => {
    const booking = await bookings.create(passenger, { tripId: DEMO_IDS.tripBueaBamenda, seatNumber: 'S01' });
    await expect(bookings.getOwnedBooking(otherPassenger, booking.id)).rejects.toBeInstanceOf(ForbiddenException);
  });

  it('blocks taxi eligibility until payment', async () => {
    const booking = await bookings.create(passenger, { tripId: DEMO_IDS.tripBueaBamenda, seatNumber: 'S01' });
    await expect(taxi.eligibleAreas(passenger, booking.id)).rejects.toThrow('Taxi add-on is only available');
  });

  it('returns only active, verified, in-range areas in the destination city', async () => {
    const booking = await bookings.create(passenger, { tripId: DEMO_IDS.tripBueaBamenda, seatNumber: 'S01' });
    await bookings.confirmDemoPayment(passenger, booking.id);
    const result = await taxi.eligibleAreas(passenger, booking.id);
    expect(result.arrivalTerminal.city).toBe('Bamenda');
    expect(result.eligibleAreas.map((area) => area.id)).toEqual([DEMO_IDS.nkwen]);
    expect(result.eligibleAreas.some((area) => area.id === DEMO_IDS.akwa)).toBe(false);
  });

  it('keeps Douala bookings from seeing Bamenda areas', async () => {
    const booking = await bookings.create(passenger, { tripId: DEMO_IDS.tripBueaDouala, seatNumber: 'S01' });
    await bookings.confirmDemoPayment(passenger, booking.id);
    const result = await taxi.eligibleAreas(passenger, booking.id);
    expect(result.eligibleAreas.map((area) => area.id)).toEqual([DEMO_IDS.akwa]);
  });

  it('rejects a taxi destination that is not eligible for the booking', async () => {
    const booking = await bookings.create(passenger, { tripId: DEMO_IDS.tripBueaBamenda, seatNumber: 'S01' });
    await bookings.confirmDemoPayment(passenger, booking.id);
    await expect(taxi.createRide(passenger, booking.id, { destinationAreaId: DEMO_IDS.akwa, destinationLandmark: 'Near pharmacy' })).rejects.toBeInstanceOf(BusinessRuleException);
  });

  it('creates exactly one ticket when demo payment is repeated', async () => {
    const booking = await bookings.create(passenger, { tripId: DEMO_IDS.tripBueaBamenda, seatNumber: 'S01' });
    const first = await bookings.confirmDemoPayment(passenger, booking.id);
    const second = await bookings.confirmDemoPayment(passenger, booking.id);
    expect(second.ticket.id).toBe(first.ticket.id);
    expect(second.ticket.ticketCode).toBe(first.ticket.ticketCode);
    expect(repository.getTicketCount()).toBe(1);
  });

  it('allows only one concurrent booking for the same trip seat', async () => {
    const results = await Promise.allSettled([
      bookings.create(passenger, { tripId: DEMO_IDS.tripBueaBamenda, seatNumber: 'S02' }),
      bookings.create(otherPassenger, { tripId: DEMO_IDS.tripBueaBamenda, seatNumber: 'S02' }),
    ]);
    expect(results.filter((result) => result.status === 'fulfilled')).toHaveLength(1);
    expect(results.filter((result) => result.status === 'rejected')).toHaveLength(1);
    expect(repository.getSeatLockCount()).toBe(1);
  });

  it('rejects payment confirmation from an invalid status without creating a ticket', async () => {
    const booking = await bookings.create(passenger, { tripId: DEMO_IDS.tripBueaBamenda, seatNumber: 'S01' });
    await repository.updateBooking({ ...booking, status: 'confirmed' });
    await expect(bookings.confirmDemoPayment(passenger, booking.id)).rejects.toBeInstanceOf(BusinessRuleException);
    expect(repository.getTicketCount()).toBe(0);
  });
});

describe('TaxiFareService', () => {
  const fares = new TaxiFareService();
  it.each([[0, 1000], [3000, 1000], [3001, 1500], [7001, 2000], [10001, 3000], [15000, 3000]])('prices %i meters at %i XAF', (distance, expected) => {
    expect(fares.calculate(distance)).toBe(expected);
  });
  it('rejects destinations over 15 km', () => {
    expect(() => fares.calculate(15001)).toThrow(BadRequestException);
  });
});
