import { randomUUID } from 'node:crypto';

import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';

import type { AuthenticatedUser } from '../auth/authenticated-user';
import type { CreateAgencyApplicationDto } from './dto/create-agency-application.dto';
import type { CreateDriverApplicationDto } from './dto/create-driver-application.dto';
import type { DocumentMetadataDto } from './dto/document-metadata.dto';
import type { ReviewApplicationDto } from './dto/review-application.dto';
import type { ApplicationDocument, ApplicationType, OnboardingApplication } from './onboarding.models';
import { OnboardingRepository } from './onboarding.repository';

@Injectable()
export class OnboardingService {
  constructor(private readonly repository: OnboardingRepository) {}

  createAgency(user: AuthenticatedUser, dto: CreateAgencyApplicationDto) {
    return this.create(user, 'agency', {
      applicantName: dto.ownerManagerName,
      phone: dto.phone,
      email: dto.email,
      city: dto.city,
      companyName: dto.companyName,
      businessRegistrationNumber: dto.businessRegistrationNumber,
      description: dto.description,
      documents: dto.documents,
    });
  }

  createDriver(user: AuthenticatedUser, dto: CreateDriverApplicationDto) {
    return this.create(user, 'driver', {
      applicantName: dto.driverName,
      phone: dto.phone,
      email: user.email,
      city: dto.city,
      vehiclePlate: dto.vehiclePlate,
      description: dto.description,
      documents: dto.documents,
    });
  }

  listMine(user: AuthenticatedUser) {
    return this.repository.listByApplicant(user.id);
  }

  listAll() {
    return this.repository.listAll();
  }

  async review(user: AuthenticatedUser, id: string, dto: ReviewApplicationDto) {
    const application = await this.repository.findById(id);
    if (!application) throw new NotFoundException('Application not found.');
    if (dto.decision === 'rejected' && !dto.rejectionReason?.trim()) {
      throw new BadRequestException('A rejection reason is required when rejecting an application.');
    }
    const now = new Date().toISOString();
    return this.repository.update({
      ...application,
      status: dto.decision,
      reviewedAt: now,
      reviewedBy: user.id,
      rejectionReason: dto.decision === 'rejected' ? dto.rejectionReason?.trim() ?? null : null,
      updatedAt: now,
    });
  }

  private create(
    user: AuthenticatedUser,
    type: ApplicationType,
    values: {
      applicantName: string;
      phone: string;
      email: string;
      city: string;
      companyName?: string;
      businessRegistrationNumber?: string;
      vehiclePlate?: string;
      description?: string;
      documents?: DocumentMetadataDto[];
    },
  ) {
    const id = randomUUID();
    const now = new Date().toISOString();
    const documents: ApplicationDocument[] = (values.documents ?? []).map((document) => ({
      id: randomUUID(),
      applicationId: id,
      applicationType: type,
      documentType: document.documentType.trim(),
      originalFilename: document.originalFilename.trim(),
      storageProvider: 'staging_placeholder',
      placeholderPath: document.placeholderPath?.trim() || `metadata-only/${id}/${document.originalFilename.trim()}`,
      status: 'metadata_only',
      uploadedAt: null,
      createdAt: now,
      updatedAt: now,
    }));
    const application: OnboardingApplication = {
      id,
      applicantUserId: user.id,
      applicationType: type,
      applicantName: values.applicantName.trim(),
      phone: values.phone.trim(),
      email: values.email.trim().toLowerCase(),
      city: values.city.trim(),
      companyName: values.companyName?.trim(),
      businessRegistrationNumber: values.businessRegistrationNumber?.trim(),
      vehiclePlate: values.vehiclePlate?.trim(),
      description: values.description?.trim(),
      status: 'submitted',
      submittedAt: now,
      reviewedAt: null,
      reviewedBy: null,
      rejectionReason: null,
      createdAt: now,
      updatedAt: now,
      documents,
    };
    return this.repository.create(application);
  }
}
