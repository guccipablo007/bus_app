import { Transform } from 'class-transformer';
import { IsString, Matches, MaxLength, MinLength } from 'class-validator';

export class CreateBookingDto {
  @IsString()
  @Transform(({ value }) => typeof value === 'string' ? value.trim() : value)
  @MinLength(3)
  @MaxLength(100)
  tripId: string;
  @IsString()
  @Transform(({ value }) => typeof value === 'string' ? value.trim().toUpperCase() : value)
  @Matches(/^[0-9]{1,3}[A-Z]$/)
  seatNumber: string;
}
