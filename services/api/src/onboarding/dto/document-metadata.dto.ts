import { IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

export class DocumentMetadataDto {
  @IsString()
  @MinLength(2)
  @MaxLength(80)
  documentType: string;

  @IsString()
  @MinLength(1)
  @MaxLength(180)
  originalFilename: string;

  @IsOptional()
  @IsString()
  @MaxLength(240)
  placeholderPath?: string;
}
