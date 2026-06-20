import type { StoredUser } from './user.repository';

export abstract class AuthRepository {
  abstract findByIdentifier(identifier: string): Promise<StoredUser | undefined>;
}
