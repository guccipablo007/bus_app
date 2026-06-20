import { Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

import { BookingRepository } from './booking.repository';
import { InMemoryDomainRepository } from './in-memory-domain.repository';
import { LocationRepository } from './location.repository';
import { TaxiRepository } from './taxi.repository';
import { TicketRepository } from './ticket.repository';
import { TripRepository } from './trip.repository';
import { PostgresBookingRepository } from '../database/postgres-booking.repository';
import { PostgresLocationRepository } from '../database/postgres-location.repository';
import { PostgresTaxiRepository } from '../database/postgres-taxi.repository';
import { PostgresTicketRepository } from '../database/postgres-ticket.repository';
import { PostgresTripRepository } from '../database/postgres-trip.repository';
import { usePostgresRepositories } from '../database/repository-mode';

@Module({
  providers: [
    InMemoryDomainRepository,
    PostgresLocationRepository,
    PostgresTripRepository,
    PostgresBookingRepository,
    PostgresTicketRepository,
    PostgresTaxiRepository,
    {
      provide: LocationRepository,
      inject: [ConfigService, InMemoryDomainRepository, PostgresLocationRepository],
      useFactory: (config: ConfigService, memory: InMemoryDomainRepository, postgres: PostgresLocationRepository) =>
        usePostgresRepositories(config) ? postgres : memory,
    },
    {
      provide: TripRepository,
      inject: [ConfigService, InMemoryDomainRepository, PostgresTripRepository],
      useFactory: (config: ConfigService, memory: InMemoryDomainRepository, postgres: PostgresTripRepository) =>
        usePostgresRepositories(config) ? postgres : memory,
    },
    {
      provide: BookingRepository,
      inject: [ConfigService, InMemoryDomainRepository, PostgresBookingRepository],
      useFactory: (config: ConfigService, memory: InMemoryDomainRepository, postgres: PostgresBookingRepository) =>
        usePostgresRepositories(config) ? postgres : memory,
    },
    {
      provide: TicketRepository,
      inject: [ConfigService, InMemoryDomainRepository, PostgresTicketRepository],
      useFactory: (config: ConfigService, memory: InMemoryDomainRepository, postgres: PostgresTicketRepository) =>
        usePostgresRepositories(config) ? postgres : memory,
    },
    {
      provide: TaxiRepository,
      inject: [ConfigService, InMemoryDomainRepository, PostgresTaxiRepository],
      useFactory: (config: ConfigService, memory: InMemoryDomainRepository, postgres: PostgresTaxiRepository) =>
        usePostgresRepositories(config) ? postgres : memory,
    },
  ],
  exports: [InMemoryDomainRepository, LocationRepository, TripRepository, BookingRepository, TicketRepository, TaxiRepository],
})
export class DataModule {}
