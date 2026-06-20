import type { Ticket } from './domain.models';

export abstract class TicketRepository {
  abstract getTicketByBooking(bookingId: string): Promise<Ticket | undefined>;
  abstract createTicket(ticket: Ticket): Promise<Ticket>;
}
