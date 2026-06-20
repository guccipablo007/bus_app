import { Transform } from 'class-transformer';
import { IsEmail, IsString, Matches, MaxLength, MinLength } from 'class-validator';

export class RegisterDto {
  @IsString()
  @Transform(({ value }) => typeof value === 'string' ? value.trim() : value)
  @MinLength(2)
  @MaxLength(120)
  fullName: string;

  @IsString()
  @Transform(({ value }) => typeof value === 'string' ? value.trim() : value)
  @Matches(/^\+?[0-9]{8,15}$/)
  phone: string;

  @IsEmail()
  @Transform(({ value }) => typeof value === 'string' ? value.trim().toLowerCase() : value)
  email: string;

  @IsString()
  @MinLength(8)
  @MaxLength(128)
  password: string;
}
