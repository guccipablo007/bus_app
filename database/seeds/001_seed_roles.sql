BEGIN;

INSERT INTO roles (code, name, description) VALUES
  ('passenger', 'Passenger', 'Books bus trips and eligible destination taxi rides.'),
  ('agency_owner', 'Agency owner', 'Owns and administers an agency.'),
  ('agency_admin', 'Agency administrator', 'Manages agency operations and staff.'),
  ('agency_staff', 'Agency staff', 'Handles assigned agency operations.'),
  ('taxi_dispatcher', 'Taxi dispatcher', 'Assigns and monitors agency taxi rides.'),
  ('taxi_driver', 'Taxi driver', 'Completes assigned agency taxi rides.'),
  ('super_admin', 'Super administrator', 'Administers the platform.')
ON CONFLICT (code) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description;

COMMIT;
