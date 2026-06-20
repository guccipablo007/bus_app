BEGIN;

CREATE TABLE residential_areas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  agency_id uuid NOT NULL REFERENCES agencies(id) ON DELETE RESTRICT,
  city_id uuid NOT NULL REFERENCES cities(id) ON DELETE RESTRICT,
  name text NOT NULL,
  center_point geography(Point, 4326) NOT NULL,
  boundary geography(Polygon, 4326),
  active boolean NOT NULL DEFAULT true,
  verified_by_admin boolean NOT NULL DEFAULT false,
  verified_by_user_id uuid REFERENCES users(id) ON DELETE SET NULL,
  verified_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (agency_id, city_id, name),
  CONSTRAINT residential_areas_name_not_blank CHECK (btrim(name) <> ''),
  CONSTRAINT residential_areas_verification_consistent CHECK (
    (verified_by_admin = true AND verified_at IS NOT NULL)
    OR verified_by_admin = false
  )
);

CREATE INDEX residential_areas_city_id_idx ON residential_areas (city_id);
CREATE INDEX residential_areas_agency_id_idx ON residential_areas (agency_id);
CREATE INDEX residential_areas_active_verified_idx
  ON residential_areas (city_id, active, verified_by_admin);
CREATE INDEX residential_areas_center_point_gix
  ON residential_areas USING gist (center_point);
CREATE INDEX residential_areas_boundary_gix
  ON residential_areas USING gist (boundary)
  WHERE boundary IS NOT NULL;

CREATE TABLE terminal_area_distances (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  terminal_id uuid NOT NULL REFERENCES terminals(id) ON DELETE CASCADE,
  residential_area_id uuid NOT NULL
    REFERENCES residential_areas(id) ON DELETE CASCADE,
  straight_line_meters integer NOT NULL,
  driving_distance_meters integer,
  driving_duration_seconds integer,
  active boolean NOT NULL DEFAULT true,
  verified_by_admin boolean NOT NULL DEFAULT false,
  verified_by_user_id uuid REFERENCES users(id) ON DELETE SET NULL,
  verified_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (terminal_id, residential_area_id),
  CONSTRAINT terminal_area_straight_distance_nonnegative CHECK (
    straight_line_meters >= 0
  ),
  CONSTRAINT terminal_area_driving_distance_nonnegative CHECK (
    driving_distance_meters IS NULL OR driving_distance_meters >= 0
  ),
  CONSTRAINT terminal_area_duration_nonnegative CHECK (
    driving_duration_seconds IS NULL OR driving_duration_seconds >= 0
  ),
  CONSTRAINT terminal_area_verification_consistent CHECK (
    (verified_by_admin = true AND verified_at IS NOT NULL)
    OR verified_by_admin = false
  )
);

CREATE INDEX terminal_area_distances_terminal_id_idx
  ON terminal_area_distances (terminal_id);
CREATE INDEX terminal_area_distances_residential_area_id_idx
  ON terminal_area_distances (residential_area_id);
CREATE INDEX terminal_area_distances_eligibility_idx
  ON terminal_area_distances (
    terminal_id,
    active,
    verified_by_admin,
    straight_line_meters
  );

CREATE TABLE taxi_vehicles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  agency_id uuid NOT NULL REFERENCES agencies(id) ON DELETE RESTRICT,
  registration_number text NOT NULL,
  make text,
  model text,
  color text,
  passenger_capacity integer NOT NULL DEFAULT 4,
  status taxi_vehicle_status NOT NULL DEFAULT 'active',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (agency_id, registration_number),
  CONSTRAINT taxi_vehicles_registration_not_blank CHECK (
    btrim(registration_number) <> ''
  ),
  CONSTRAINT taxi_vehicles_capacity_positive CHECK (passenger_capacity > 0)
);

CREATE INDEX taxi_vehicles_agency_id_idx ON taxi_vehicles (agency_id);

CREATE TABLE taxi_drivers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  agency_id uuid NOT NULL REFERENCES agencies(id) ON DELETE RESTRICT,
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  default_vehicle_id uuid REFERENCES taxi_vehicles(id) ON DELETE SET NULL,
  license_number text,
  license_expires_on date,
  status taxi_driver_status NOT NULL DEFAULT 'offline',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (agency_id, user_id)
);

