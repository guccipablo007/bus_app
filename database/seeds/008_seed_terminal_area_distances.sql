BEGIN;

INSERT INTO terminal_area_distances (
  terminal_id,
  residential_area_id,
  straight_line_meters,
  driving_distance_meters,
  driving_duration_seconds,
  active,
  verified_by_admin,
  verified_at
)
SELECT
  t.id,
  area.id,
  round(ST_Distance(t.location, area.center_point))::integer,
  NULL,
  NULL,
  area.active AND ST_DWithin(t.location, area.center_point, 15000),
  area.verified_by_admin,
  CASE WHEN area.verified_by_admin THEN now() ELSE NULL END
FROM terminals t
JOIN residential_areas area
  ON area.city_id = t.city_id
  AND area.agency_id = t.agency_id
JOIN agencies agency ON agency.id = t.agency_id
WHERE agency.registration_number = 'UNITY-EXPRESS-DEMO'
ON CONFLICT (terminal_id, residential_area_id) DO UPDATE SET
  straight_line_meters = EXCLUDED.straight_line_meters,
  driving_distance_meters = EXCLUDED.driving_distance_meters,
  driving_duration_seconds = EXCLUDED.driving_duration_seconds,
  active = EXCLUDED.active,
  verified_by_admin = EXCLUDED.verified_by_admin,
  verified_at = EXCLUDED.verified_at;

COMMIT;
