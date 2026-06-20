BEGIN;

CREATE TABLE buses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  agency_id uuid NOT NULL REFERENCES agencies(id) ON DELETE RESTRICT,
  registration_number text NOT NULL,
  display_name text,
  manufacturer text,
  model text,
  seat_capacity integer NOT NULL,
  seat_layout jsonb NOT NULL DEFAULT '{}'::jsonb,
  status bus_status NOT NULL DEFAULT 'active',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (agency_id, registration_number),
  CONSTRAINT buses_registration_not_blank CHECK (btrim(registration_number) <> ''),
  CONSTRAINT buses_capacity_positive CHECK (seat_capacity > 0)
);

CREATE INDEX buses_agency_id_idx ON buses (agency_id);

CREATE TABLE bus_seats (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  bus_id uuid NOT NULL REFERENCES buses(id) ON DELETE CASCADE,
  seat_number text NOT NULL,
  seat_row integer,
  seat_column integer,
  seat_type text NOT NULL DEFAULT 'standard',
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (bus_id, seat_number),
  CONSTRAINT bus_seats_number_not_blank CHECK (btrim(seat_number) <> ''),
  CONSTRAINT bus_seats_row_positive CHECK (seat_row IS NULL OR seat_row > 0),
  CONSTRAINT bus_seats_column_positive CHECK (seat_column IS NULL OR seat_column > 0)
);

CREATE INDEX bus_seats_bus_id_idx ON bus_seats (bus_id);

CREATE TABLE routes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  agency_id uuid NOT NULL REFERENCES agencies(id) ON DELETE RESTRICT,
  origin_terminal_id uuid NOT NULL REFERENCES terminals(id) ON DELETE RESTRICT,
  destination_terminal_id uuid NOT NULL REFERENCES terminals(id) ON DELETE RESTRICT,
  name text NOT NULL,
  distance_meters integer,
  estimated_duration_seconds integer,
  base_fare_xaf integer NOT NULL,
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (agency_id, origin_terminal_id, destination_terminal_id, name),
  CONSTRAINT routes_terminals_different CHECK (
    origin_terminal_id <> destination_terminal_id
  ),
  CONSTRAINT routes_distance_positive CHECK (
    distance_meters IS NULL OR distance_meters > 0
  ),
  CONSTRAINT routes_duration_positive CHECK (
    estimated_duration_seconds IS NULL OR estimated_duration_seconds > 0
  ),
  CONSTRAINT routes_fare_nonnegative CHECK (base_fare_xaf >= 0),
  CONSTRAINT routes_name_not_blank CHECK (btrim(name) <> '')
);

CREATE INDEX routes_origin_terminal_id_idx ON routes (origin_terminal_id);
CREATE INDEX routes_destination_terminal_id_idx ON routes (destination_terminal_id);
CREATE INDEX routes_agency_id_idx ON routes (agency_id);

CREATE TABLE trip_instances (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  route_id uuid NOT NULL REFERENCES routes(id) ON DELETE RESTRICT,
  bus_id uuid NOT NULL REFERENCES buses(id) ON DELETE RESTRICT,
  departure_time timestamptz NOT NULL,
  expected_arrival_time timestamptz NOT NULL,
  actual_departure_time timestamptz,
  actual_arrival_time timestamptz,
  fare_xaf integer NOT NULL,
  status trip_status NOT NULL DEFAULT 'scheduled',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT trip_instances_schedule_order CHECK (
    expected_arrival_time > departure_time
  ),
  CONSTRAINT trip_instances_actual_order CHECK (
    actual_arrival_time IS NULL
    OR actual_departure_time IS NULL
    OR actual_arrival_time >= actual_departure_time
  ),
  CONSTRAINT trip_instances_fare_nonnegative CHECK (fare_xaf >= 0)
);

CREATE INDEX trip_instances_route_id_idx ON trip_instances (route_id);
CREATE INDEX trip_instances_departure_time_idx ON trip_instances (departure_time);
CREATE INDEX trip_instances_route_departure_idx
  ON trip_instances (route_id, departure_time);
CREATE INDEX trip_instances_bus_id_idx ON trip_instances (bus_id);
CREATE INDEX trip_instances_status_idx ON trip_instances (status);

CREATE OR REPLACE FUNCTION validate_route_agency()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  origin_agency_id uuid;
  destination_agency_id uuid;
BEGIN
  SELECT agency_id INTO origin_agency_id
  FROM terminals
  WHERE id = NEW.origin_terminal_id;

  SELECT agency_id INTO destination_agency_id
  FROM terminals
  WHERE id = NEW.destination_terminal_id;

  IF origin_agency_id IS DISTINCT FROM NEW.agency_id
    OR destination_agency_id IS DISTINCT FROM NEW.agency_id THEN
    RAISE EXCEPTION 'Route terminals must belong to the route agency';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER routes_validate_agency
BEFORE INSERT OR UPDATE OF agency_id, origin_terminal_id, destination_terminal_id
ON routes
FOR EACH ROW EXECUTE FUNCTION validate_route_agency();

CREATE OR REPLACE FUNCTION validate_trip_bus_agency()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  route_agency_id uuid;
  bus_agency_id uuid;
BEGIN
  SELECT agency_id INTO route_agency_id FROM routes WHERE id = NEW.route_id;
  SELECT agency_id INTO bus_agency_id FROM buses WHERE id = NEW.bus_id;

  IF route_agency_id IS DISTINCT FROM bus_agency_id THEN
    RAISE EXCEPTION 'Trip bus and route must belong to the same agency';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trip_instances_validate_bus_agency
BEFORE INSERT OR UPDATE OF route_id, bus_id
ON trip_instances
FOR EACH ROW EXECUTE FUNCTION validate_trip_bus_agency();

CREATE TRIGGER buses_set_updated_at
BEFORE UPDATE ON buses
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER bus_seats_set_updated_at
BEFORE UPDATE ON bus_seats
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER routes_set_updated_at
BEFORE UPDATE ON routes
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trip_instances_set_updated_at
BEFORE UPDATE ON trip_instances
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

COMMIT;
