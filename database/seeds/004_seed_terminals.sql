BEGIN;

WITH terminal_data (city_name, terminal_name, longitude, latitude, address) AS (
  VALUES
    ('Buea', 'Buea Demo Terminal', 9.2418, 4.1590, 'Approximate Molyko staging location'),
    ('Bamenda', 'Bamenda Demo Terminal', 10.1591, 5.9631, 'Approximate Commercial Avenue staging location'),
    ('Douala', 'Douala Demo Terminal', 9.7043, 4.0511, 'Approximate Akwa staging location'),
    ('Bafoussam', 'Bafoussam Demo Terminal', 10.4176, 5.4781, 'Approximate central staging location'),
    ('Yaoundé', 'Yaoundé Demo Terminal', 11.5200, 3.8300, 'Approximate Mvan staging location')
),
demo_agency AS (
  SELECT id
  FROM agencies
  WHERE registration_number = 'UNITY-EXPRESS-DEMO'
)
INSERT INTO terminals (
  agency_id,
  city_id,
  name,
  address,
  location,
  active
)
SELECT
  a.id,
  c.id,
  d.terminal_name,
  d.address,
  ST_SetSRID(ST_MakePoint(d.longitude, d.latitude), 4326)::geography,
  true
FROM terminal_data d
CROSS JOIN demo_agency a
JOIN cities c ON c.name = d.city_name
ON CONFLICT (agency_id, city_id, name) DO UPDATE SET
  address = EXCLUDED.address,
  location = EXCLUDED.location,
  active = EXCLUDED.active;

COMMIT;
