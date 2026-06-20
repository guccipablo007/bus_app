import { randomBytes } from 'node:crypto';

type EnvironmentName = 'development' | 'test' | 'staging' | 'production';

const allowedEnvironments = new Set<EnvironmentName>([
  'development',
  'test',
  'staging',
  'production',
]);

function requiredString(
  config: Record<string, unknown>,
  key: string,
): string {
  const value = config[key];
  if (typeof value !== 'string' || value.trim() === '') {
    throw new Error(`${key} is required.`);
  }
  return value;
}

export function validateEnvironment(
  input: Record<string, unknown>,
): Record<string, unknown> {
  const config = { ...input };
  const rawEnvironment = String(config.NODE_ENV ?? 'development');

  if (!allowedEnvironments.has(rawEnvironment as EnvironmentName)) {
    throw new Error(`Unsupported NODE_ENV: ${rawEnvironment}`);
  }

  const environment = rawEnvironment as EnvironmentName;
  const requiresHostedSecrets =
    environment === 'staging' || environment === 'production';
  const port = Number(config.PORT ?? 3000);

  if (!Number.isInteger(port) || port < 1 || port > 65535) {
    throw new Error('PORT must be an integer between 1 and 65535.');
  }

  if (requiresHostedSecrets) {
    requiredString(config, 'DATABASE_URL');
    requiredString(config, 'JWT_ACCESS_SECRET');
    requiredString(config, 'JWT_REFRESH_SECRET');
    requiredString(config, 'ID_ENCRYPTION_KEY');
    requiredString(config, 'CORS_ORIGINS');
  } else {
    config.JWT_ACCESS_SECRET ??= randomBytes(32).toString('hex');
    config.JWT_REFRESH_SECRET ??= randomBytes(32).toString('hex');
    config.ID_ENCRYPTION_KEY ??= randomBytes(32).toString('hex');
  }

  config.NODE_ENV = environment;
  config.PORT = port;
  config.CORS_ORIGINS = String(config.CORS_ORIGINS ?? '');
  config.SUPABASE_DATABASE_NOTE = String(
    config.SUPABASE_DATABASE_NOTE ?? '',
  );

  return config;
}
