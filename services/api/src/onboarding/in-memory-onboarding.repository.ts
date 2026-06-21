import { Injectable } from '@nestjs/common';

import type { OnboardingApplication } from './onboarding.models';
import { OnboardingRepository } from './onboarding.repository';

@Injectable()
export class InMemoryOnboardingRepository implements OnboardingRepository {
  private readonly applications = new Map<string, OnboardingApplication>();

  async create(application: OnboardingApplication): Promise<OnboardingApplication> {
    this.applications.set(application.id, application);
    return application;
  }

  async listByApplicant(userId: string): Promise<OnboardingApplication[]> {
    return [...this.applications.values()].filter((item) => item.applicantUserId === userId);
  }

  async listAll(): Promise<OnboardingApplication[]> {
    return [...this.applications.values()];
  }

  async findById(id: string): Promise<OnboardingApplication | undefined> {
    return this.applications.get(id);
  }

  async update(application: OnboardingApplication): Promise<OnboardingApplication> {
    this.applications.set(application.id, application);
    return application;
  }
}
