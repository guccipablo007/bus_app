BEGIN;

CREATE TABLE agency_applications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  applicant_user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  company_name text NOT NULL,
  owner_manager_name text NOT NULL,
  phone text NOT NULL,
  email text NOT NULL,
  city text NOT NULL,
  business_registration_number text,
  description text NOT NULL,
  status text NOT NULL DEFAULT 'submitted',
  submitted_at timestamptz NOT NULL DEFAULT now(),
  reviewed_at timestamptz,
  reviewed_by uuid REFERENCES users(id) ON DELETE SET NULL,
  rejection_reason text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT agency_applications_status_check CHECK
    (status IN ('draft', 'submitted', 'under_review', 'approved', 'rejected')),
  CONSTRAINT agency_applications_company_not_blank CHECK (btrim(company_name) <> '')
);

CREATE TABLE driver_applications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  applicant_user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  driver_name text NOT NULL,
  phone text NOT NULL,
  email text NOT NULL,
  city text NOT NULL,
  vehicle_plate text,
  description text,
  status text NOT NULL DEFAULT 'submitted',
  submitted_at timestamptz NOT NULL DEFAULT now(),
  reviewed_at timestamptz,
  reviewed_by uuid REFERENCES users(id) ON DELETE SET NULL,
  rejection_reason text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT driver_applications_status_check CHECK
    (status IN ('draft', 'submitted', 'under_review', 'approved', 'rejected')),
  CONSTRAINT driver_applications_name_not_blank CHECK (btrim(driver_name) <> '')
);

CREATE TABLE application_documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  application_id uuid NOT NULL,
  application_type text NOT NULL,
  document_type text NOT NULL,
  original_filename text NOT NULL,
  storage_provider text NOT NULL DEFAULT 'staging_placeholder',
  placeholder_path text NOT NULL,
  status text NOT NULL DEFAULT 'metadata_only',
  uploaded_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT application_documents_type_check CHECK
    (application_type IN ('agency', 'driver')),
  CONSTRAINT application_documents_status_check CHECK
    (status IN ('metadata_only', 'pending_upload', 'uploaded', 'verified', 'rejected')),
  CONSTRAINT application_documents_filename_not_blank CHECK (btrim(original_filename) <> '')
);

CREATE INDEX agency_applications_applicant_idx
  ON agency_applications (applicant_user_id, created_at DESC);
CREATE INDEX agency_applications_review_idx
  ON agency_applications (status, submitted_at DESC);
CREATE INDEX driver_applications_applicant_idx
  ON driver_applications (applicant_user_id, created_at DESC);
CREATE INDEX driver_applications_review_idx
  ON driver_applications (status, submitted_at DESC);
CREATE INDEX application_documents_application_idx
  ON application_documents (application_type, application_id);

COMMENT ON TABLE application_documents IS
  'Document metadata only for staging. File bytes require external object storage and are never stored on Render disk.';

COMMIT;