CREATE UNIQUE INDEX taxi_drivers_license_number_unique_idx
  ON taxi_drivers (license_number)
  WHERE license_number IS NOT NULL;
CREATE INDEX taxi_drivers_agency_id_idx ON taxi_drivers (agency_id);
CREATE INDEX taxi_drivers_user_id_idx ON taxi_drivers (user_id);
CREATE INDEX taxi_drivers_status_idx ON taxi_drivers (status);

CREATE TABLE taxi_rides (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  agency_id uuid NOT NULL REFERENCES agencies(id) ON DELETE RESTRICT,
  booking_id uuid NOT NULL REFERENCES bookings(id) ON DELETE RESTRICT,
  passenger_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  pickup_terminal_id uuid NOT NULL REFERENCES terminals(id) ON DELETE RESTRICT,
  destination_area_id uuid NOT NULL
    REFERENCES residential_areas(id) ON DELETE RESTRICT,
  driver_id uuid REFERENCES taxi_drivers(id) ON DELETE SET NULL,
  vehicle_id uuid REFERENCES taxi_vehicles(id) ON DELETE SET NULL,
  destination_landmark text,
  status taxi_ride_status NOT NULL DEFAULT 'requested',
  estimated_fare_xaf integer NOT NULL,
  final_fare_xaf integer,
  requested_at timestamptz NOT NULL DEFAULT now(),
  scheduled_pickup_at timestamptz,
  assigned_at timestamptz,
  started_at timestamptz,
  completed_at timestamptz,
  cancelled_at timestamptz,
  issue_notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT taxi_rides_estimated_fare_nonnegative CHECK (
    estimated_fare_xaf >= 0
  ),
  CONSTRAINT taxi_rides_final_fare_nonnegative CHECK (
    final_fare_xaf IS NULL OR final_fare_xaf >= 0
  ),
  CONSTRAINT taxi_rides_completion_order CHECK (
    completed_at IS NULL OR started_at IS NULL OR completed_at >= started_at
  )
);

CREATE INDEX taxi_rides_booking_id_idx ON taxi_rides (booking_id);
CREATE INDEX taxi_rides_passenger_id_idx ON taxi_rides (passenger_id);
CREATE INDEX taxi_rides_driver_id_idx ON taxi_rides (driver_id);
CREATE INDEX taxi_rides_status_idx ON taxi_rides (status);
CREATE INDEX taxi_rides_agency_status_idx ON taxi_rides (agency_id, status);
CREATE INDEX taxi_rides_pickup_terminal_id_idx
  ON taxi_rides (pickup_terminal_id);

CREATE OR REPLACE FUNCTION validate_terminal_area_distance()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  terminal_city_id uuid;
  terminal_agency_id uuid;
  area_city_id uuid;
  area_agency_id uuid;
BEGIN
  SELECT city_id, agency_id INTO terminal_city_id, terminal_agency_id
  FROM terminals
  WHERE id = NEW.terminal_id;

  SELECT city_id, agency_id INTO area_city_id, area_agency_id
  FROM residential_areas
  WHERE id = NEW.residential_area_id;

  IF terminal_city_id IS DISTINCT FROM area_city_id THEN
    RAISE EXCEPTION 'Terminal and residential area must be in the same city';
  END IF;

  IF terminal_agency_id IS DISTINCT FROM area_agency_id THEN
    RAISE EXCEPTION 'Terminal and residential area must belong to the same agency';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER terminal_area_distances_validate
BEFORE INSERT OR UPDATE OF terminal_id, residential_area_id
ON terminal_area_distances
FOR EACH ROW EXECUTE FUNCTION validate_terminal_area_distance();

CREATE OR REPLACE FUNCTION validate_taxi_ride_eligibility()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  booking_passenger_id uuid;
  current_booking_status booking_status;
  arrival_terminal_id uuid;
  route_agency_id uuid;
  pickup_city_id uuid;
  area_city_id uuid;
  area_agency_id uuid;
  area_active boolean;
  area_verified boolean;
  zone_distance integer;
  zone_active boolean;
  zone_verified boolean;
  driver_agency_id uuid;
  vehicle_agency_id uuid;
