import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
interface NestErrorBody {
  error?: string;
  message?: string | string[];
}

@Catch()
export class ApiExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost): void {
    const response = host.switchToHttp().getResponse<{
      status(code: number): { json(body: unknown): void };
    }>();
    const request = host.switchToHttp().getRequest<{ originalUrl: string }>();
    const statusCode =
      exception instanceof HttpException
        ? exception.getStatus()
        : HttpStatus.INTERNAL_SERVER_ERROR;
    const raw =
      exception instanceof HttpException ? exception.getResponse() : undefined;
    const body: NestErrorBody =
      typeof raw === 'object' && raw !== null ? raw : {};
    const message =
      typeof raw === 'string'
        ? raw
        : body.message ??
          (statusCode === HttpStatus.INTERNAL_SERVER_ERROR
            ? 'Internal server error.'
            : 'Request failed.');

    response.status(statusCode).json({
      statusCode,
      error: body.error ?? HttpStatus[statusCode] ?? 'Error',
      message,
      path: request.originalUrl,
      timestamp: new Date().toISOString(),
    });
  }
}
