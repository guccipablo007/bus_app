BEGIN;

WITH demo_agency AS (
  SELECT id
  FROM agencies
  WHERE registration_number = 'UNITY-EXPRESS-DEMO'
),
route_data (
  origin_city,
  destination_city,
  route_name,
  distance_meters,
  duration_seconds,
  fare_xaf
) AS (
  VALUES
    ('Buea', 'Bamenda', 'Buea -> Bamenda', 310000, 21600, 8000),
    ('Bamenda', 'Buea', 'Bamenda -> Buea', 310000, 21600, 8000),
    ('Buea', 'Douala', 'Buea -> Douala', 75000, 7200, 3500),
    ('Douala', 'Buea', 'Douala -> Buea', 75000, 7200, 3500),
    ('Bamenda', 'Douala', 'Bamenda -> Douala', 365000, 25200, 9000),
    ('Douala', 'Bamenda', 'Douala -> Bamenda', 365000, 25200, 9000),
    ('Buea', 'Yaoundé', 'Buea -> Yaoundé', 285000, 18000, 7500),
    ('Yaoundé', 'Buea', 'Yaoundé -> Buea', 285000, 18000, 7500),
    ('Bamenda', 'Yaoundé', 'Bamenda -> Yaoundé', 365000, 25200, 9000),
    ('Yaoundé', 'Bamenda', 'Yaoundé -> Bamenda', 365000, 25200, 9000),
    ('Bafoussam', 'Douala', 'Bafoussam -> Douala', 245000, 16200, 6500),
    ('Douala', 'Bafoussam', 'Douala -> Bafoussam', 245000, 16200, 6500),
    ('Bafoussam', 'Yaoundé', 'Bafoussam -> Yaoundé', 300000, 19800, 7500),
    ('Yaoundé', 'Bafoussam', 'Yaoundé -> Bafoussam', 300000, 19800, 7500)
)
INSERT INTO routes (
  agency_id,
  origin_terminal_id,
  destination_terminal_id,
  name,
  distance_meters,
  estimated_duration_seconds,
  base_fare_xaf,
  active
)
SELECT
  a.id,
  origin.id,
  destination.id,
  d.route_name,
  d.distance_meters,
  d.duration_seconds,
  d.fare_xaf,
  true
FROM route_data d
CROSS JOIN demo_agency a
JOIN terminals origin
  ON origin.agency_id = a.id
  AND origin.name = d.origin_city || ' Demo Terminal'
JOIN terminals destination
  ON destination.agency_id = a.id
  AND destination.name = d.destination_city || ' Demo Terminal'
ON CONFLICT (agency_id, origin_terminal_id, destination_terminal_id, name)
DO UPDATE SET
  distance_meters = EXCLUDED.distance_meters,
  estimated_duration_seconds = EXCLUDED.estimated_duration_seconds,
  base_fare_xaf = EXCLUDED.base_fare_xaf,
  active = EXCLUDED.active;

WITH demo_routes AS (
  SELECT
    r.id,
    r.base_fare_xaf,
    r.estimated_duration_seconds,
    row_number() OVER (ORDER BY r.name) AS route_number
  FROM routes r
  JOIN agencies a ON a.id = r.agency_id
  WHERE a.registration_number = 'UNITY-EXPRESS-DEMO'
),
demo_buses AS (
  SELECT
    b.id,
    row_number() OVER (ORDER BY b.seat_capacity, b.registration_number) AS bus_number,
    count(*) OVER () AS bus_count
  FROM buses b
  JOIN agencies a ON a.id = b.agency_id
  WHERE a.registration_number = 'UNITY-EXPRESS-DEMO'
),
trip_plan AS (
  SELECT
    r.id AS route_id,
    b.id AS bus_id,
    r.base_fare_xaf AS fare_xaf,
    (
      (
        CURRENT_DATE
        + (((r.route_number - 1) % 7) + 1 + offsets.week_offset)::integer
      )::timestamp
      + make_interval(hours => (7 + (((r.route_number - 1) % 3) * 3))::integer)
    ) AT TIME ZONE 'Africa/Douala' AS departure_time,
    r.estimated_duration_seconds
  FROM demo_routes r
  CROSS JOIN (VALUES (0), (7)) AS offsets(week_offset)
  JOIN demo_buses b
    ON b.bus_number = (((r.route_number - 1) % b.bus_count) + 1)
)
INSERT INTO trip_instances (
  route_id,
  bus_id,
  departure_time,
  expected_arrival_time,
  fare_xaf,
  status
)
SELECT
  p.route_id,
  p.bus_id,
  p.departure_time,
  p.departure_time + make_interval(secs => p.estimated_duration_seconds),
  p.fare_xaf,
  'scheduled'
FROM trip_plan p
WHERE NOT EXISTS (
  SELECT 1
  FROM trip_instances existing
  WHERE existing.route_id = p.route_id
    AND existing.departure_time = p.departure_time
);

COMMIT;
