import type { ConfigService } from '@nestjs/config';

export function usePostgresRepositories(config: ConfigService): boolean {
  const environment = config.get<string>('NODE_ENV', 'development');
  return environment === 'staging' || environment === 'production';
}
