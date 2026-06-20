import { validateEnvironment } from './environment';

describe('validateEnvironment', () => {
  it('allows tests without a database URL and creates runtime-only secrets', () => {
    const config = validateEnvironment({ NODE_ENV: 'test', PORT: '3001' });
    expect(config.DATABASE_URL).toBeUndefined();
    expect(config.JWT_ACCESS_SECRET).toEqual(expect.any(String));
    expect(config.PORT).toBe(3001);
  });

  it('fails closed when staging secrets are missing', () => {
    expect(() => validateEnvironment({ NODE_ENV: 'staging' })).toThrow('DATABASE_URL is required');
  });
});
