import type { INestApplication } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Test } from '@nestjs/testing';
import request = require('supertest');

import { AppModule } from '../src/app.module';
import { configureApp } from '../src/common/http/configure-app';
import { DEMO_IDS, InMemoryDomainRepository } from '../src/data/in-memory-domain.repository';

describe('API HTTP contract (e2e)', () => {
  let app: INestApplication;
  let passengerToken: string;
  let secondPassengerToken: string;
  let driverToken: string;
  let superAdminToken: string;

  const register = (email: string, phone: string) =>
    request(app.getHttpServer())
      .post('/api/v1/auth/register')
      .send({ fullName: 'Phase Six User', phone, email, password: 'strong-pass-6' });

  beforeAll(async () => {
    process.env.NODE_ENV = 'test';
    process.env.JWT_ACCESS_SECRET = 'phase-six-access-secret';
    process.env.JWT_REFRESH_SECRET = 'phase-six-refresh-secret';
    const moduleRef = await Test.createTestingModule({ imports: [AppModule] }).compile();
    app = moduleRef.createNestApplication();
    configureApp(app);
    await app.init();

    passengerToken = (await register('phase6-one@example.com', '+237670000061')).body.accessToken;
    secondPassengerToken = (await register('phase6-two@example.com', '+237670000062')).body.accessToken;
    const jwt = app.get(JwtService);
    const config = app.get(ConfigService);
    driverToken = await jwt.signAsync(
      {
        sub: 'driver-user', fullName: 'Driver', phone: null,
        email: 'driver@example.com', roles: ['taxi_driver'], driverId: 'driver-1', kind: 'access',
      },
      { secret: config.getOrThrow<string>('JWT_ACCESS_SECRET'), expiresIn: '15m' },
    );
    superAdminToken = await jwt.signAsync(
      {
        sub: 'super-admin-user', fullName: 'Super Admin', phone: null,
        email: 'admin@example.com', roles: ['super_admin'], kind: 'access',
      },
      { secret: config.getOrThrow<string>('JWT_ACCESS_SECRET'), expiresIn: '15m' },
    );
  });

  afterAll(async () => {
    await app.close();
  });

  it('serves deployment-safe health', async () => {
    const response = await request(app.getHttpServer()).get('/api/v1/health').expect(200);
    expect(response.body).toMatchObject({ status: 'ok', service: 'cameroon-bus-api', database: 'not_connected' });
  });

  it('logs in and returns backend roles', async () => {
    const response = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ identifier: 'phase6-one@example.com', password: 'strong-pass-6' })
      .expect(200);
    expect(response.body.user.roles).toEqual(['passenger']);
    expect(response.body.accessToken).toBeTruthy();
  });

  it('normalizes DTO validation errors without internal details', async () => {
    const response = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ identifier: 'x', password: 'short', unexpected: true })
      .expect(400);
    expect(response.body).toMatchObject({ statusCode: 400, path: '/api/v1/auth/login' });
    expect(response.body.message).toEqual(expect.any(Array));
    expect(response.body).not.toHaveProperty('stack');
  });

  it('rejects unauthenticated and wrong-role booking requests', async () => {
    const body = { tripId: DEMO_IDS.tripBueaBamenda, seatNumber: 'S01' };
    await request(app.getHttpServer()).post('/api/v1/bookings').send(body).expect(401);
    await request(app.getHttpServer()).post('/api/v1/bookings').set('Authorization', `Bearer ${driverToken}`).send(body).expect(403);
  });

  it('creates an authenticated passenger booking and protects ownership', async () => {
    const response = await request(app.getHttpServer())
      .post('/api/v1/bookings')
      .set('Authorization', `Bearer ${passengerToken}`)
      .send({ tripId: DEMO_IDS.tripBueaBamenda, seatNumber: 'S01' })
      .expect(201);
    expect(response.body.status).toBe('pending_payment');
    await request(app.getHttpServer())
      .get(`/api/v1/bookings/${response.body.id}`)
      .set('Authorization', `Bearer ${secondPassengerToken}`)
      .expect(403);
  });

  it('allows one concurrent seat request and returns 409 to the loser', async () => {
    const before = app.get(InMemoryDomainRepository).getSeatLockCount();
    const book = (token: string) => request(app.getHttpServer())
      .post('/api/v1/bookings')
      .set('Authorization', `Bearer ${token}`)
      .send({ tripId: DEMO_IDS.tripBueaBamenda, seatNumber: 'S02' });
    const responses = await Promise.all([book(passengerToken), book(secondPassengerToken)]);
    expect(responses.map((response) => response.status).sort()).toEqual([201, 409]);
    const conflict = responses.find((response) => response.status === 409);
    expect(conflict?.body).toMatchObject({ statusCode: 409, error: 'Conflict', path: '/api/v1/bookings' });
    expect(app.get(InMemoryDomainRepository).getSeatLockCount()).toBe(before + 1);
  });

  it('keeps payment confirmation idempotent and ticket-unique', async () => {
    const booking = await request(app.getHttpServer())
      .post('/api/v1/bookings')
      .set('Authorization', `Bearer ${passengerToken}`)
      .send({ tripId: DEMO_IDS.tripBueaBamenda, seatNumber: 'S03' })
      .expect(201);
    const first = await request(app.getHttpServer())
      .post(`/api/v1/bookings/${booking.body.id}/confirm-demo-payment`)
      .set('Authorization', `Bearer ${passengerToken}`).expect(201);
    const second = await request(app.getHttpServer())
      .post(`/api/v1/bookings/${booking.body.id}/confirm-demo-payment`)
      .set('Authorization', `Bearer ${passengerToken}`).expect(201);
    expect(second.body.ticket.id).toBe(first.body.ticket.id);
    expect(second.body.ticket.ticketCode).toBe(first.body.ticket.ticketCode);
  });

  it('blocks unpaid taxi access and unauthenticated taxi access', async () => {
    const booking = await request(app.getHttpServer())
      .post('/api/v1/bookings')
      .set('Authorization', `Bearer ${secondPassengerToken}`)
      .send({ tripId: DEMO_IDS.tripBueaDouala, seatNumber: 'S04' }).expect(201);
    await request(app.getHttpServer()).get(`/api/v1/bookings/${booking.body.id}/eligible-taxi-areas`).expect(401);
    const unpaid = await request(app.getHttpServer())
      .get(`/api/v1/bookings/${booking.body.id}/eligible-taxi-areas`)
      .set('Authorization', `Bearer ${secondPassengerToken}`).expect(422);
    expect(unpaid.body).toMatchObject({ statusCode: 422, error: 'Unprocessable Entity' });
  });

  it('returns a normalized 404 for a missing owned resource', async () => {
    const response = await request(app.getHttpServer())
      .get('/api/v1/bookings/missing-booking')
      .set('Authorization', `Bearer ${passengerToken}`)
      .expect(404);
    expect(response.body).toMatchObject({ statusCode: 404, error: 'Not Found' });
    expect(response.body).not.toHaveProperty('stack');
  });

  it('returns only eligible destination areas and rejects invalid ride destinations', async () => {
    const booking = await request(app.getHttpServer())
      .post('/api/v1/bookings')
      .set('Authorization', `Bearer ${secondPassengerToken}`)
      .send({ tripId: DEMO_IDS.tripBueaBamenda, seatNumber: 'S04' }).expect(201);
    await request(app.getHttpServer())
      .post(`/api/v1/bookings/${booking.body.id}/confirm-demo-payment`)
      .set('Authorization', `Bearer ${secondPassengerToken}`).expect(201);
    const eligible = await request(app.getHttpServer())
      .get(`/api/v1/bookings/${booking.body.id}/eligible-taxi-areas`)
      .set('Authorization', `Bearer ${secondPassengerToken}`).expect(200);
    expect(eligible.body.arrivalTerminal.city).toBe('Bamenda');
    expect(eligible.body.eligibleAreas.map((area: { id: string }) => area.id)).toEqual([DEMO_IDS.nkwen]);

    await request(app.getHttpServer())
      .post(`/api/v1/bookings/${booking.body.id}/taxi-rides`)
      .set('Authorization', `Bearer ${secondPassengerToken}`)
      .send({ destinationAreaId: 'area-does-not-exist', destinationLandmark: 'Near pharmacy' })
      .expect(422);
    await request(app.getHttpServer())
      .post(`/api/v1/bookings/${booking.body.id}/taxi-rides`)
      .set('Authorization', `Bearer ${secondPassengerToken}`)
      .send({ destinationAreaId: DEMO_IDS.akwa, destinationLandmark: 'Wrong city' })
      .expect(422);
    await request(app.getHttpServer())
      .post(`/api/v1/bookings/${booking.body.id}/taxi-rides`)
      .set('Authorization', `Bearer ${secondPassengerToken}`)
      .send({ destinationAreaId: DEMO_IDS.nkwen, destinationLandmark: 'Near pharmacy', pickupTerminalId: 'tampered' })
      .expect(400);
  });

  it('supports passenger applications and super-admin status-only review', async () => {
    const agency = await request(app.getHttpServer())
      .post('/api/v1/onboarding/agency-applications')
      .set('Authorization', `Bearer ${passengerToken}`)
      .send({
        companyName: 'Mountain Express', ownerManagerName: 'Test Owner',
        phone: '+237670000061', email: 'phase6-one@example.com', city: 'Buea',
        description: 'A staging agency application for intercity transport.',
        documents: [{ documentType: 'business_registration', originalFilename: 'registration.pdf' }],
      })
      .expect(201);
    expect(agency.body).toMatchObject({ applicationType: 'agency', status: 'submitted' });
    expect(agency.body.documents[0]).toMatchObject({
      storageProvider: 'staging_placeholder', status: 'metadata_only',
    });

    const driver = await request(app.getHttpServer())
      .post('/api/v1/onboarding/driver-applications')
      .set('Authorization', `Bearer ${passengerToken}`)
      .send({ driverName: 'Test Driver', phone: '+237670000061', city: 'Buea', vehiclePlate: 'SW-123-AA',
        documents: [{ documentType: 'driver_license', originalFilename: 'license.jpg' }] })
      .expect(201);
    expect(driver.body).toMatchObject({ applicationType: 'driver', status: 'submitted' });

    const mine = await request(app.getHttpServer())
      .get('/api/v1/onboarding/my-applications')
      .set('Authorization', `Bearer ${passengerToken}`).expect(200);
    expect(mine.body).toHaveLength(2);

    await request(app.getHttpServer())
      .patch(`/api/v1/admin/applications/${agency.body.id}/review`)
      .set('Authorization', `Bearer ${passengerToken}`)
      .send({ decision: 'approved' }).expect(403);

    const all = await request(app.getHttpServer())
      .get('/api/v1/admin/applications')
      .set('Authorization', `Bearer ${superAdminToken}`).expect(200);
    expect(all.body).toHaveLength(2);

    const approved = await request(app.getHttpServer())
      .patch(`/api/v1/admin/applications/${agency.body.id}/review`)
      .set('Authorization', `Bearer ${superAdminToken}`)
      .send({ decision: 'approved' }).expect(200);
    expect(approved.body).toMatchObject({ status: 'approved', rejectionReason: null });

    const rejected = await request(app.getHttpServer())
      .patch(`/api/v1/admin/applications/${driver.body.id}/review`)
      .set('Authorization', `Bearer ${superAdminToken}`)
      .send({ decision: 'rejected', rejectionReason: 'License metadata needs correction.' }).expect(200);
    expect(rejected.body).toMatchObject({ status: 'rejected', rejectionReason: 'License metadata needs correction.' });
  });
});
