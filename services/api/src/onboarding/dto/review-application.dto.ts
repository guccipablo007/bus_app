import { IsIn, IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

export class ReviewApplicationDto {
  @IsIn(['approved', 'rejected'])
  decision: 'approved' | 'rejected';

  @IsOptional()
  @IsString()
  @MinLength(3)
  @MaxLength(500)
  rejectionReason?: string;
}
