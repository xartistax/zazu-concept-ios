//
//  ZAZUApp.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import SwiftUI

@main
struct ZAZUApp: App {
    @State private var appState = AppState()

    private let supabaseService: SupabaseService
    private let authenticationService: AuthenticationService
    private let candidateProfileRepository: CandidateProfileRepository
    private let workExperienceRepository: WorkExperienceRepository
    private let skillRepository: SkillRepository
    private let sessionService: SessionService
    private let educationRepository: EducationRepository
    private let languageRepository: LanguageRepository
    private let profileRepository: ProfileRepository
    private let jobRepository: JobRepository
    private let matchRepository: MatchRepository
    private let interviewRepository: InterviewRepository
    private let companyRepository: CompanyRepository

    
    let candidateJobInteractionRepository: CandidateJobInteractionRepository

    init() {
        let supabaseService = SupabaseService()

        let candidateProfileRepository = CandidateProfileRepository(
            client: supabaseService.client
        )

        let workExperienceRepository = WorkExperienceRepository(
            client: supabaseService.client
        )

        let skillRepository = SkillRepository(
            client: supabaseService.client
        )

        let authenticationService = AuthenticationService(
            client: supabaseService.client
        )
        
        let profileRepository = ProfileRepository(

            client: supabaseService.client

        )
        
        let companyRepository = CompanyRepository(
            client: supabaseService.client
        )

        let sessionService = SessionService(
            client: supabaseService.client,
            profileRepository: profileRepository,
            candidateProfileRepository: candidateProfileRepository,
            companyRepository: companyRepository
        )
        
        let educationRepository = EducationRepository(
            client: supabaseService.client
        )
        
        let languageRepository = LanguageRepository(
            client: supabaseService.client
        )
        

        
        let jobRepository = JobRepository(
            client: supabaseService.client
        )
        
        let matchRepository = MatchRepository(
            client: supabaseService.client
        )
        
        
        

        self.supabaseService = supabaseService
        self.authenticationService = authenticationService
        self.candidateProfileRepository = candidateProfileRepository
        self.workExperienceRepository = workExperienceRepository
        self.skillRepository = skillRepository
        self.sessionService = sessionService
        self.educationRepository = educationRepository
        self.languageRepository = languageRepository
        self.profileRepository = profileRepository
        self.jobRepository = jobRepository
        self.matchRepository = matchRepository
        self.companyRepository = companyRepository
        
        candidateJobInteractionRepository = CandidateJobInteractionRepository(
            client: supabaseService.client
        )
        
        interviewRepository = InterviewRepository(
            client: supabaseService.client
        )
        
        
    }

    var body: some Scene {
        WindowGroup {
            RootView(
                appState: appState,
                authenticationService: authenticationService,
                sessionService: sessionService,
                profileRepository: profileRepository,
                candidateProfileRepository: candidateProfileRepository,
                workExperienceRepository: workExperienceRepository,
                skillRepository: skillRepository,
                educationRepository: educationRepository,
                languageRepository: languageRepository,
                supabaseClient: supabaseService.client,
                jobRepository: jobRepository,
                candidateJobInteractionRepository: candidateJobInteractionRepository,
                matchRepository: matchRepository,
                interviewRepository: interviewRepository,
                companyRepository: companyRepository,
            )
            .preferredColorScheme(.light)
            .task {
                await sessionService.restoreSession(
                    appState: appState
                )
            }
        }
    }
}
