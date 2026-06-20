import type { AppRole } from './app-role';

export interface AuthenticatedUser {
  id: string;
  fullName: string;
  phone: string | null;
  email: string;
  roles: AppRole[];
  agencyIds?: string[];
  driverId?: string;
}

export interface AccessTokenPayload {
  sub: string;
  fullName: string;
  phone: string | null;
  email: string;
  roles: AppRole[];
  agencyIds?: string[];
  driverId?: string;
  kind: 'access';
}
