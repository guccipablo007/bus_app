import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';

import type { AuthenticatedUser } from '../auth/authenticated-user';
import { CurrentUser } from '../auth/current-user.decorator';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/roles.decorator';
import { RolesGuard } from '../auth/roles.guard';
import { BookingsService } from './bookings.service';
import { CreateBookingDto } from './dto/create-booking.dto';

@Controller('bookings')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('passenger')
export class BookingsController {
  constructor(private readonly bookings: BookingsService) {}
  @Post()
  create(@CurrentUser() user: AuthenticatedUser, @Body() dto: CreateBookingDto) { return this.bookings.create(user, dto); }
  @Get(':bookingId')
  get(@CurrentUser() user: AuthenticatedUser, @Param('bookingId') bookingId: string) { return this.bookings.getOwnedBooking(user, bookingId); }
  @Post(':bookingId/confirm-demo-payment')
  confirmDemoPayment(@CurrentUser() user: AuthenticatedUser, @Param('bookingId') bookingId: string) {
    return this.bookings.confirmDemoPayment(user, bookingId);
  }
}
