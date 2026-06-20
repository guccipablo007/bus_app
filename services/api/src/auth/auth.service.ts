import { randomUUID } from 'node:crypto';

import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { compare, hash } from 'bcryptjs';

import type { AccessTokenPayload } from './authenticated-user';
import { AuthRepository } from './auth.repository';
import type { LoginDto } from './dto/login.dto';
import type { RegisterDto } from './dto/register.dto';
import { type StoredUser, UserRepository } from './user.repository';

export interface AuthResponse {
  accessToken: string;
  refreshToken: string;
  user: Omit<StoredUser, 'passwordHash' | 'agencyIds' | 'driverId'>;
}

@Injectable()
export class AuthService {
  constructor(
    private readonly users: UserRepository,
    private readonly credentials: AuthRepository,
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
  ) {}

  async register(dto: RegisterDto): Promise<AuthResponse> {
    const user = await this.users.create({
      id: randomUUID(),
      fullName: dto.fullName.trim(),
      phone: dto.phone.trim(),
      email: dto.email.trim().toLowerCase(),
      passwordHash: await hash(dto.password, 12),
      roles: ['passenger'],
      agencyIds: [],
    });
    return this.issueTokens(user);
  }

  async login(dto: LoginDto): Promise<AuthResponse> {
    const user = await this.credentials.findByIdentifier(dto.identifier);
    if (!user || !(await compare(dto.password, user.passwordHash))) {
      throw new UnauthorizedException('Invalid email, phone, or password.');
    }
    return this.issueTokens(user);
  }

  private async issueTokens(user: StoredUser): Promise<AuthResponse> {
    const payload: Omit<AccessTokenPayload, 'kind'> = {
      sub: user.id,
      fullName: user.fullName,
      phone: user.phone,
      email: user.email,
      roles: user.roles,
      agencyIds: user.agencyIds,
      driverId: user.driverId,
    };
    const [accessToken, refreshToken] = await Promise.all([
      this.jwt.signAsync(
        { ...payload, kind: 'access' satisfies AccessTokenPayload['kind'] },
        {
          secret: this.config.getOrThrow<string>('JWT_ACCESS_SECRET'),
          expiresIn: '15m',
        },
      ),
      this.jwt.signAsync(
        { sub: user.id, kind: 'refresh' },
        {
          secret: this.config.getOrThrow<string>('JWT_REFRESH_SECRET'),
          expiresIn: '30d',
        },
      ),
    ]);
    return {
      accessToken,
      refreshToken,
      user: {
        id: user.id,
        fullName: user.fullName,
        phone: user.phone,
        email: user.email,
        roles: user.roles,
      },
    };
  }
}
