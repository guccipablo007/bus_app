BEGIN;

CREATE TABLE audit_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_user_id uuid REFERENCES users(id) ON DELETE SET NULL,
  agency_id uuid REFERENCES agencies(id) ON DELETE SET NULL,
  action text NOT NULL,
  entity_type text NOT NULL,
  entity_id uuid,
  request_id text,
  ip_address inet,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT audit_logs_action_not_blank CHECK (btrim(action) <> ''),
  CONSTRAINT audit_logs_entity_type_not_blank CHECK (btrim(entity_type) <> '')
);

CREATE INDEX audit_logs_actor_user_id_idx ON audit_logs (actor_user_id);
CREATE INDEX audit_logs_agency_id_idx ON audit_logs (agency_id);
CREATE INDEX audit_logs_entity_idx ON audit_logs (entity_type, entity_id);
CREATE INDEX audit_logs_created_at_idx ON audit_logs (created_at DESC);
CREATE INDEX audit_logs_action_created_at_idx
  ON audit_logs (action, created_at DESC);

CREATE INDEX users_status_idx ON users (status);
CREATE INDEX agencies_status_idx ON agencies (status);
CREATE INDEX terminals_active_city_idx ON terminals (city_id, active);
CREATE INDEX routes_active_origin_destination_idx
  ON routes (origin_terminal_id, destination_terminal_id, active);
CREATE INDEX bookings_trip_status_idx
  ON bookings (trip_instance_id, status);
CREATE INDEX payments_booking_status_idx
  ON payments (booking_id, status);
CREATE INDEX taxi_rides_booking_passenger_idx
  ON taxi_rides (booking_id, passenger_id);
CREATE INDEX taxi_rides_driver_status_idx
  ON taxi_rides (driver_id, status)
  WHERE driver_id IS NOT NULL;

COMMENT ON TABLE users IS
  'Application users authenticated and authorized by the hosted NestJS API.';
COMMENT ON TABLE user_roles IS
  'Multi-role assignments used by backend role guards and returned as role claims.';
COMMENT ON TABLE audit_logs IS
  'Security and operational audit events. Never store secrets or plain identity document numbers in metadata.';

COMMENT ON SCHEMA public IS
  'Cameroon Bus tables are backend-only. Do not expose database credentials or direct table access to Flutter.';

-- RLS is intentionally not enabled in this phase because the Flutter app never
-- connects directly to Supabase tables. If Supabase Data API exposure is added,
-- define and test explicit RLS policies before granting client access. Backend
-- authentication, agency scoping, ownership checks, and role guards remain
-- mandatory regardless of future RLS policies.

COMMIT;
