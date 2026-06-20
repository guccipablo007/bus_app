import { Module } from '@nestjs/common';

import { DataModule } from '../data/data.module';
import { TripsController } from './trips.controller';
import { TripsService } from './trips.service';

@Module({ imports: [DataModule], controllers: [TripsController], providers: [TripsService], exports: [TripsService] })
export class TripsModule {}
