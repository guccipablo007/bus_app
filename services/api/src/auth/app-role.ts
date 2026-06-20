export const APP_ROLES = [
  'passenger',
  'agency_owner',
  'agency_admin',
  'agency_staff',
  'taxi_dispatcher',
  'taxi_driver',
  'super_admin',
] as const;

export type AppRole = (typeof APP_ROLES)[number];

export function isAppRole(value: unknown): value is AppRole {
  return typeof value === 'string' && APP_ROLES.includes(value as AppRole);
}
