//
//  EmployerMainTabView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 07.10.2026.
//

import SwiftUI
import Supabase

struct EmployerMainTabView: View {
    @Bindable var appState: AppState
    let authenticationService: AuthenticationService
    let supabaseClient: SupabaseClient
    
    let userId: UUID
    let companyRepository: CompanyRepository
    let jobRepository: JobRepository
    let matchRepository: MatchRepository
    let interviewRepository: InterviewRepository
    let skillRepository: SkillRepository
    let languageRepository: LanguageRepository
    let candidateProfileRepository: CandidateProfileRepository
    
    let employerMatchingRepository: EmployerMatchingRepository
    let employerMatchingService: EmployerMatchingService
    
    let accountSwitcher: PoCAccountSwitcher
    
    

    
    

    var body: some View {
        TabView {
            EmployerDiscoverView(
                userId: userId,
                companyRepository: companyRepository,
                jobRepository: jobRepository,
                skillRepository: skillRepository,
                languageRepository: languageRepository,
                employerMatchingRepository: employerMatchingRepository,
                employerMatchingService: employerMatchingService
            )
            .tabItem {
                Label("Kandidaten", systemImage: "person.2.fill")
            }

            EmployerJobsView(
                userId: userId,
                companyRepository: companyRepository,
                jobRepository: jobRepository,
                skillRepository: skillRepository,
                languageRepository: languageRepository,
                supabaseClient: supabaseClient
            )
            .tabItem {
                Label("Jobs", systemImage: "briefcase.fill")
            }

            EmployerMatchesView(
                matchRepository: matchRepository,
                jobRepository: jobRepository,
                companyRepository: companyRepository,
                interviewRepository: interviewRepository,
                skillRepository: skillRepository,
                languageRepository: languageRepository,
                employerMatchingRepository: employerMatchingRepository,
                employerMatchingService: employerMatchingService,
                userId: userId
            )
            .tabItem {
                Label("Matches", systemImage: "heart.fill")
            }

            EmployerCompanyView(
                appState: appState,
                authenticationService: authenticationService,
                supabaseClient: supabaseClient,
                accountSwitcher: accountSwitcher,
                companyRepository: companyRepository,
                userId: userId
            )

            .tabItem {

                Label("Unternehmen", systemImage: "building.2.fill")

            }
        }
        .tint(ZAZUColors.primary)
    }


}
