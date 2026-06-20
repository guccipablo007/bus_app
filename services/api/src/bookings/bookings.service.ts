import { randomUUID } from 'node:crypto';

import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';

import type { AuthenticatedUser } from '../auth/authenticated-user';
import { BusinessRuleException } from '../common/http/business-rule.exception';
import { BookingRepository } from '../data/booking.repository';
import type { Booking } from '../data/domain.models';
import { TicketRepository } from '../data/ticket.repository';
import { TripRepository } from '../data/trip.repository';
import type { CreateBookingDto } from './dto/create-booking.dto';

@Injectable()
export class BookingsService {
  constructor(
    private readonly trips: TripRepository,
    private readonly bookings: BookingRepository,
    private readonly tickets: TicketRepository,
  ) {}

  async create(user: AuthenticatedUser, dto: CreateBookingDto): Promise<Booking> {
    const trip = await this.trips.getTrip(dto.tripId);
    if (!trip) throw new NotFoundException('Trip not found.');
    if (!trip.availableSeats.includes(dto.seatNumber)) {
      throw new BusinessRuleException('Seat number is not valid for this trip.');
    }
    return this.bookings.createBooking({
      id: randomUUID(),
      passengerId: user.id,
      tripId: trip.id,
      seatNumber: dto.seatNumber,
      status: 'pending_payment',
    });
  }

  async getOwnedBooking(user: AuthenticatedUser, bookingId: string): Promise<Booking> {
    const booking = await this.bookings.getBooking(bookingId);
    if (!booking) throw new NotFoundException('Booking not found.');
    if (booking.passengerId !== user.id) throw new ForbiddenException('You cannot access this booking.');
    return booking;
  }

  async confirmDemoPayment(user: AuthenticatedUser, bookingId: string) {
    const booking = await this.getOwnedBooking(user, bookingId);
    const existingTicket = await this.tickets.getTicketByBooking(booking.id);
    if (existingTicket) return { booking, ticket: existingTicket };

    if (booking.status !== 'pending_payment' && booking.status !== 'paid') {
      throw new BusinessRuleException('Only a pending-payment booking can be confirmed.');
    }

    const paidBooking = booking.status === 'paid'
      ? booking
      : await this.bookings.updateBooking({ ...booking, status: 'paid' });
    const ticket = await this.tickets.createTicket({
      id: randomUUID(),
      bookingId: booking.id,
      ticketCode: `CB-${randomUUID().replaceAll('-', '').slice(0, 12).toUpperCase()}`,
      createdAt: new Date().toISOString(),
    });
    const bookingWithTicket = await this.bookings.updateBooking({ ...paidBooking, ticketId: ticket.id });
    return { booking: bookingWithTicket, ticket };
  }
}
