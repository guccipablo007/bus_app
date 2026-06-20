BEGIN;

INSERT INTO agencies (
  legal_name,
  display_name,
  registration_number,
  contact_phone,
  contact_email,
  status
) VALUES (
  'Unity Express Demo Limited',
  'Unity Express Demo',
  'UNITY-EXPRESS-DEMO',
  NULL,
  'operations.demo@cameroonbus.test',
  'active'
)
ON CONFLICT (registration_number) WHERE registration_number IS NOT NULL
DO UPDATE SET
  legal_name = EXCLUDED.legal_name,
  display_name = EXCLUDED.display_name,
  contact_phone = EXCLUDED.contact_phone,
  contact_email = EXCLUDED.contact_email,
  status = EXCLUDED.status;

-- Agency staff memberships are inserted in 009 after demo users exist.

COMMIT;
