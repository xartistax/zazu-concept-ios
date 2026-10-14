//
//  SessionService.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import Foundation
import Supabase

final class SessionService {
    private let client: SupabaseClient
    private let profileRepository: ProfileRepository
    private let candidateProfileRepository: CandidateProfileRepository
    private let companyRepository: CompanyRepository

    init(
        client: SupabaseClient,
        profileRepository: ProfileRepository,
        candidateProfileRepository: CandidateProfileRepository,
        companyRepository: CompanyRepository
    ) {
        self.client = client
        self.profileRepository = profileRepository
        self.candidateProfileRepository = candidateProfileRepository
        self.companyRepository = companyRepository
    }

    @MainActor
    func restoreSession(appState: AppState) async {
        do {
            let session = try await client.auth.session

            guard !session.isExpired else {
                appState.rootState = .authentication
                return
            }

            do {
                let profile = try await profileRepository.fetchProfile(
                    userId: session.user.id
                )

                switch profile.accountRole {
                case .candidate:
                    let candidateProfile =
                        try await candidateProfileRepository.fetchProfile(
                            userId: session.user.id
                        )

                    appState.rootState =
                        candidateProfile.onboardingCompleted
                        ? .main
                        : .onboarding

                case .employer:
                    guard let membership = try await companyRepository.fetchOwnMembership(
                        userId: session.user.id
                    ) else {
                        appState.rootState = .employerOnboarding
                        return
                    }

                    let company = try await companyRepository.fetchCompany(
                        companyId: membership.companyId
                    )

                    appState.rootState =
                        company.onboardingCompleted
                        ? .employerMain
                        : .employerOnboarding
                }

            } catch {
                appState.rootState = .error(
                    "Dein Profil konnte nicht geladen werden. Bitte versuche es erneut."
                )
            }

        } catch {
            appState.rootState = .authentication
        }
    }
}
