import { Module } from '@nestjs/common';

import { DataModule } from '../data/data.module';
import { LocationsController } from './locations.controller';
import { LocationsService } from './locations.service';

@Module({ imports: [DataModule], controllers: [LocationsController], providers: [LocationsService] })
export class LocationsModule {}
