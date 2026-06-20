import type { ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';

import type { AuthenticatedUser } from './authenticated-user';
import { RolesGuard } from './roles.guard';

describe('RolesGuard', () => {
  const user: AuthenticatedUser = { id: 'user-1', fullName: 'Passenger', phone: null, email: 'p@example.com', roles: ['passenger'] };

  function context(currentUser?: AuthenticatedUser): ExecutionContext {
    return {
      switchToHttp: () => ({ getRequest: () => ({ user: currentUser }) }),
      getHandler: () => (() => undefined),
      getClass: () => class TestController {},
    } as unknown as ExecutionContext;
  }

  it('allows a matching backend role', () => {
    const reflector = { getAllAndOverride: () => ['passenger'] } as unknown as Reflector;
    expect(new RolesGuard(reflector).canActivate(context(user))).toBe(true);
  });

  it('rejects missing or non-matching roles', () => {
    const reflector = { getAllAndOverride: () => ['agency_admin'] } as unknown as Reflector;
    expect(new RolesGuard(reflector).canActivate(context(user))).toBe(false);
    expect(new RolesGuard(reflector).canActivate(context())).toBe(false);
  });
});
