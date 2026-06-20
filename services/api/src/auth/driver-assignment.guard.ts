import { type CanActivate, type ExecutionContext, ForbiddenException, Injectable } from '@nestjs/common';

import type { AuthenticatedUser } from './authenticated-user';

@Injectable()
export class DriverAssignmentGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<{ user?: AuthenticatedUser; assignedDriverId?: string }>();
    if (request.user?.roles.includes('super_admin')) return true;
    if (request.user?.driverId && request.user.driverId === request.assignedDriverId) return true;
    throw new ForbiddenException('Taxi drivers can only access rides assigned to them.');
  }
}