BEGIN
  SELECT b.passenger_id, b.status, r.destination_terminal_id, r.agency_id
  INTO booking_passenger_id, current_booking_status, arrival_terminal_id, route_agency_id
  FROM bookings b
  JOIN trip_instances ti ON ti.id = b.trip_instance_id
  JOIN routes r ON r.id = ti.route_id
  WHERE b.id = NEW.booking_id;

  IF booking_passenger_id IS NULL THEN
    RAISE EXCEPTION 'Taxi ride requires a valid booking';
  END IF;

  IF booking_passenger_id IS DISTINCT FROM NEW.passenger_id THEN
    RAISE EXCEPTION 'Taxi ride passenger must own the booking';
  END IF;

  IF current_booking_status NOT IN ('paid', 'confirmed') THEN
    RAISE EXCEPTION 'Taxi add-on requires a paid or confirmed bus booking';
  END IF;

  IF arrival_terminal_id IS DISTINCT FROM NEW.pickup_terminal_id THEN
    RAISE EXCEPTION 'Taxi pickup must be the booking arrival terminal';
  END IF;

  IF route_agency_id IS DISTINCT FROM NEW.agency_id THEN
    RAISE EXCEPTION 'Taxi ride agency must match the bus route agency';
  END IF;

  SELECT city_id INTO pickup_city_id
  FROM terminals
  WHERE id = NEW.pickup_terminal_id;

  SELECT city_id, agency_id, active, verified_by_admin
  INTO area_city_id, area_agency_id, area_active, area_verified
  FROM residential_areas
  WHERE id = NEW.destination_area_id;

  IF pickup_city_id IS DISTINCT FROM area_city_id THEN
    RAISE EXCEPTION 'Taxi destination must be in the booking destination city';
  END IF;

  IF area_agency_id IS DISTINCT FROM NEW.agency_id THEN
    RAISE EXCEPTION 'Taxi destination area must belong to the ride agency';
  END IF;

  IF area_active IS DISTINCT FROM true OR area_verified IS DISTINCT FROM true THEN
    RAISE EXCEPTION 'Taxi destination area must be active and verified';
  END IF;

  SELECT straight_line_meters, active, verified_by_admin
  INTO zone_distance, zone_active, zone_verified
  FROM terminal_area_distances
  WHERE terminal_id = NEW.pickup_terminal_id
    AND residential_area_id = NEW.destination_area_id;

  IF zone_distance IS NULL
    OR zone_distance > 15000
    OR zone_active IS DISTINCT FROM true
    OR zone_verified IS DISTINCT FROM true THEN
    RAISE EXCEPTION 'Taxi destination area is not an eligible verified zone';
  END IF;

  IF NEW.driver_id IS NOT NULL THEN
    SELECT agency_id INTO driver_agency_id
    FROM taxi_drivers
    WHERE id = NEW.driver_id;

    IF driver_agency_id IS DISTINCT FROM NEW.agency_id THEN
      RAISE EXCEPTION 'Taxi driver must belong to the ride agency';
    END IF;
  END IF;

  IF NEW.vehicle_id IS NOT NULL THEN
    SELECT agency_id INTO vehicle_agency_id
    FROM taxi_vehicles
    WHERE id = NEW.vehicle_id;

    IF vehicle_agency_id IS DISTINCT FROM NEW.agency_id THEN
      RAISE EXCEPTION 'Taxi vehicle must belong to the ride agency';
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER taxi_rides_validate_eligibility
BEFORE INSERT OR UPDATE OF
  agency_id,
  booking_id,
  passenger_id,
  pickup_terminal_id,
  destination_area_id,
  driver_id,
  vehicle_id
ON taxi_rides
FOR EACH ROW EXECUTE FUNCTION validate_taxi_ride_eligibility();

CREATE TRIGGER residential_areas_set_updated_at
BEFORE UPDATE ON residential_areas
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER terminal_area_distances_set_updated_at
BEFORE UPDATE ON terminal_area_distances
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER taxi_vehicles_set_updated_at
BEFORE UPDATE ON taxi_vehicles
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER taxi_drivers_set_updated_at
BEFORE UPDATE ON taxi_drivers
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER taxi_rides_set_updated_at
BEFORE UPDATE ON taxi_rides
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE terminal_area_distances IS
  'Admin-verified terminal-to-area eligibility cache; API must also enforce the 15 km rule.';
COMMENT ON TABLE taxi_rides IS
  'Agency taxi add-on tied to a paid or confirmed bus booking and its arrival terminal.';

COMMIT;
