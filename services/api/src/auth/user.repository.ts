import type { AppRole } from './app-role';

export interface StoredUser {
  id: string;
  fullName: string;
  phone: string;
  email: string;
  passwordHash: string;
  roles: AppRole[];
  agencyIds: string[];
  driverId?: string;
}

export abstract class UserRepository {
  abstract create(user: StoredUser): Promise<StoredUser>;
}
