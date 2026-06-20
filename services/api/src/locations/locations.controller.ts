import { Controller, Get, Query } from '@nestjs/common';

import { LocationsService } from './locations.service';

@Controller()
export class LocationsController {
  constructor(private readonly locations: LocationsService) {}
  @Get('regions')
  listRegions() { return this.locations.listRegions(); }
  @Get('cities')
  listCities(@Query('regionId') regionId?: string) { return this.locations.listCities(regionId); }
}
