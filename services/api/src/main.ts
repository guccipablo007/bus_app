import 'reflect-metadata';

import { NestFactory } from '@nestjs/core';
import { ConfigService } from '@nestjs/config';

import { AppModule } from './app.module';
import { configureApp } from './common/http/configure-app';

async function bootstrap(): Promise<void> {
  const app = await NestFactory.create(AppModule);
  const config = app.get(ConfigService);
  const origins = config
    .get<string>(
      'CORS_ORIGINS',
      'http://localhost:3000,http://localhost:5173',
    )
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean);

  configureApp(app);
  app.enableCors({
    origin: origins.includes('*') ? '*' : origins.length > 0 ? origins : false,
  });

  const port = Number(process.env.PORT || config.get<number>('PORT', 3000));
  await app.listen(port);
}

void bootstrap();
