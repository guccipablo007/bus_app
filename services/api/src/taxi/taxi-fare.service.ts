import { BadRequestException, Injectable } from '@nestjs/common';

@Injectable()
export class TaxiFareService {
  calculate(distanceMeters: number): number {
    if (distanceMeters < 0) throw new BadRequestException('Distance cannot be negative.');
    if (distanceMeters <= 3000) return 1000;
    if (distanceMeters <= 7000) return 1500;
    if (distanceMeters <= 10000) return 2000;
    if (distanceMeters <= 15000) return 3000;
    throw new BadRequestException('Destination is outside the 15 km taxi service area.');
  }
}
