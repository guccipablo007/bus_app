import type { OnboardingApplication } from './onboarding.models';

export abstract class OnboardingRepository {
  abstract create(application: OnboardingApplication): Promise<OnboardingApplication>;
  abstract listByApplicant(userId: string): Promise<OnboardingApplication[]>;
  abstract listAll(): Promise<OnboardingApplication[]>;
  abstract findById(id: string): Promise<OnboardingApplication | undefined>;
  abstract update(application: OnboardingApplication): Promise<OnboardingApplication>;
}
