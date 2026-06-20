BEGIN;

WITH demo_users (auth_subject, full_name, email, password_hash, role_code) AS (
  VALUES
    ('demo:passenger', 'Passenger Demo', 'passenger.demo@cameroonbus.test', '$2b$10$v9T/Aurlxj2Ec25Wybla1.ZAW1JCQThhAIcPLJOPvrvmy74YAjeJe', 'passenger'),
    ('demo:agency-owner', 'Agency Owner Demo', 'agency.owner.demo@cameroonbus.test', '$2b$10$v9T/Aurlxj2Ec25Wybla1.ZAW1JCQThhAIcPLJOPvrvmy74YAjeJe', 'agency_owner'),
    ('demo:agency-admin', 'Agency Admin Demo', 'agency.admin.demo@cameroonbus.test', '$2b$10$v9T/Aurlxj2Ec25Wybla1.ZAW1JCQThhAIcPLJOPvrvmy74YAjeJe', 'agency_admin'),
    ('demo:agency-staff', 'Agency Staff Demo', 'agency.staff.demo@cameroonbus.test', '$2b$10$v9T/Aurlxj2Ec25Wybla1.ZAW1JCQThhAIcPLJOPvrvmy74YAjeJe', 'agency_staff'),
    ('demo:dispatcher', 'Taxi Dispatcher Demo', 'dispatcher.demo@cameroonbus.test', '$2b$10$v9T/Aurlxj2Ec25Wybla1.ZAW1JCQThhAIcPLJOPvrvmy74YAjeJe', 'taxi_dispatcher'),
    ('demo:driver', 'Taxi Driver Demo', 'driver.demo@cameroonbus.test', '$2b$10$v9T/Aurlxj2Ec25Wybla1.ZAW1JCQThhAIcPLJOPvrvmy74YAjeJe', 'taxi_driver'),
    ('demo:super-admin', 'Super Admin Demo', 'superadmin.demo@cameroonbus.test', '$2b$10$v9T/Aurlxj2Ec25Wybla1.ZAW1JCQThhAIcPLJOPvrvmy74YAjeJe', 'super_admin')
)
INSERT INTO users (
  auth_subject,
  full_name,
  email,
  password_hash,
  status,
  email_verified_at
)
SELECT
  auth_subject,
  full_name,
  email,
  password_hash,
  'active',
  now()
FROM demo_users
ON CONFLICT (auth_subject) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  email = EXCLUDED.email,
  password_hash = EXCLUDED.password_hash,
  status = EXCLUDED.status,
  email_verified_at = EXCLUDED.email_verified_at;

WITH role_assignments (email, role_code) AS (
  VALUES
    ('passenger.demo@cameroonbus.test', 'passenger'),
    ('agency.owner.demo@cameroonbus.test', 'agency_owner'),
    ('agency.admin.demo@cameroonbus.test', 'agency_admin'),
    ('agency.staff.demo@cameroonbus.test', 'agency_staff'),
    ('dispatcher.demo@cameroonbus.test', 'taxi_dispatcher'),
    ('driver.demo@cameroonbus.test', 'taxi_driver'),
    ('superadmin.demo@cameroonbus.test', 'super_admin')
)
INSERT INTO user_roles (user_id, role_id, revoked_at)
SELECT user_record.id, role_record.id, NULL
FROM role_assignments assignment
JOIN users user_record ON lower(user_record.email) = lower(assignment.email)
JOIN roles role_record ON role_record.code = assignment.role_code
ON CONFLICT (user_id, role_id) DO UPDATE SET
  revoked_at = NULL;

INSERT INTO passenger_profiles (user_id)
SELECT id
FROM users
WHERE auth_subject = 'demo:passenger'
ON CONFLICT (user_id) DO NOTHING;

WITH staff_assignments (email, role_code) AS (
  VALUES
    ('agency.owner.demo@cameroonbus.test', 'agency_owner'),
    ('agency.admin.demo@cameroonbus.test', 'agency_admin'),
    ('agency.staff.demo@cameroonbus.test', 'agency_staff'),
    ('dispatcher.demo@cameroonbus.test', 'taxi_dispatcher')
),
demo_agency AS (
  SELECT id
  FROM agencies
  WHERE registration_number = 'UNITY-EXPRESS-DEMO'
)
INSERT INTO agency_staff (agency_id, user_id, role_id, active)
SELECT agency.id, user_record.id, role_record.id, true
FROM staff_assignments assignment
CROSS JOIN demo_agency agency
JOIN users user_record ON lower(user_record.email) = lower(assignment.email)
JOIN roles role_record ON role_record.code = assignment.role_code
ON CONFLICT (agency_id, user_id, role_id) DO UPDATE SET
  active = true,
  left_at = NULL;

WITH demo_agency AS (
  SELECT id
  FROM agencies
  WHERE registration_number = 'UNITY-EXPRESS-DEMO'
)
INSERT INTO taxi_vehicles (
  agency_id,
  registration_number,
  make,
  model,
  color,
  passenger_capacity,
  status
)
SELECT
  id,
  'UNITY-TAXI-001',
  'Demo',
  'Sedan',
  'White',
  4,
  'active'
FROM demo_agency
ON CONFLICT (agency_id, registration_number) DO UPDATE SET
  make = EXCLUDED.make,
  model = EXCLUDED.model,
  color = EXCLUDED.color,
  passenger_capacity = EXCLUDED.passenger_capacity,
  status = EXCLUDED.status;

WITH demo_agency AS (
  SELECT id
  FROM agencies
  WHERE registration_number = 'UNITY-EXPRESS-DEMO'
),
driver_user AS (
  SELECT id
  FROM users
  WHERE auth_subject = 'demo:driver'
),
demo_vehicle AS (
  SELECT vehicle.id
  FROM taxi_vehicles vehicle
  JOIN demo_agency agency ON agency.id = vehicle.agency_id
  WHERE vehicle.registration_number = 'UNITY-TAXI-001'
)
INSERT INTO taxi_drivers (
  agency_id,
  user_id,
  default_vehicle_id,
  status
)
SELECT agency.id, driver.id, vehicle.id, 'available'
FROM demo_agency agency
CROSS JOIN driver_user driver
CROSS JOIN demo_vehicle vehicle
ON CONFLICT (agency_id, user_id) DO UPDATE SET
  default_vehicle_id = EXCLUDED.default_vehicle_id,
  status = EXCLUDED.status;

-- Identity documents are intentionally not seeded. Do not use real ID numbers.

COMMIT;
