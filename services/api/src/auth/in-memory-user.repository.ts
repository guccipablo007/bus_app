import { ConflictException, Injectable } from '@nestjs/common';

import { AuthRepository } from './auth.repository';
import { type StoredUser, UserRepository } from './user.repository';

@Injectable()
export class InMemoryUserRepository implements UserRepository, AuthRepository {
  private readonly users = new Map<string, StoredUser>();

  async create(user: StoredUser): Promise<StoredUser> {
    const duplicate = [...this.users.values()].some(
      (candidate) =>
        candidate.email.toLowerCase() === user.email.toLowerCase() ||
        candidate.phone === user.phone,
    );
    if (duplicate) {
      throw new ConflictException('A user with that email or phone already exists.');
    }
    this.users.set(user.id, user);
    return user;
  }

  async findByIdentifier(identifier: string): Promise<StoredUser | undefined> {
    const normalized = identifier.trim().toLowerCase();
    return [...this.users.values()].find(
      (user) => user.email.toLowerCase() === normalized || user.phone === identifier.trim(),
    );
  }
}
