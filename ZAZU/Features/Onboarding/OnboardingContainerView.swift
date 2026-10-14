//
//  OnboardingContainerView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import SwiftUI

struct OnboardingContainerView: View {
    @State private var viewModel: OnboardingViewModel
    @Bindable var appState: AppState

    private let candidateProfileRepository: CandidateProfileRepository
    private let workExperienceRepository: WorkExperienceRepository
    private let skillRepository: SkillRepository
    private let educationRepository: EducationRepository
    private let languageRepository: LanguageRepository
    private let profileRepository: ProfileRepository
    
    
    private let userId: UUID

    init(
        appState: AppState,
        profileRepository: ProfileRepository,
        candidateProfileRepository: CandidateProfileRepository,
        workExperienceRepository: WorkExperienceRepository,
        skillRepository: SkillRepository,
        educationRepository: EducationRepository,
        languageRepository: LanguageRepository,
        userId: UUID
    ) {
        self.appState = appState
        self.profileRepository = profileRepository
        self.candidateProfileRepository = candidateProfileRepository
        self.workExperienceRepository = workExperienceRepository
        self.skillRepository = skillRepository
        self.educationRepository = educationRepository
        self.languageRepository = languageRepository
        self.userId = userId

        _viewModel = State(
            initialValue: OnboardingViewModel(
                repository: candidateProfileRepository,
                profileRepository: profileRepository,
                userId: userId
            )
        )
    }

    var body: some View {
        Group {
            if viewModel.isInitialLoading {
                loadingView
            } else {
                onboardingContent
            }
        }
        .task {
            await viewModel.load()
        }
    }

    @ViewBuilder
    private var onboardingContent: some View {
        switch viewModel.currentStep {
        case 0:
            BasicInformationView(
                viewModel: viewModel,
                onContinue: {
                    viewModel.currentStep = 1
                }
            )

        case 1:
            WorkExperienceView(
                viewModel: WorkExperienceViewModel(
                    workExperienceRepository: workExperienceRepository,
                    candidateProfileRepository: candidateProfileRepository,
                    candidateId: userId
                ),
                onContinue: {
                    viewModel.currentStep = 2
                }
            )

        case 2:
            SkillsView(
                viewModel: SkillsViewModel(
                    skillRepository: skillRepository,
                    candidateProfileRepository: candidateProfileRepository,
                    candidateId: userId
                ),
                onContinue: {
                    viewModel.currentStep = 3
                }
            )

        case 3:
            EducationView(
                viewModel: EducationViewModel(
                    educationRepository: educationRepository,
                    candidateProfileRepository: candidateProfileRepository,
                    candidateId: userId
                ),
                onContinue: {
                    viewModel.currentStep = 4
                }
            )

        case 4:
            LanguagesView(
                viewModel: LanguagesViewModel(
                    languageRepository: languageRepository,
                    candidateProfileRepository: candidateProfileRepository,
                    candidateId: userId
                ),
                onContinue: {
                    viewModel.currentStep = 5
                }
            )

        case 5:
            JobPreferencesView(
                viewModel: JobPreferencesViewModel(
                    repository: candidateProfileRepository,
                    userId: userId
                ),
                onContinue: {
                    viewModel.currentStep = 6
                }
            )

        case 6:
            WorkAndSalaryView(
                viewModel: WorkAndSalaryViewModel(
                    repository: candidateProfileRepository,
                    userId: userId
                ),
                onContinue: {
                    viewModel.currentStep = 7
                }
            )

        case 7:
            OnboardingSummaryView(
                viewModel: OnboardingSummaryViewModel(
                    profileRepository: profileRepository,
                    candidateProfileRepository: candidateProfileRepository,
                    workExperienceRepository: workExperienceRepository,
                    skillRepository: skillRepository,
                    educationRepository: educationRepository,
                    languageRepository: languageRepository,
                    userId: userId
                ),
                onComplete: {
                    appState.rootState = .main
                }
            )
            
            
        default:
            nextStepPlaceholder
        }
    }

    private var loadingView: some View {
        ZStack {
            ZAZUColors.veryLightPurple
                .ignoresSafeArea()

            ProgressView()
                .tint(ZAZUColors.primary)
        }
    }

    private var nextStepPlaceholder: some View {
        ZStack {
            ZAZUColors.veryLightPurple
                .ignoresSafeArea()

            VStack(spacing: ZAZUSpacing.medium) {
                Text("Schritt 7 gespeichert ✓")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(ZAZUColors.textPrimary)

                Text("Als Nächstes: Zusammenfassung")
                    .foregroundStyle(ZAZUColors.textSecondary)
            }
            .padding(ZAZUSpacing.large)
        }
    }
}
