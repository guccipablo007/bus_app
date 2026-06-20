import type { Booking } from './domain.models';

export abstract class BookingRepository {
  abstract createBooking(booking: Booking): Promise<Booking>;
  abstract getBooking(id: string): Promise<Booking | undefined>;
  abstract updateBooking(booking: Booking): Promise<Booking>;
}
