BEGIN;

INSERT INTO regions (name, code, active) VALUES
  ('South West', 'SW', true),
  ('North West', 'NW', true),
  ('Littoral', 'LT', true),
  ('West', 'OU', true),
  ('Centre', 'CE', true)
ON CONFLICT (code) DO UPDATE SET
  name = EXCLUDED.name,
  active = EXCLUDED.active;

WITH city_data (region_code, city_name) AS (
  VALUES
    ('SW', 'Buea'),
    ('SW', 'Limbe'),
    ('SW', 'Kumba'),
    ('NW', 'Bamenda'),
    ('LT', 'Douala'),
    ('OU', 'Bafoussam'),
    ('OU', 'Dschang'),
    ('CE', 'Yaoundé')
)
INSERT INTO cities (region_id, name, active)
SELECT r.id, d.city_name, true
FROM city_data d
JOIN regions r ON r.code = d.region_code
ON CONFLICT (region_id, name) DO UPDATE SET
  active = EXCLUDED.active;

COMMIT;
