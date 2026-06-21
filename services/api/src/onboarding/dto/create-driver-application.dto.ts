import { Type } from 'class-transformer';
import { IsArray, IsOptional, IsString, MaxLength, MinLength, ValidateNested } from 'class-validator';

import { DocumentMetadataDto } from './document-metadata.dto';

export class CreateDriverApplicationDto {
  @IsString() @MinLength(2) @MaxLength(160) driverName: string;
  @IsString() @MinLength(7) @MaxLength(32) phone: string;
  @IsString() @MinLength(2) @MaxLength(120) city: string;
  @IsOptional() @IsString() @MaxLength(32) vehiclePlate?: string;
  @IsOptional() @IsString() @MaxLength(1000) description?: string;
  @IsOptional() @IsArray() @ValidateNested({ each: true }) @Type(() => DocumentMetadataDto)
  documents?: DocumentMetadataDto[];
}
