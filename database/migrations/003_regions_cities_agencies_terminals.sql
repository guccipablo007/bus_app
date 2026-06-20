BEGIN;

CREATE TABLE regions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  code text NOT NULL UNIQUE,
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT regions_name_not_blank CHECK (btrim(name) <> ''),
  CONSTRAINT regions_code_not_blank CHECK (btrim(code) <> '')
);

CREATE TABLE cities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  region_id uuid NOT NULL REFERENCES regions(id) ON DELETE RESTRICT,
  name text NOT NULL,
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (region_id, name),
  CONSTRAINT cities_name_not_blank CHECK (btrim(name) <> '')
);

CREATE INDEX cities_region_id_idx ON cities (region_id);

CREATE TABLE agencies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  legal_name text NOT NULL,
  display_name text NOT NULL,
  registration_number text,
  contact_phone text,
  contact_email text,
  status agency_status NOT NULL DEFAULT 'pending',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT agencies_legal_name_not_blank CHECK (btrim(legal_name) <> ''),
  CONSTRAINT agencies_display_name_not_blank CHECK (btrim(display_name) <> '')
);

CREATE UNIQUE INDEX agencies_registration_number_unique_idx
  ON agencies (registration_number)
  WHERE registration_number IS NOT NULL;

CREATE TABLE agency_staff (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  agency_id uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role_id uuid NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
  active boolean NOT NULL DEFAULT true,
  joined_at timestamptz NOT NULL DEFAULT now(),
  left_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (agency_id, user_id, role_id),
  CONSTRAINT agency_staff_date_order CHECK (left_at IS NULL OR left_at >= joined_at)
);

CREATE INDEX agency_staff_agency_id_idx ON agency_staff (agency_id);
CREATE INDEX agency_staff_user_id_idx ON agency_staff (user_id);

CREATE TABLE terminals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  agency_id uuid NOT NULL REFERENCES agencies(id) ON DELETE RESTRICT,
  city_id uuid NOT NULL REFERENCES cities(id) ON DELETE RESTRICT,
  name text NOT NULL,
  address text,
  contact_phone text,
  location geography(Point, 4326) NOT NULL,
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (agency_id, city_id, name),
  CONSTRAINT terminals_name_not_blank CHECK (btrim(name) <> '')
);

CREATE INDEX terminals_city_id_idx ON terminals (city_id);
CREATE INDEX terminals_agency_id_idx ON terminals (agency_id);
CREATE INDEX terminals_location_gix ON terminals USING gist (location);

CREATE TRIGGER regions_set_updated_at
BEFORE UPDATE ON regions
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER cities_set_updated_at
BEFORE UPDATE ON cities
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER agencies_set_updated_at
BEFORE UPDATE ON agencies
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER agency_staff_set_updated_at
BEFORE UPDATE ON agency_staff
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER terminals_set_updated_at
BEFORE UPDATE ON terminals
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE agency_staff IS
  'Agency membership and scope. The API must verify role code and agency scope.';

COMMIT;
