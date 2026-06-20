BEGIN;

WITH area_data (
  city_name,
  area_name,
  longitude,
  latitude,
  is_active,
  is_verified
) AS (
  VALUES
    ('Bamenda', 'Nkwen', 10.1740, 5.9630, true, true),
    ('Bamenda', 'Mile 4', 10.1840, 5.9810, true, true),
    ('Bamenda', 'Up Station', 10.1390, 5.9410, true, true),
    ('Bamenda', 'Commercial Avenue', 10.1591, 5.9631, true, true),
    ('Bamenda', 'Small Mankon', 10.1450, 5.9720, true, false),
    ('Bamenda', 'Ntarikon', 10.1540, 5.9500, true, true),
    ('Bamenda', 'Ntamulung', 10.1640, 5.9560, true, false),
    ('Bamenda', 'Foncha Street', 10.1790, 5.9470, false, true),

    ('Buea', 'Molyko', 9.2920, 4.1580, true, true),
    ('Buea', 'Mile 17', 9.3030, 4.1010, true, true),
    ('Buea', 'Great Soppo', 9.2440, 4.1700, true, true),
    ('Buea', 'Bonduma', 9.2740, 4.1530, true, false),
    ('Buea', 'Clerks Quarter', 9.2360, 4.1630, true, true),
    ('Buea', 'Check Point', 9.2870, 4.1390, true, false),

    ('Douala', 'Bonaberi', 9.6500, 4.0800, true, true),
    ('Douala', 'Akwa', 9.7043, 4.0511, true, true),
    ('Douala', 'Bonamoussadi', 9.7450, 4.0980, true, true),
    ('Douala', 'Makepe', 9.7530, 4.0890, true, false),
    ('Douala', 'Bepanda', 9.7210, 4.0670, true, true),
    ('Douala', 'Deido', 9.7000, 4.0750, true, true),
    ('Douala', 'Logbessou', 9.8350, 4.1350, true, true),
    ('Douala', 'Bonapriso', 9.7000, 4.0300, true, false),

    ('Bafoussam', 'Tamja', 10.4130, 5.4810, true, true),
    ('Bafoussam', 'Djeleng', 10.4250, 5.4890, true, true),
    ('Bafoussam', 'Tamdja', 10.4070, 5.4730, true, false),
    ('Bafoussam', 'Banengo', 10.4390, 5.4940, true, true),
    ('Bafoussam', 'Kamkop', 10.3970, 5.4610, false, true),

    ('Yaoundé', 'Bastos', 11.5100, 3.8900, true, true),
    ('Yaoundé', 'Mvan', 11.5200, 3.8300, true, true),
    ('Yaoundé', 'Ekounou', 11.5350, 3.8490, true, true),
    ('Yaoundé', 'Essos', 11.5300, 3.8750, true, false),
    ('Yaoundé', 'Melen', 11.4920, 3.8620, true, true),
    ('Yaoundé', 'Biyem-Assi', 11.4800, 3.8420, true, true),
    ('Yaoundé', 'Emana', 11.5200, 4.0050, true, true),
    ('Yaoundé', 'Nlongkak', 11.5220, 3.8870, true, false)
),
demo_agency AS (
  SELECT id
  FROM agencies
  WHERE registration_number = 'UNITY-EXPRESS-DEMO'
)
INSERT INTO residential_areas (
  agency_id,
  city_id,
  name,
  center_point,
  active,
  verified_by_admin,
  verified_at
)
SELECT
  a.id,
  c.id,
  d.area_name,
  ST_SetSRID(ST_MakePoint(d.longitude, d.latitude), 4326)::geography,
  d.is_active,
  d.is_verified,
  CASE WHEN d.is_verified THEN now() ELSE NULL END
FROM area_data d
CROSS JOIN demo_agency a
JOIN cities c ON c.name = d.city_name
ON CONFLICT (agency_id, city_id, name) DO UPDATE SET
  center_point = EXCLUDED.center_point,
  active = EXCLUDED.active,
  verified_by_admin = EXCLUDED.verified_by_admin,
  verified_at = EXCLUDED.verified_at;

COMMIT;
