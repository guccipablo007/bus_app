import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';

import { AuthService } from './auth.service';
import { InMemoryUserRepository } from './in-memory-user.repository';

describe('AuthService', () => {
  const config = new ConfigService({ JWT_ACCESS_SECRET: 'access-test-secret', JWT_REFRESH_SECRET: 'refresh-test-secret' });
  const jwt = new JwtService();
  const users = new InMemoryUserRepository();
  const service = new AuthService(users, users, jwt, config);

  it('registers a passenger and returns backend-provided roles', async () => {
    const result = await service.register({ fullName: 'Test Passenger', phone: '+237670000001', email: 'passenger@example.com', password: 'strong-pass-1' });
    expect(result.user.roles).toEqual(['passenger']);
    expect(result.accessToken).toBeTruthy();
    const payload = await jwt.verifyAsync(result.accessToken, { secret: 'access-test-secret' });
    expect(payload.roles).toEqual(['passenger']);
    expect(payload.kind).toBe('access');
  });

  it('logs in by email without returning a password hash', async () => {
    const result = await service.login({ identifier: 'passenger@example.com', password: 'strong-pass-1' });
    expect(result.user.email).toBe('passenger@example.com');
    expect(result.user).not.toHaveProperty('passwordHash');
  });
});
