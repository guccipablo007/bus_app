import {
  type CanActivate,
  type ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';

import type {
  AccessTokenPayload,
  AuthenticatedUser,
} from './authenticated-user';

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(
    private readonly jwtService: JwtService,
    private readonly config: ConfigService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<{
      headers: { authorization?: string };
      user?: AuthenticatedUser;
    }>();
    const [scheme, token] = request.headers.authorization?.split(' ') ?? [];

    if (scheme !== 'Bearer' || !token) {
      throw new UnauthorizedException('Bearer access token is required.');
    }

    try {
      const payload = await this.jwtService.verifyAsync<AccessTokenPayload>(
        token,
        { secret: this.config.getOrThrow<string>('JWT_ACCESS_SECRET') },
      );
      if (payload.kind !== 'access') throw new Error('Wrong token kind');

      request.user = {
        id: payload.sub,
        fullName: payload.fullName,
        phone: payload.phone,
        email: payload.email,
        roles: payload.roles,
        agencyIds: payload.agencyIds,
        driverId: payload.driverId,
      };
      return true;
    } catch {
      throw new UnauthorizedException('Access token is invalid or expired.');
    }
  }
}
