import { Type } from 'class-transformer';
import { IsArray, IsEmail, IsOptional, IsString, MaxLength, MinLength, ValidateNested } from 'class-validator';

import { DocumentMetadataDto } from './document-metadata.dto';

export class CreateAgencyApplicationDto {
  @IsString() @MinLength(2) @MaxLength(160) companyName: string;
  @IsString() @MinLength(2) @MaxLength(160) ownerManagerName: string;
  @IsString() @MinLength(7) @MaxLength(32) phone: string;
  @IsEmail() @MaxLength(160) email: string;
  @IsString() @MinLength(2) @MaxLength(120) city: string;
  @IsOptional() @IsString() @MaxLength(120) businessRegistrationNumber?: string;
  @IsString() @MinLength(10) @MaxLength(1000) description: string;
  @IsOptional() @IsArray() @ValidateNested({ each: true }) @Type(() => DocumentMetadataDto)
  documents?: DocumentMetadataDto[];
}
