//
//  EmployerMatchesView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 10.10.2026.
//

import SwiftUI

struct EmployerMatchesView: View {
    @State private var viewModel: EmployerMatchesViewModel
    
    private let interviewRepository: InterviewRepository
    private let skillRepository: SkillRepository
    private let languageRepository: LanguageRepository

    init(
        matchRepository: MatchRepository,
        jobRepository: JobRepository,
        companyRepository: CompanyRepository,
        interviewRepository: InterviewRepository,
        skillRepository: SkillRepository,
        languageRepository: LanguageRepository,
        employerMatchingRepository: EmployerMatchingRepository,
        employerMatchingService: EmployerMatchingService,
        userId: UUID
    ) {
        self.interviewRepository = interviewRepository
        self.skillRepository = skillRepository
        self.languageRepository = languageRepository

        _viewModel = State(
            initialValue: EmployerMatchesViewModel(
                matchRepository: matchRepository,
                jobRepository: jobRepository,
                companyRepository: companyRepository,
                skillRepository: skillRepository,
                languageRepository: languageRepository,
                employerMatchingRepository: employerMatchingRepository,
                employerMatchingService: employerMatchingService,
                userId: userId
            )
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ZAZUColors.veryLightPurple
                    .ignoresSafeArea()

                content
            }
            .navigationTitle("Matches")
            .task {
                await viewModel.load()
            }
            .refreshable {
                await viewModel.load()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.matches.isEmpty {
            ProgressView()
                .tint(ZAZUColors.primary)
        } else if let errorMessage = viewModel.errorMessage {
            errorState(errorMessage)
        } else if viewModel.matches.isEmpty {
            emptyState
        } else {
            matchList
        }
    }

    private var matchList: some View {
        ScrollView {
            LazyVStack(spacing: ZAZUSpacing.medium) {
                ForEach(viewModel.matches) { match in
                    if let job = viewModel.job(for: match) {
                        NavigationLink {
                            EmployerMatchedCandidateView(
                                match: match,
                                job: job,
                                skills: viewModel.skills,
                                languages: viewModel.languages,
                                interviewRepository: interviewRepository
                            ) {
                                try await viewModel.candidateMatch(
                                    for: match,
                                    job: job
                                )
                            }
                        } label: {
                            matchCard(
                                match: match,
                                job: job
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(ZAZUSpacing.medium)
        }
    }

    private func matchCard(
        match: Match,
        job: Job
    ) -> some View {
        HStack(spacing: ZAZUSpacing.medium) {
            ZStack {
                Circle()
                    .fill(ZAZUColors.lightPurple)
                    .frame(width: 56, height: 56)

                Image(systemName: "heart.fill")
                    .foregroundStyle(ZAZUColors.primary)
            }

            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.xSmall
            ) {
                Text(job.title)
                    .font(.headline)
                    .foregroundStyle(ZAZUColors.textPrimary)

                Label(
                    "Mutual Match",
                    systemImage: "checkmark.circle.fill"
                )
                .font(.subheadline)
                .foregroundStyle(ZAZUColors.success)

                Text("Kandidatenprofil")
                    .font(.caption)
                    .foregroundStyle(ZAZUColors.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(ZAZUColors.textSecondary)
        }
        .padding(ZAZUSpacing.medium)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: ZAZURadius.medium
            )
        )
    }

    private var emptyState: some View {
        VStack(spacing: ZAZUSpacing.medium) {
            Image(systemName: "heart.slash")
                .font(.system(size: 44))
                .foregroundStyle(ZAZUColors.textSecondary)

            Text("Noch keine Matches")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(ZAZUColors.textPrimary)

            Text(
                "Sobald sich Arbeitgeber und Kandidat gegenseitig matchen, erscheint der Match hier."
            )
            .font(.subheadline)
            .foregroundStyle(ZAZUColors.textSecondary)
            .multilineTextAlignment(.center)
        }
        .padding(ZAZUSpacing.large)
    }

    private func errorState(
        _ message: String
    ) -> some View {
        VStack(spacing: ZAZUSpacing.medium) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundStyle(ZAZUColors.danger)

            Text("Matches konnten nicht geladen werden")
                .font(.headline)
                .foregroundStyle(ZAZUColors.textPrimary)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(ZAZUColors.textSecondary)
                .multilineTextAlignment(.center)

            Button("Erneut versuchen") {
                Task {
                    await viewModel.load()
                }
            }
            .foregroundStyle(ZAZUColors.primary)
        }
        .padding(ZAZUSpacing.large)
    }
}
