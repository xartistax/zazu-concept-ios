//
//  EmployerMatchedCandidateView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 11.10.2026.
//

import SwiftUI

struct EmployerMatchedCandidateView: View {
    let match: Match
    let job: Job
    let skills: [Skill]
    let languages: [Language]

    let interviewRepository: InterviewRepository
    let loadCandidateMatch: () async throws -> EmployerCandidateMatch?

    @State private var candidateMatch: EmployerCandidateMatch?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    @State private var confirmedInterview: Interview?
    @State private var candidateContact: CandidateContact?

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .tint(ZAZUColors.primary)

            } else if let errorMessage {
                errorState(errorMessage)

            } else if let candidateMatch {
                EmployerCandidateDetailView(
                    match: candidateMatch,
                    skills: skills,
                    languages: languages,
                    candidateContact: candidateContact
                )

            } else {
                errorState(
                    "Das Kandidatenprofil konnte nicht geladen werden."
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZAZUColors.veryLightPurple
                .ignoresSafeArea()
        )
        .task {
            await load()
        }
        .safeAreaInset(edge: .bottom) {
            if candidateMatch != nil {
                interviewButton
            }
        }
    }

    private var interviewButton: some View {
        NavigationLink {
            EmployerInterviewSlotsView(
                interviewRepository: interviewRepository,
                matchId: match.id
            )
        } label: {
            Label(
                "Interview planen",
                systemImage: "calendar.badge.plus"
            )
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(ZAZUColors.white)
            .background(ZAZUColors.primary)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: ZAZURadius.medium
                )
            )
        }
        .padding(.horizontal, ZAZUSpacing.medium)
        .padding(.vertical, ZAZUSpacing.small)
        .background(.ultraThinMaterial)
    }

    private func load() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            async let candidateMatchTask = loadCandidateMatch()
            async let interviewTask = interviewRepository.fetchEmployerInterview(
                matchId: match.id
            )

            let (
                loadedCandidateMatch,
                loadedInterview
            ) = try await (
                candidateMatchTask,
                interviewTask
            )

            candidateMatch = loadedCandidateMatch
            confirmedInterview = loadedInterview

            if loadedInterview != nil {
                candidateContact =
                    try await interviewRepository
                        .fetchConfirmedCandidateContact(
                            matchId: match.id
                        )
            } else {
                candidateContact = nil
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func errorState(
        _ message: String
    ) -> some View {
        VStack(spacing: ZAZUSpacing.medium) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundStyle(ZAZUColors.danger)

            Text("Profil konnte nicht geladen werden")
                .font(.headline)
                .foregroundStyle(ZAZUColors.textPrimary)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(ZAZUColors.textSecondary)
                .multilineTextAlignment(.center)

            Button("Erneut versuchen") {
                Task {
                    await load()
                }
            }
            .foregroundStyle(ZAZUColors.primary)
        }
        .padding(ZAZUSpacing.large)
    }
}
