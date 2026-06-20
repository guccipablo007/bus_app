import { Controller, Get, Query } from '@nestjs/common';

import { SearchTripsDto } from './dto/search-trips.dto';
import { TripsService } from './trips.service';

@Controller('trips')
export class TripsController {
  constructor(private readonly trips: TripsService) {}
  @Get('search')
  search(@Query() query: SearchTripsDto) { return this.trips.search(query); }
}
