import { Body, Controller, Get, Param, Patch, UseGuards } from '@nestjs/common';

import type { AuthenticatedUser } from '../auth/authenticated-user';
import { CurrentUser } from '../auth/current-user.decorator';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/roles.decorator';
import { RolesGuard } from '../auth/roles.guard';
import { ReviewApplicationDto } from './dto/review-application.dto';
import { OnboardingService } from './onboarding.service';

@Controller('admin/applications')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('super_admin')
export class AdminApplicationsController {
  constructor(private readonly onboarding: OnboardingService) {}

  @Get()
  list() {
    return this.onboarding.listAll();
  }

  @Patch(':id/review')
  review(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() dto: ReviewApplicationDto,
  ) {
    return this.onboarding.review(user, id, dto);
  }
}
