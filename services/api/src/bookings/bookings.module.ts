import { Module } from '@nestjs/common';

import { AuthModule } from '../auth/auth.module';
import { DataModule } from '../data/data.module';
import { BookingsController } from './bookings.controller';
import { BookingsService } from './bookings.service';

@Module({
  imports: [DataModule, AuthModule],
  controllers: [BookingsController],
  providers: [BookingsService],
  exports: [BookingsService],
})
export class BookingsModule {}
