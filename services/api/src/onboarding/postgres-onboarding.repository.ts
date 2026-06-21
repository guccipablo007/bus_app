import { Injectable } from '@nestjs/common';

import { DatabaseService } from '../database/database.service';
import type { ApplicationDocument, ApplicationType, OnboardingApplication } from './onboarding.models';
import { OnboardingRepository } from './onboarding.repository';

interface ApplicationRow {
  id: string; applicant_user_id: string; application_type: ApplicationType;
  applicant_name: string; phone: string; email: string; city: string;
  company_name: string | null; business_registration_number: string | null;
  vehicle_plate: string | null; description: string | null; status: OnboardingApplication['status'];
  submitted_at: Date; reviewed_at: Date | null; reviewed_by: string | null;
  rejection_reason: string | null; created_at: Date; updated_at: Date;
}

interface DocumentRow {
  id: string; application_id: string; application_type: ApplicationType; document_type: string;
  original_filename: string; storage_provider: 'staging_placeholder'; placeholder_path: string;
  status: 'metadata_only'; uploaded_at: Date | null; created_at: Date; updated_at: Date;
}

@Injectable()
export class PostgresOnboardingRepository implements OnboardingRepository {
  constructor(private readonly database: DatabaseService) {}

  async create(application: OnboardingApplication): Promise<OnboardingApplication> {
    await this.database.transaction(async (client) => {
      const table = application.applicationType === 'agency' ? 'agency_applications' : 'driver_applications';
      if (application.applicationType === 'agency') {
        await client.query(
          `INSERT INTO ${table} (id, applicant_user_id, company_name, owner_manager_name, phone, email, city,
             business_registration_number, description, status, submitted_at, created_at, updated_at)
           VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)`,
          [application.id, application.applicantUserId, application.companyName, application.applicantName,
            application.phone, application.email, application.city, application.businessRegistrationNumber ?? null,
            application.description, application.status, application.submittedAt, application.createdAt, application.updatedAt],
        );
      } else {
        await client.query(
          `INSERT INTO ${table} (id, applicant_user_id, driver_name, phone, email, city, vehicle_plate,
             description, status, submitted_at, created_at, updated_at)
           VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)`,
          [application.id, application.applicantUserId, application.applicantName, application.phone,
            application.email, application.city, application.vehiclePlate ?? null, application.description ?? null,
            application.status, application.submittedAt, application.createdAt, application.updatedAt],
        );
      }
      for (const document of application.documents) {
        await client.query(
          `INSERT INTO application_documents (id, application_id, application_type, document_type,
             original_filename, storage_provider, placeholder_path, status, uploaded_at, created_at, updated_at)
           VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)`,
          [document.id, document.applicationId, document.applicationType, document.documentType,
            document.originalFilename, document.storageProvider, document.placeholderPath, document.status,
            document.uploadedAt, document.createdAt, document.updatedAt],
        );
      }
    });
    return application;
  }

  async listByApplicant(userId: string) { return this.list('WHERE applicant_user_id = $1', [userId]); }
  async listAll() { return this.list('', []); }

  async findById(id: string): Promise<OnboardingApplication | undefined> {
    return (await this.list('WHERE id = $1', [id]))[0];
  }

  async update(application: OnboardingApplication): Promise<OnboardingApplication> {
    const table = application.applicationType === 'agency' ? 'agency_applications' : 'driver_applications';
    await this.database.query(
      `UPDATE ${table} SET status=$2, reviewed_at=$3, reviewed_by=$4, rejection_reason=$5, updated_at=$6 WHERE id=$1`,
      [application.id, application.status, application.reviewedAt, application.reviewedBy,
        application.rejectionReason, application.updatedAt],
    );
    return application;
  }

  private async list(where: string, values: unknown[]): Promise<OnboardingApplication[]> {
    const result = await this.database.query<ApplicationRow>(
      `SELECT id, applicant_user_id, 'agency'::text AS application_type, owner_manager_name AS applicant_name,
         phone, email, city, company_name, business_registration_number, NULL::text AS vehicle_plate,
         description, status, submitted_at, reviewed_at, reviewed_by, rejection_reason, created_at, updated_at
       FROM agency_applications ${where}
       UNION ALL
       SELECT id, applicant_user_id, 'driver'::text, driver_name, phone, email, city, NULL::text,
         NULL::text, vehicle_plate, description, status, submitted_at, reviewed_at, reviewed_by,
         rejection_reason, created_at, updated_at FROM driver_applications ${where}
       ORDER BY created_at DESC`,
      values,
    );
    const documents = await this.documents(result.rows.map((row) => row.id));
    return result.rows.map((row) => this.map(row, documents.filter((doc) => doc.applicationId === row.id)));
  }

  private async documents(ids: string[]): Promise<ApplicationDocument[]> {
    if (ids.length === 0) return [];
    const result = await this.database.query<DocumentRow>(
      'SELECT * FROM application_documents WHERE application_id = ANY($1::uuid[]) ORDER BY created_at', [ids],
    );
    return result.rows.map((row) => ({ id: row.id, applicationId: row.application_id,
      applicationType: row.application_type, documentType: row.document_type,
      originalFilename: row.original_filename, storageProvider: row.storage_provider,
      placeholderPath: row.placeholder_path, status: row.status,
      uploadedAt: null, createdAt: row.created_at.toISOString(), updatedAt: row.updated_at.toISOString() }));
  }

  private map(row: ApplicationRow, documents: ApplicationDocument[]): OnboardingApplication {
    return { id: row.id, applicantUserId: row.applicant_user_id, applicationType: row.application_type,
      applicantName: row.applicant_name, phone: row.phone, email: row.email, city: row.city,
      companyName: row.company_name ?? undefined, businessRegistrationNumber: row.business_registration_number ?? undefined,
      vehiclePlate: row.vehicle_plate ?? undefined, description: row.description ?? undefined, status: row.status,
      submittedAt: row.submitted_at.toISOString(), reviewedAt: row.reviewed_at?.toISOString() ?? null,
      reviewedBy: row.reviewed_by, rejectionReason: row.rejection_reason,
      createdAt: row.created_at.toISOString(), updatedAt: row.updated_at.toISOString(), documents };
  }
}
