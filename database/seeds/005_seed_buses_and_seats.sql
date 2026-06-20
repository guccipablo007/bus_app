BEGIN;

WITH demo_agency AS (
  SELECT id
  FROM agencies
  WHERE registration_number = 'UNITY-EXPRESS-DEMO'
),
bus_data (registration_number, display_name, seat_capacity) AS (
  VALUES
    ('UNITY-DEMO-30', 'Unity Demo 30-seat bus', 30),
    ('UNITY-DEMO-50', 'Unity Demo 50-seat bus', 50),
    ('UNITY-DEMO-70', 'Unity Demo 70-seat bus', 70)
)
INSERT INTO buses (
  agency_id,
  registration_number,
  display_name,
  seat_capacity,
  seat_layout,
  status
)
SELECT
  a.id,
  d.registration_number,
  d.display_name,
  d.seat_capacity,
  jsonb_build_object(
    'layoutVersion', 1,
    'generated', true,
    'seatCount', d.seat_capacity
  ),
  'active'
FROM bus_data d
CROSS JOIN demo_agency a
ON CONFLICT (agency_id, registration_number) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  seat_capacity = EXCLUDED.seat_capacity,
  seat_layout = EXCLUDED.seat_layout,
  status = EXCLUDED.status;

INSERT INTO bus_seats (
  bus_id,
  seat_number,
  seat_row,
  seat_column,
  seat_type,
  active
)
SELECT
  b.id,
  'S' || lpad(series.seat_no::text, 2, '0'),
  ((series.seat_no - 1) / 4) + 1,
  ((series.seat_no - 1) % 4) + 1,
  CASE
    WHEN series.seat_no <= 2 THEN 'priority'
    ELSE 'standard'
  END,
  true
FROM buses b
CROSS JOIN LATERAL generate_series(1, b.seat_capacity) AS series(seat_no)
JOIN agencies a ON a.id = b.agency_id
WHERE a.registration_number = 'UNITY-EXPRESS-DEMO'
ON CONFLICT (bus_id, seat_number) DO UPDATE SET
  seat_row = EXCLUDED.seat_row,
  seat_column = EXCLUDED.seat_column,
  seat_type = EXCLUDED.seat_type,
  active = EXCLUDED.active;

COMMIT;
