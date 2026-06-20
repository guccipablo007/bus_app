BEGIN;

CREATE TABLE bookings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_reference text NOT NULL UNIQUE,
  passenger_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  trip_instance_id uuid NOT NULL REFERENCES trip_instances(id) ON DELETE RESTRICT,
  status booking_status NOT NULL DEFAULT 'pending_payment',
  total_amount_xaf integer NOT NULL,
  currency char(3) NOT NULL DEFAULT 'XAF',
  expires_at timestamptz,
  cancelled_at timestamptz,
  cancellation_reason text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT bookings_reference_not_blank CHECK (btrim(booking_reference) <> ''),
  CONSTRAINT bookings_total_nonnegative CHECK (total_amount_xaf >= 0),
  CONSTRAINT bookings_currency_xaf CHECK (currency = 'XAF')
);

CREATE INDEX bookings_passenger_id_idx ON bookings (passenger_id);
CREATE INDEX bookings_trip_instance_id_idx ON bookings (trip_instance_id);
CREATE INDEX bookings_status_idx ON bookings (status);
CREATE INDEX bookings_passenger_status_idx ON bookings (passenger_id, status);

CREATE TABLE booking_passengers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id uuid NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  passenger_user_id uuid REFERENCES users(id) ON DELETE SET NULL,
  identity_document_id uuid REFERENCES identity_documents(id) ON DELETE SET NULL,
  full_name text NOT NULL,
  phone text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT booking_passengers_name_not_blank CHECK (btrim(full_name) <> '')
);

CREATE INDEX booking_passengers_booking_id_idx
  ON booking_passengers (booking_id);
CREATE INDEX booking_passengers_user_id_idx
  ON booking_passengers (passenger_user_id);

CREATE TABLE trip_seat_locks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_instance_id uuid NOT NULL REFERENCES trip_instances(id) ON DELETE CASCADE,
  seat_id uuid NOT NULL REFERENCES bus_seats(id) ON DELETE RESTRICT,
  booking_id uuid REFERENCES bookings(id) ON DELETE CASCADE,
  booking_passenger_id uuid REFERENCES booking_passengers(id) ON DELETE CASCADE,
  locked_by_user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  locked_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz NOT NULL,
  confirmed_at timestamptz,
  UNIQUE (trip_instance_id, seat_id),
  UNIQUE (booking_passenger_id),
  CONSTRAINT trip_seat_locks_expiry_order CHECK (expires_at > locked_at),
  CONSTRAINT trip_seat_locks_confirmation_order CHECK (
    confirmed_at IS NULL OR confirmed_at >= locked_at
  ),
  CONSTRAINT trip_seat_locks_passenger_requires_booking CHECK (
    booking_passenger_id IS NULL OR booking_id IS NOT NULL
  )
);

CREATE INDEX trip_seat_locks_trip_instance_id_idx
  ON trip_seat_locks (trip_instance_id);
CREATE INDEX trip_seat_locks_booking_id_idx
  ON trip_seat_locks (booking_id);
CREATE INDEX trip_seat_locks_expires_at_idx
  ON trip_seat_locks (expires_at);

CREATE TABLE payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id uuid NOT NULL REFERENCES bookings(id) ON DELETE RESTRICT,
  provider text NOT NULL,
  provider_reference text,
  amount_xaf integer NOT NULL,
  status payment_status NOT NULL DEFAULT 'initialized',
  payment_method text,
  failure_reason text,
  initiated_at timestamptz NOT NULL DEFAULT now(),
  completed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT payments_provider_not_blank CHECK (btrim(provider) <> ''),
  CONSTRAINT payments_amount_positive CHECK (amount_xaf > 0),
  CONSTRAINT payments_completion_order CHECK (
    completed_at IS NULL OR completed_at >= initiated_at
  )
);

CREATE UNIQUE INDEX payments_provider_reference_unique_idx
  ON payments (provider, provider_reference)
  WHERE provider_reference IS NOT NULL;
CREATE INDEX payments_booking_id_idx ON payments (booking_id);
CREATE INDEX payments_status_idx ON payments (status);

CREATE TABLE tickets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id uuid NOT NULL REFERENCES bookings(id) ON DELETE RESTRICT,
  booking_passenger_id uuid NOT NULL UNIQUE
    REFERENCES booking_passengers(id) ON DELETE RESTRICT,
  qr_value text NOT NULL UNIQUE,
  status ticket_status NOT NULL DEFAULT 'active',
  issued_at timestamptz NOT NULL DEFAULT now(),
  validated_at timestamptz,
  validated_by_user_id uuid REFERENCES users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT tickets_qr_not_blank CHECK (btrim(qr_value) <> '')
);

CREATE INDEX tickets_booking_id_idx ON tickets (booking_id);
CREATE INDEX tickets_status_idx ON tickets (status);

CREATE OR REPLACE FUNCTION validate_trip_seat_lock()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  trip_bus_id uuid;
  seat_bus_id uuid;
  booking_trip_id uuid;
  passenger_booking_id uuid;
BEGIN
  SELECT bus_id INTO trip_bus_id
  FROM trip_instances
  WHERE id = NEW.trip_instance_id;

  SELECT bus_id INTO seat_bus_id
  FROM bus_seats
  WHERE id = NEW.seat_id;

  IF trip_bus_id IS DISTINCT FROM seat_bus_id THEN
    RAISE EXCEPTION 'Seat does not belong to the bus assigned to this trip';
  END IF;

  IF NEW.booking_id IS NOT NULL THEN
    SELECT trip_instance_id INTO booking_trip_id
    FROM bookings
    WHERE id = NEW.booking_id;

    IF booking_trip_id IS DISTINCT FROM NEW.trip_instance_id THEN
      RAISE EXCEPTION 'Seat lock booking must be for the same trip';
    END IF;
  END IF;

  IF NEW.booking_passenger_id IS NOT NULL THEN
    SELECT booking_id INTO passenger_booking_id
    FROM booking_passengers
    WHERE id = NEW.booking_passenger_id;

    IF passenger_booking_id IS DISTINCT FROM NEW.booking_id THEN
      RAISE EXCEPTION 'Seat lock passenger must belong to the same booking';
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trip_seat_locks_validate
BEFORE INSERT OR UPDATE OF trip_instance_id, seat_id, booking_id, booking_passenger_id
ON trip_seat_locks
FOR EACH ROW EXECUTE FUNCTION validate_trip_seat_lock();

CREATE OR REPLACE FUNCTION validate_ticket_booking()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  passenger_booking_id uuid;
BEGIN
  SELECT booking_id INTO passenger_booking_id
  FROM booking_passengers
  WHERE id = NEW.booking_passenger_id;

  IF passenger_booking_id IS DISTINCT FROM NEW.booking_id THEN
    RAISE EXCEPTION 'Ticket passenger must belong to the same booking';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER tickets_validate_booking
BEFORE INSERT OR UPDATE OF booking_id, booking_passenger_id
ON tickets
FOR EACH ROW EXECUTE FUNCTION validate_ticket_booking();

CREATE TRIGGER bookings_set_updated_at
BEFORE UPDATE ON bookings
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER booking_passengers_set_updated_at
BEFORE UPDATE ON booking_passengers
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER payments_set_updated_at
BEFORE UPDATE ON payments
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER tickets_set_updated_at
BEFORE UPDATE ON tickets
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

COMMENT ON TABLE trip_seat_locks IS
  'Unique trip/seat rows prevent two active booking flows from owning one seat.';
COMMENT ON TABLE tickets IS
  'One ticket per booking passenger; qr_value is globally unique.';

COMMIT;
