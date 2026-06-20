BEGIN;

CREATE TABLE users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_subject text UNIQUE,
  full_name text NOT NULL,
  phone text,
  email text,
  password_hash text,
  status user_status NOT NULL DEFAULT 'pending_verification',
  phone_verified_at timestamptz,
  email_verified_at timestamptz,
  last_login_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT users_contact_required CHECK (phone IS NOT NULL OR email IS NOT NULL),
  CONSTRAINT users_phone_not_blank CHECK (phone IS NULL OR btrim(phone) <> ''),
  CONSTRAINT users_email_not_blank CHECK (email IS NULL OR btrim(email) <> '')
);

CREATE UNIQUE INDEX users_phone_unique_idx
  ON users (phone)
  WHERE phone IS NOT NULL;

CREATE UNIQUE INDEX users_email_lower_unique_idx
  ON users (lower(email))
  WHERE email IS NOT NULL;

CREATE TABLE roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  description text,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT roles_code_format CHECK (code ~ '^[a-z][a-z0-9_]*$')
);

INSERT INTO roles (code, name) VALUES
  ('passenger', 'Passenger'),
  ('agency_owner', 'Agency owner'),
  ('agency_admin', 'Agency administrator'),
  ('agency_staff', 'Agency staff'),
  ('taxi_dispatcher', 'Taxi dispatcher'),
  ('taxi_driver', 'Taxi driver'),
  ('super_admin', 'Super administrator')
ON CONFLICT (code) DO NOTHING;

CREATE TABLE user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role_id uuid NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
  assigned_by_user_id uuid REFERENCES users(id) ON DELETE SET NULL,
  assigned_at timestamptz NOT NULL DEFAULT now(),
  revoked_at timestamptz,
  UNIQUE (user_id, role_id),
  CONSTRAINT user_roles_revocation_order CHECK (
    revoked_at IS NULL OR revoked_at >= assigned_at
  )
);

CREATE INDEX user_roles_user_id_idx ON user_roles (user_id);
CREATE INDEX user_roles_role_id_idx ON user_roles (role_id);

CREATE TABLE passenger_profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  date_of_birth date,
  emergency_contact_name text,
  emergency_contact_phone text,
  accessibility_notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE identity_documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  document_type text NOT NULL,
  encrypted_document_number bytea NOT NULL,
  document_number_hash bytea,
  document_image_url text,
  verification_status identity_verification_status NOT NULL DEFAULT 'unverified',
  verified_by_user_id uuid REFERENCES users(id) ON DELETE SET NULL,
  verified_at timestamptz,
  expires_on date,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT identity_documents_type_not_blank CHECK (btrim(document_type) <> ''),
  CONSTRAINT identity_documents_verification_consistent CHECK (
    (verification_status = 'verified' AND verified_at IS NOT NULL)
    OR verification_status <> 'verified'
  )
);

CREATE UNIQUE INDEX identity_documents_number_hash_unique_idx
  ON identity_documents (document_number_hash)
  WHERE document_number_hash IS NOT NULL;

CREATE INDEX identity_documents_user_id_idx ON identity_documents (user_id);

CREATE TRIGGER users_set_updated_at
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER passenger_profiles_set_updated_at
BEFORE UPDATE ON passenger_profiles
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER identity_documents_set_updated_at
BEFORE UPDATE ON identity_documents
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

COMMENT ON COLUMN identity_documents.encrypted_document_number IS
  'Application-encrypted document number. Never log or return this value.';
COMMENT ON COLUMN identity_documents.document_number_hash IS
  'Optional keyed hash for duplicate detection; never use as a display value.';

COMMIT;
