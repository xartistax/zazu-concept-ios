//
//  MatchesView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 03.10.2026.
//

import SwiftUI

struct MatchesView: View {
    @State private var viewModel: MatchesViewModel
    private let interviewRepository: InterviewRepository

    init(
        viewModel: MatchesViewModel,
        interviewRepository: InterviewRepository
    ) {
        _viewModel = State(
            initialValue: viewModel
        )
        self.interviewRepository = interviewRepository
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ZAZUColors.veryLightPurple
                    .ignoresSafeArea()

                if viewModel.isLoading {
                    loadingView
                } else if let errorMessage = viewModel.errorMessage {
                    errorView(errorMessage)
                } else if viewModel.matches.isEmpty {
                    emptyView
                } else {
                    matchesList
                }
            }
            .navigationTitle("Matches")
            .task {
                await viewModel.load()
            }
        }
    }

    // MARK: - List

    private var matchesList: some View {
        ScrollView {
            LazyVStack(
                spacing: ZAZUSpacing.medium
            ) {
                ForEach(viewModel.matches) { match in
                    if let job = viewModel.job(for: match) {
                        NavigationLink {
                            InterviewSelectionView(
                                viewModel: InterviewSelectionViewModel(
                                    interviewRepository: interviewRepository,
                                    match: match
                                ),
                                job: job,
                                company: viewModel.company(for: job),
                                matchResult: viewModel.matchResult(for: job),
                                skillRequirements: viewModel.skillRequirements(for: job),
                                languageRequirements: viewModel.languageRequirements(for: job),
                                educationRequirements: viewModel.educationRequirements(for: job),
                                skillName: { skillId in
                                    viewModel.skillName(for: skillId)
                                },
                                languageName: { languageId in
                                    viewModel.languageName(for: languageId)
                                }
                            )
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
            .padding(ZAZUSpacing.large)
        }
        .refreshable {
            await viewModel.load()
        }
    }

    // MARK: - Card

    private func matchCard(
        match: Match,
        job: Job
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            HStack {
                Label(
                    "Job Match",
                    systemImage: "heart.fill"
                )
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(ZAZUColors.primary)

                Spacer()

                Text(
                    match.matchedAt,
                    format: .dateTime
                        .day()
                        .month()
                        .year()
                )
                .font(.caption)
                .foregroundStyle(ZAZUColors.textSecondary)
            }

            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.xSmall
            ) {
                Text(job.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(ZAZUColors.textPrimary)

                if let company = viewModel.company(for: job) {
                    Text(company.name)
                        .font(.headline)
                        .foregroundStyle(ZAZUColors.primary)
                }
            }

            Divider()

            Label(
                job.location,
                systemImage: "mappin.and.ellipse"
            )

            Label(
                job.workModel.title,
                systemImage: "building.2"
            )

            Label(
                "\(job.workloadMin)–\(job.workloadMax) %",
                systemImage: "percent"
            )

            HStack {
                if viewModel.hasConfirmedInterview(for: match) {
                    Label(
                        "Interview bestätigt",
                        systemImage: "checkmark.circle.fill"
                    )
                    .foregroundStyle(ZAZUColors.success)
                } else {
                    Label(
                        "Interview ausstehend",
                        systemImage: "calendar"
                    )
                    .foregroundStyle(ZAZUColors.primary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(ZAZUColors.textSecondary)
            }
            .font(.caption)
            .fontWeight(.semibold)
        }
        .font(.subheadline)
        .foregroundStyle(ZAZUColors.textSecondary)
        .padding(ZAZUSpacing.large)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: ZAZURadius.large
            )
        )
        .shadow(
            color: .black.opacity(0.05),
            radius: 8,
            y: 3
        )
    }

    // MARK: - States

    private var loadingView: some View {
        ProgressView(
            "Matches werden geladen …"
        )
        .tint(ZAZUColors.primary)
    }

    private var emptyView: some View {
        ContentUnavailableView(
            "Noch keine Matches",
            systemImage: "heart",
            description: Text(
                "Sobald ihr euch gegenseitig matcht, erscheint der Job hier."
            )
        )
    }

    private func errorView(
        _ message: String
    ) -> some View {
        ContentUnavailableView {
            Label(
                "Matches konnten nicht geladen werden",
                systemImage: "exclamationmark.triangle"
            )
        } description: {
            Text(message)
        } actions: {
            Button("Erneut versuchen") {
                Task {
                    await viewModel.load()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(ZAZUColors.primary)
        }
    }
}
