import type { ExecutionContext } from '@nestjs/common';

import { AgencyScopeGuard } from './agency-scope.guard';
import type { AuthenticatedUser } from './authenticated-user';
import { DriverAssignmentGuard } from './driver-assignment.guard';

function context(request: object): ExecutionContext {
  return { switchToHttp: () => ({ getRequest: () => request }) } as unknown as ExecutionContext;
}

describe('scope guard structures', () => {
  const agencyUser: AuthenticatedUser = {
    id: 'agency-user', fullName: 'Agency User', phone: null, email: 'agency@example.com', roles: ['agency_staff'], agencyIds: ['agency-a'],
  };

  it('prevents agency staff from crossing agency scope', () => {
    const guard = new AgencyScopeGuard();
    expect(guard.canActivate(context({ user: agencyUser, params: { agencyId: 'agency-a' } }))).toBe(true);
    expect(() => guard.canActivate(context({ user: agencyUser, params: { agencyId: 'agency-b' } }))).toThrow("another agency's data");
  });

  it('prevents taxi drivers from accessing unassigned rides', () => {
    const guard = new DriverAssignmentGuard();
    const driver = { ...agencyUser, roles: ['taxi_driver'] as const, driverId: 'driver-a' } as AuthenticatedUser;
    expect(guard.canActivate(context({ user: driver, assignedDriverId: 'driver-a' }))).toBe(true);
    expect(() => guard.canActivate(context({ user: driver, assignedDriverId: 'driver-b' }))).toThrow('only access rides assigned');
  });
});
