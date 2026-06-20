import { UnprocessableEntityException } from '@nestjs/common';

export class BusinessRuleException extends UnprocessableEntityException {
  constructor(message: string) {
    super(message);
  }
}
