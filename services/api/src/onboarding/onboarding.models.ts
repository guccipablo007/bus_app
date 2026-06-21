export type ApplicationType = 'agency' | 'driver';
export type ApplicationStatus = 'draft' | 'submitted' | 'under_review' | 'approved' | 'rejected';

export interface ApplicationDocument {
  id: string;
  applicationId: string;
  applicationType: ApplicationType;
  documentType: string;
  originalFilename: string;
  storageProvider: 'staging_placeholder';
  placeholderPath: string;
  status: 'metadata_only';
  uploadedAt: null;
  createdAt: string;
  updatedAt: string;
}

export interface OnboardingApplication {
  id: string;
  applicantUserId: string;
  applicationType: ApplicationType;
  applicantName: string;
  phone: string;
  email: string;
  city: string;
  companyName?: string;
  businessRegistrationNumber?: string;
  vehiclePlate?: string;
  description?: string;
  status: ApplicationStatus;
  submittedAt: string;
  reviewedAt: string | null;
  reviewedBy: string | null;
  rejectionReason: string | null;
  createdAt: string;
  updatedAt: string;
  documents: ApplicationDocument[];
}
