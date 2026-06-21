import { Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { usePostgresRepositories } from '../database/repository-mode';
import { AdminApplicationsController } from './admin-applications.controller';
import { InMemoryOnboardingRepository } from './in-memory-onboarding.repository';
import { OnboardingController } from './onboarding.controller';
import { OnboardingRepository } from './onboarding.repository';
import { OnboardingService } from './onboarding.service';
import { PostgresOnboardingRepository } from './postgres-onboarding.repository';

@Module({
  controllers: [OnboardingController, AdminApplicationsController],
  providers: [
    OnboardingService, JwtAuthGuard, RolesGuard,
    InMemoryOnboardingRepository, PostgresOnboardingRepository,
    {
      provide: OnboardingRepository,
      inject: [ConfigService, InMemoryOnboardingRepository, PostgresOnboardingRepository],
      useFactory: (config: ConfigService, memory: InMemoryOnboardingRepository, postgres: PostgresOnboardingRepository) =>
        usePostgresRepositories(config) ? postgres : memory,
    },
  ],
})
export class OnboardingModule {}
