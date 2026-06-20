import { Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

import { AuthController } from './auth.controller';
import { AuthRepository } from './auth.repository';
import { AuthService } from './auth.service';
import { AgencyScopeGuard } from './agency-scope.guard';
import { DriverAssignmentGuard } from './driver-assignment.guard';
import { InMemoryUserRepository } from './in-memory-user.repository';
import { JwtAuthGuard } from './jwt-auth.guard';
import { RolesGuard } from './roles.guard';
import { UserRepository } from './user.repository';
import { PostgresUserRepository } from '../database/postgres-user.repository';
import { usePostgresRepositories } from '../database/repository-mode';

@Module({
  controllers: [AuthController],
  providers: [
    AuthService,
    InMemoryUserRepository,
    PostgresUserRepository,
    JwtAuthGuard,
    RolesGuard,
    AgencyScopeGuard,
    DriverAssignmentGuard,
    {
      provide: UserRepository,
      inject: [ConfigService, InMemoryUserRepository, PostgresUserRepository],
      useFactory: (config: ConfigService, memory: InMemoryUserRepository, postgres: PostgresUserRepository) =>
        usePostgresRepositories(config) ? postgres : memory,
    },
    {
      provide: AuthRepository,
      inject: [ConfigService, InMemoryUserRepository, PostgresUserRepository],
      useFactory: (config: ConfigService, memory: InMemoryUserRepository, postgres: PostgresUserRepository) =>
        usePostgresRepositories(config) ? postgres : memory,
    },
  ],
  exports: [JwtAuthGuard, RolesGuard, AgencyScopeGuard, DriverAssignmentGuard],
})
export class AuthModule {}
