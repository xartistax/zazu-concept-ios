import SwiftUI
import Supabase

struct RootView: View {
    @Bindable var appState: AppState

    let authenticationService: AuthenticationService
    let sessionService: SessionService
    let profileRepository: ProfileRepository
    let candidateProfileRepository: CandidateProfileRepository
    let workExperienceRepository: WorkExperienceRepository
    let skillRepository: SkillRepository
    let educationRepository: EducationRepository
    let languageRepository: LanguageRepository
    let supabaseClient: SupabaseClient
    let jobRepository: JobRepository
    let candidateJobInteractionRepository: CandidateJobInteractionRepository
    let matchRepository: MatchRepository
    let interviewRepository: InterviewRepository
    let companyRepository: CompanyRepository

    
    private var employerMatchingRepository: EmployerMatchingRepository {
        EmployerMatchingRepository(
            client: supabaseClient,
            candidateProfileRepository: candidateProfileRepository,
            skillRepository: skillRepository,
            languageRepository: languageRepository,
            educationRepository: educationRepository,
            workExperienceRepository: workExperienceRepository,
            jobRepository: jobRepository
        )
    }

    private var employerMatchingService: EmployerMatchingService {
        EmployerMatchingService(
            matchingService: MatchingService()
        )
    }
    
    private var poCAccountSwitcher: PoCAccountSwitcher {
        PoCAccountSwitcher(
            client: supabaseClient,
            sessionService: sessionService
        )
    }
    
    

    var body: some View {
        switch appState.rootState {
        case .loading:
            LoadingView()

        case .authentication:
            AuthenticationView(
                viewModel: AuthenticationViewModel(
                    authenticationService: authenticationService,
                    sessionService: sessionService,
                    appState: appState
                )
            )

        case .onboarding:
            onboardingView
        
        case .employerOnboarding:
            employerOnboardingView

        case .employerMain:
            employerMainView

        case .main:
            mainView

        case .error(let message):
            RootErrorView(
                message: message
            )
        }
    }

    // MARK: - Onboarding


    @ViewBuilder
    private var onboardingView: some View {
        if let userId = supabaseClient.auth.currentUser?.id {
            OnboardingContainerView(
                appState: appState,
                profileRepository: profileRepository,
                candidateProfileRepository: candidateProfileRepository,
                workExperienceRepository: workExperienceRepository,
                skillRepository: skillRepository,
                educationRepository: educationRepository,
                languageRepository: languageRepository,
                userId: userId
            )
        } else {
            LoadingView()
        }
    }
    
    
    @ViewBuilder
    private var employerOnboardingView: some View {
        if let userId = supabaseClient.auth.currentUser?.id {
            EmployerOnboardingView(
                userId: userId,
                companyRepository: companyRepository
            ) {
                Task {
                    await sessionService.restoreSession(
                        appState: appState
                    )
                }
            }
        } else {
            LoadingView()
        }
    }
    
    // MARK: - Employer Main App

    @ViewBuilder
    private var employerMainView: some View {
        if let userId = supabaseClient.auth.currentUser?.id {
            EmployerMainTabView(
                appState: appState,
                authenticationService: authenticationService,
                supabaseClient: supabaseClient,
                userId: userId,
                companyRepository: companyRepository,
                jobRepository: jobRepository,
                matchRepository: matchRepository,
                interviewRepository: interviewRepository,
                skillRepository: skillRepository,
                languageRepository: languageRepository,
                candidateProfileRepository: candidateProfileRepository,
                employerMatchingRepository: employerMatchingRepository,
                employerMatchingService: employerMatchingService,
                accountSwitcher: poCAccountSwitcher
            )   } else {
            LoadingView()
        }
    }

    // MARK: - Main App

    @ViewBuilder
    private var mainView: some View {
        if let userId = supabaseClient.auth.currentUser?.id {
            MainTabView(
                appState: appState,
                authenticationService: authenticationService,
                profileRepository: profileRepository,
                candidateProfileRepository: candidateProfileRepository,
                workExperienceRepository: workExperienceRepository,
                skillRepository: skillRepository,
                educationRepository: educationRepository,
                languageRepository: languageRepository,
                jobRepository: jobRepository,
                candidateJobInteractionRepository: candidateJobInteractionRepository,
                matchRepository: matchRepository,
                interviewRepository: interviewRepository,
                supabaseClient: supabaseClient,
                accountSwitcher: poCAccountSwitcher,
                userId: userId

            )
        } else {
            LoadingView()
        }
    }
}

// MARK: - Loading

struct LoadingView: View {
    var body: some View {
        ZStack {
            ZAZUColors.veryLightPurple
                .ignoresSafeArea()

            ProgressView()
                .tint(ZAZUColors.primary)
        }
    }
}

// MARK: - Root Error

private struct RootErrorView: View {
    let message: String

    var body: some View {
        ZStack {
            ZAZUColors.veryLightPurple
                .ignoresSafeArea()

            VStack(spacing: ZAZUSpacing.large) {
                Image(
                    systemName: "exclamationmark.triangle"
                )
                .font(.system(size: 40))
                .foregroundStyle(ZAZUColors.primary)

                Text("Profil konnte nicht geladen werden")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(ZAZUColors.textPrimary)

                Text(message)
                    .foregroundStyle(ZAZUColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(ZAZUSpacing.large)
        }
    }
}


