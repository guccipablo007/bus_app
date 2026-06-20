BEGIN;

-- Supabase commonly installs extensions in its `extensions` schema. These
-- guards are intentionally unqualified so an existing installation is reused.
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TYPE user_status AS ENUM (
  'pending_verification',
  'active',
  'suspended',
  'disabled'
);

CREATE TYPE identity_verification_status AS ENUM (
  'unverified',
  'pending',
  'verified',
  'rejected'
);

CREATE TYPE agency_status AS ENUM (
  'pending',
  'active',
  'suspended',
  'disabled'
);

CREATE TYPE bus_status AS ENUM (
  'active',
  'maintenance',
  'inactive',
  'retired'
);

CREATE TYPE trip_status AS ENUM (
  'scheduled',
  'boarding',
  'departed',
  'arrived',
  'cancelled'
);

CREATE TYPE booking_status AS ENUM (
  'pending_payment',
  'paid',
  'confirmed',
  'cancelled',
  'refunded',
  'checked_in',
  'boarded',
  'completed',
  'no_show'
);

CREATE TYPE payment_status AS ENUM (
  'initialized',
  'pending',
  'successful',
  'failed',
  'expired',
  'refunded',
  'manually_confirmed'
);

CREATE TYPE ticket_status AS ENUM (
  'active',
  'used',
  'cancelled',
  'expired'
);

CREATE TYPE taxi_vehicle_status AS ENUM (
  'active',
  'maintenance',
  'inactive',
  'retired'
);

CREATE TYPE taxi_driver_status AS ENUM (
  'available',
  'assigned',
  'on_ride',
  'offline',
  'suspended'
);

CREATE TYPE taxi_ride_status AS ENUM (
  'requested',
  'pending_payment',
  'scheduled',
  'assigned',
  'driver_on_way',
  'passenger_picked_up',
  'completed',
  'cancelled',
  'no_show'
);

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

COMMIT;
