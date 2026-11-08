//
//  OnboardingContainerView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import SwiftUI

struct OnboardingContainerView: View {
    @State private var viewModel: OnboardingViewModel
    @State private var educationViewModel: EducationViewModel
    @State private var workExperienceViewModel: WorkExperienceViewModel
    @State private var skillsViewModel: SkillsViewModel
    @Bindable var appState: AppState
    @State private var languagesViewModel: LanguagesViewModel
    @State private var jobPreferencesViewModel: JobPreferencesViewModel
    @State private var workAndSalaryViewModel: WorkAndSalaryViewModel

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
        _educationViewModel = State(
            initialValue: EducationViewModel(
                educationRepository: educationRepository,
                candidateProfileRepository: candidateProfileRepository,
                candidateId: userId
            )
        )
        _workExperienceViewModel = State(
            initialValue: WorkExperienceViewModel(
                workExperienceRepository: workExperienceRepository,
                candidateProfileRepository: candidateProfileRepository,
                candidateId: userId
            )
        )
        _skillsViewModel = State(
            initialValue: SkillsViewModel(
                skillRepository: skillRepository,
                candidateProfileRepository: candidateProfileRepository,
                candidateId: userId
            )
        )
        _languagesViewModel = State(
            initialValue: LanguagesViewModel(
                languageRepository: languageRepository,
                candidateProfileRepository: candidateProfileRepository,
                candidateId: userId
            )
        )
        _jobPreferencesViewModel = State(
            initialValue: JobPreferencesViewModel(
                repository: candidateProfileRepository,
                userId: userId
            )
        )
        _workAndSalaryViewModel = State(
            initialValue: WorkAndSalaryViewModel(
                repository: candidateProfileRepository,
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
                    .disabled(viewModel.isNavigating)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if !viewModel.isInitialLoading,
               viewModel.currentStep > 0 {
                VStack(
                    alignment: .leading,
                    spacing: ZAZUSpacing.small
                ) {
                    HStack {
                        Button {
                            Task {
                                await viewModel.goBack()
                            }
                        } label: {
                            HStack(spacing: ZAZUSpacing.small) {
                                if viewModel.isNavigating {
                                    ProgressView()
                                        .tint(ZAZUColors.primary)
                                } else {
                                    Image(systemName: "chevron.left")
                                }

                                Text("Zurück")
                            }
                            .font(.body.weight(.semibold))
                            .foregroundStyle(ZAZUColors.primary)
                            .padding(.vertical, ZAZUSpacing.small)
                        }
                        .buttonStyle(.plain)
                        .disabled(viewModel.isNavigating)

                        Spacer()
                    }

                    if let message = viewModel.navigationErrorMessage {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
                .padding(.horizontal, ZAZUSpacing.large)
                .background(ZAZUColors.veryLightPurple)
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
            EducationView(
                viewModel: EducationViewModel(
                    educationRepository: educationRepository,
                    candidateProfileRepository: candidateProfileRepository,
                    candidateId: userId
                ),
                onContinue: {
                    viewModel.currentStep = 2
                }
            )

        case 2:
            WorkExperienceView(
                viewModel: workExperienceViewModel,
                onContinue: {
                    viewModel.currentStep = 3
                }
            )
            
        case 3:
            SkillsView(
                viewModel: skillsViewModel,
                onContinue: {
                    viewModel.currentStep = 4
                }
            )

        case 4:
            LanguagesView(
                viewModel: languagesViewModel,
                onContinue: {
                    viewModel.currentStep = 5
                }
            )

        case 5:
            JobPreferencesView(
                viewModel: jobPreferencesViewModel,
                onContinue: {
                    viewModel.currentStep = 6
                }
            )

        case 6:
            WorkAndSalaryView(
                viewModel: workAndSalaryViewModel,
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
