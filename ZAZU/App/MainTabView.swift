//
//  MainTabView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import SwiftUI
import Supabase


struct MainTabView: View {
    let appState: AppState
    let authenticationService: AuthenticationService
    let profileRepository: ProfileRepository
    let candidateProfileRepository: CandidateProfileRepository
    let workExperienceRepository: WorkExperienceRepository
    let skillRepository: SkillRepository
    let educationRepository: EducationRepository
    let languageRepository: LanguageRepository
    let jobRepository: JobRepository
    let candidateJobInteractionRepository: CandidateJobInteractionRepository
    let matchRepository: MatchRepository
    let interviewRepository: InterviewRepository
    let supabaseClient: SupabaseClient
    let accountSwitcher: PoCAccountSwitcher
    let userId: UUID

    var body: some View {
        TabView {
            DiscoverView(
                viewModel: DiscoverViewModel(
                    jobRepository: jobRepository,
                    candidateProfileRepository: candidateProfileRepository,
                    workExperienceRepository: workExperienceRepository,
                    skillRepository: skillRepository,
                    languageRepository: languageRepository,
                    educationRepository: educationRepository,
                    candidateJobInteractionRepository: candidateJobInteractionRepository,
                    matchRepository: matchRepository,
                    userId: userId
                )
            )
            .tabItem {
                Label(
                    "Discover",
                    systemImage: "rectangle.stack.fill"
                )
            }

            MatchesView(
                viewModel: MatchesViewModel(
                    matchRepository: matchRepository,
                    jobRepository: jobRepository,
                    interviewRepository: interviewRepository,
                    candidateProfileRepository: candidateProfileRepository,
                    workExperienceRepository: workExperienceRepository,
                    skillRepository: skillRepository,
                    languageRepository: languageRepository,
                    educationRepository: educationRepository,
                    userId: userId
                ),
                interviewRepository: interviewRepository
            )
            .tabItem {
                Label(
                    "Matches",
                    systemImage: "heart.fill"
                )
            }

            ProfileView(
                viewModel: ProfileViewModel(
                    profileRepository: profileRepository,
                    candidateProfileRepository: candidateProfileRepository,
                    workExperienceRepository: workExperienceRepository,
                    skillRepository: skillRepository,
                    educationRepository: educationRepository,
                    languageRepository: languageRepository,
                    userId: userId
                ),
                appState: appState,
                authenticationService: authenticationService,
                profileRepository: profileRepository,
                candidateProfileRepository: candidateProfileRepository,
                workExperienceRepository: workExperienceRepository,
                skillRepository: skillRepository,
                educationRepository: educationRepository,
                languageRepository: languageRepository,
                candidateJobInteractionRepository: candidateJobInteractionRepository,
                matchRepository: matchRepository,
                supabaseClient: supabaseClient,
                accountSwitcher: accountSwitcher,
                userId: userId
            ).tabItem {
                Label(
                    "Profil",
                    systemImage: "person.fill"
                )
            }
        }
        .tint(ZAZUColors.primary)
    }
}

// MARK: - Temporary PoC Placeholders




