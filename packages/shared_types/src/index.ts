export const userRoles = [
  'passenger',
  'agency_owner',
  'agency_admin',
  'agency_staff',
  'taxi_dispatcher',
  'taxi_driver',
  'super_admin',
] as const;

export type UserRole = (typeof userRoles)[number];
