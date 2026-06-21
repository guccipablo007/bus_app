import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';

import { AuthModule } from './auth/auth.module';
import { BookingsModule } from './bookings/bookings.module';
import { validateEnvironment } from './config/environment';
import { DataModule } from './data/data.module';
import { DatabaseModule } from './database/database.module';
import { HealthController } from './health/health.controller';
import { LocationsModule } from './locations/locations.module';
import { OnboardingModule } from './onboarding/onboarding.module';
import { TaxiModule } from './taxi/taxi.module';
import { TripsModule } from './trips/trips.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      cache: true,
      validate: validateEnvironment,
    }),
    JwtModule.register({ global: true }),
    DatabaseModule,
    DataModule,
    AuthModule,
    LocationsModule,
    TripsModule,
    BookingsModule,
    TaxiModule,
    OnboardingModule,
  ],
  controllers: [HealthController],
})
export class AppModule {}
