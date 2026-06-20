import { Transform } from 'class-transformer';
import { IsString, MaxLength, MinLength } from 'class-validator';

export class LoginDto {
  @IsString()
  @Transform(({ value }) => typeof value === 'string' ? value.trim() : value)
  @MinLength(3)
  @MaxLength(160)
  identifier: string;

  @IsString()
  @MinLength(8)
  @MaxLength(128)
  password: string;
}
