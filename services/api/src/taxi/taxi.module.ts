import { Module } from '@nestjs/common';

import { AuthModule } from '../auth/auth.module';
import { BookingsModule } from '../bookings/bookings.module';
import { DataModule } from '../data/data.module';
import { TaxiController } from './taxi.controller';
import { TaxiFareService } from './taxi-fare.service';
import { TaxiService } from './taxi.service';

@Module({
  imports: [DataModule, AuthModule, BookingsModule],
  controllers: [TaxiController],
  providers: [TaxiFareService, TaxiService],
  exports: [TaxiFareService, TaxiService],
})
export class TaxiModule {}
