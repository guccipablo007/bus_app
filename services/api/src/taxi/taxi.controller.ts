import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';

import type { AuthenticatedUser } from '../auth/authenticated-user';
import { CurrentUser } from '../auth/current-user.decorator';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/roles.decorator';
import { RolesGuard } from '../auth/roles.guard';
import { CreateTaxiRideDto } from './dto/create-taxi-ride.dto';
import { TaxiService } from './taxi.service';

@Controller('bookings/:bookingId')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('passenger')
export class TaxiController {
  constructor(private readonly taxi: TaxiService) {}
  @Get('eligible-taxi-areas')
  eligible(@CurrentUser() user: AuthenticatedUser, @Param('bookingId') bookingId: string) {
    return this.taxi.eligibleAreas(user, bookingId);
  }
  @Post('taxi-rides')
  create(@CurrentUser() user: AuthenticatedUser, @Param('bookingId') bookingId: string, @Body() dto: CreateTaxiRideDto) {
    return this.taxi.createRide(user, bookingId, dto);
  }
}
