import { Body, Controller, Get, Post, UseGuards } from '@nestjs/common';

import type { AuthenticatedUser } from '../auth/authenticated-user';
import { CurrentUser } from '../auth/current-user.decorator';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/roles.decorator';
import { RolesGuard } from '../auth/roles.guard';
import { CreateAgencyApplicationDto } from './dto/create-agency-application.dto';
import { CreateDriverApplicationDto } from './dto/create-driver-application.dto';
import { OnboardingService } from './onboarding.service';

@Controller('onboarding')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('passenger')
export class OnboardingController {
  constructor(private readonly onboarding: OnboardingService) {}

  @Post('agency-applications')
  createAgency(@CurrentUser() user: AuthenticatedUser, @Body() dto: CreateAgencyApplicationDto) {
    return this.onboarding.createAgency(user, dto);
  }

  @Post('driver-applications')
  createDriver(@CurrentUser() user: AuthenticatedUser, @Body() dto: CreateDriverApplicationDto) {
    return this.onboarding.createDriver(user, dto);
  }

  @Get('my-applications')
  listMine(@CurrentUser() user: AuthenticatedUser) {
    return this.onboarding.listMine(user);
  }
}
