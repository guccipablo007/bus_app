import { Transform } from 'class-transformer';
import { IsDateString, IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

export class SearchTripsDto {
  @IsString()
  @Transform(({ value }) => typeof value === 'string' ? value.trim() : value)
  @MinLength(2)
  @MaxLength(80)
  originCity: string;
  @IsString()
  @Transform(({ value }) => typeof value === 'string' ? value.trim() : value)
  @MinLength(2)
  @MaxLength(80)
  destinationCity: string;
  @IsOptional()
  @IsDateString({ strict: true })
  travelDate?: string;
}
