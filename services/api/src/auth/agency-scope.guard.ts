import { type CanActivate, type ExecutionContext, ForbiddenException, Injectable } from '@nestjs/common';

import type { AuthenticatedUser } from './authenticated-user';

@Injectable()
export class AgencyScopeGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<{ user?: AuthenticatedUser; params: { agencyId?: string } }>();
    const agencyId = request.params.agencyId;
    if (request.user?.roles.includes('super_admin')) return true;
    if (agencyId && request.user?.agencyIds?.includes(agencyId)) return true;
    throw new ForbiddenException('You cannot access another agency\'s data.');
  }
}
