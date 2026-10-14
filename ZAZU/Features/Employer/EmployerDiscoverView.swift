//
//  EmployerDiscoverView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 08.10.2026.
//

import SwiftUI
import SwipeCardsKit

struct EmployerDiscoverView: View {
    @State private var viewModel: EmployerDiscoverViewModel

    @State private var swipeMatches: [EmployerCandidateMatch] = []
    @State private var selectedMatch: EmployerCandidateMatch?
    @State private var popTrigger: CardSwipeDirection?
    @State private var isSwipeStackReady = false
    
    @State private var detailMatch: EmployerCandidateMatch?
    @State private var celebrationJob: Job?

    init(
        userId: UUID,
        companyRepository: CompanyRepository,
        jobRepository: JobRepository,
        skillRepository: SkillRepository,
        languageRepository: LanguageRepository,
        employerMatchingRepository: EmployerMatchingRepository,
        employerMatchingService: EmployerMatchingService
    ) {
        _viewModel = State(
            initialValue: EmployerDiscoverViewModel(
                userId: userId,
                companyRepository: companyRepository,
                jobRepository: jobRepository,
                skillRepository: skillRepository,
                languageRepository: languageRepository,
                employerMatchingRepository: employerMatchingRepository,
                employerMatchingService: employerMatchingService
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
            .navigationTitle("Kandidaten")
            .task {
                await reloadCards()
            }
            .sheet(item: $detailMatch) { match in
                NavigationStack {
                    EmployerCandidateDetailView(
                        match: match,
                        skills: viewModel.skills,
                        languages: viewModel.languages
                    )
                }
            }
            .fullScreenCover(
                item: $celebrationJob
            ) { job in
                JobMatchCelebrationView(
                    job: job,
                    company: nil
                ) {
                    celebrationJob = nil
                    viewModel.mutualMatchId = nil
                }
            }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.jobs.isEmpty {
            loadingView
        } else if let errorMessage = viewModel.errorMessage {
            errorState(errorMessage)
        } else if viewModel.jobs.isEmpty {
            emptyJobsState
        } else {
            candidateContent
        }
    }

    private var candidateContent: some View {
        VStack(spacing: ZAZUSpacing.medium) {
            jobPicker

            if viewModel.isLoading {
                loadingView
            } else if swipeMatches.isEmpty {
                emptyCandidatesState
            } else if isSwipeStackReady {
                candidateSwipeStack
            }
        }
    }

    // MARK: - Job Picker

    private var jobPicker: some View {
        Menu {
            ForEach(viewModel.jobs) { job in
                Button(job.title) {
                    Task {
                        await selectJob(job)
                    }
                }
            }
        } label: {
            HStack {
                VStack(
                    alignment: .leading,
                    spacing: ZAZUSpacing.xSmall
                ) {
                    Text("Job")
                        .font(.caption)
                        .foregroundStyle(ZAZUColors.textSecondary)

                    Text(
                        viewModel.selectedJob?.title
                        ?? "Job auswählen"
                    )
                    .font(.headline)
                    .foregroundStyle(ZAZUColors.textPrimary)
                }

                Spacer()

                Image(systemName: "chevron.down")
                    .foregroundStyle(ZAZUColors.primary)
            }
            .padding(ZAZUSpacing.medium)
            .background(ZAZUColors.white)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: ZAZURadius.medium
                )
            )
        }
        .padding(.horizontal, ZAZUSpacing.medium)
    }

    // MARK: - Swipe Stack

    private var candidateSwipeStack: some View {
        CardSwipeView(
            items: $swipeMatches,
            selectedItem: $selectedMatch,
            popTrigger: $popTrigger
        ) { match, progress, direction in
            ZStack {
                candidateCard(match)

                swipeOverlay(
                    progress: progress,
                    direction: direction
                )
            }
            .contentShape(Rectangle())
            .onTapGesture {
                detailMatch = match
            }
            .padding(.horizontal, ZAZUSpacing.medium)
            .padding(.vertical, ZAZUSpacing.small)
        }
        .configure(
            threshold: 140,
            minimumDistance: 20,
            animateOnYAxes: false
        )
        .onSwipeEnd { match, direction in
            let decision: String

            switch direction {
            case .right:
                decision = "match"

            case .left:
                decision = "pass"

            default:
                return
            }

            Task {
                await viewModel.decide(
                    candidateId: match.candidateId,
                    decision: decision
                )

                if decision == "match",
                   viewModel.mutualMatchId != nil,
                   let job = viewModel.selectedJob {
                    celebrationJob = job
                }
            }
        }
        .onThresholdPassed {
            UIImpactFeedbackGenerator(
                style: .medium
            ).impactOccurred()
        }
    }

    // MARK: - Candidate Card

    private func candidateCard(
        _ match: EmployerCandidateMatch
    ) -> some View {
        let result = match.matchResult

        return VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.large
        ) {
            candidateHeader

            matchScore(result)

            Divider()

            VStack(spacing: ZAZUSpacing.medium) {
                employerCompatibilityRow(
                    title: "Lohn",
                    systemImage: "banknote",
                    criterion: result.salaryCompatibility
                )

                employerCompatibilityRow(
                    title: "Arbeitsmodell",
                    systemImage: "building.2",
                    criterion: result.workModelCompatibility
                )

                employerCompatibilityRow(
                    title: "Homeoffice",
                    systemImage: "house",
                    criterion: result.homeofficeCompatibility
                )
            }

            Divider()

            HStack(spacing: ZAZUSpacing.small) {
                requirementPill(
                    value:
                        "\(result.fulfilledMustCriteria.count)/\(result.mustCriteria.count)",
                    title: "MUSS",
                    color:
                        result.fulfillsAllMustCriteria
                        ? ZAZUColors.success
                        : ZAZUColors.danger
                )

                requirementPill(
                    value:
                        "\(result.fulfilledOptionalCriteria.count)/\(result.optionalCriteria.count)",
                    title: "OPTIONAL",
                    color: ZAZUColors.primary
                )
            }

            detailHint
        }
        .padding(ZAZUSpacing.large)
        .frame(
            maxWidth: .infinity,
            alignment: .topLeading
        )
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: ZAZURadius.large
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: ZAZURadius.large
            )
            .stroke(
                ZAZUColors.lightPurple.opacity(0.8),
                lineWidth: 1
            )
        }
        .shadow(
            color: .black.opacity(0.08),
            radius: 18,
            y: 8
        )
    }

    private var candidateHeader: some View {
        HStack(alignment: .center) {
            ZStack {
                Circle()
                    .fill(ZAZUColors.lightPurple)
                    .frame(
                        width: 56,
                        height: 56
                    )

                Image(systemName: "person.fill")
                    .font(.title2)
                    .foregroundStyle(ZAZUColors.primary)
            }

            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.xSmall
            ) {
                Text("Anonymes Profil")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(ZAZUColors.textPrimary)

                Label(
                    "Identität geschützt",
                    systemImage: "lock.fill"
                )
                .font(.caption)
                .foregroundStyle(ZAZUColors.textSecondary)
            }

            Spacer()
        }
    }

    private func matchScore(
        _ result: MatchResult
    ) -> some View {
        HStack(spacing: ZAZUSpacing.large) {
            ZStack {
                Circle()
                    .stroke(
                        ZAZUColors.lightPurple,
                        lineWidth: 8
                    )

                Circle()
                    .trim(
                        from: 0,
                        to: Double(result.score) / 100
                    )
                    .stroke(
                        ZAZUColors.primary,
                        style: StrokeStyle(
                            lineWidth: 8,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 0) {
                    Text("\(result.score)%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(ZAZUColors.textPrimary)

                    Text("Match")
                        .font(.caption2)
                        .foregroundStyle(ZAZUColors.textSecondary)
                }
            }
            .frame(
                width: 92,
                height: 92
            )

            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.small
            ) {
                Text("ZAZU Match")
                    .font(.headline)
                    .foregroundStyle(ZAZUColors.textPrimary)

                Label(
                    result.fulfillsAllMustCriteria
                        ? "Alle MUSS-Kriterien erfüllt"
                        : "\(result.missingMustCriteria.count) MUSS-Kriterien fehlen",
                    systemImage:
                        result.fulfillsAllMustCriteria
                        ? "checkmark.circle.fill"
                        : "exclamationmark.circle.fill"
                )
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(
                    result.fulfillsAllMustCriteria
                        ? ZAZUColors.success
                        : ZAZUColors.danger
                )
            }

            Spacer()
        }
    }

    // MARK: - Compatibility

    private func employerCompatibilityRow(
        title: String,
        systemImage: String,
        criterion: MatchCriterion
    ) -> some View {
        HStack(spacing: ZAZUSpacing.medium) {
            Image(systemName: systemImage)
                .foregroundStyle(ZAZUColors.primary)
                .frame(width: 24)

            Text(title)
                .font(.subheadline)
                .foregroundStyle(ZAZUColors.textPrimary)

            Spacer()

            Label(
                criterion.isFulfilled
                    ? "Passt"
                    : "Abweichung",
                systemImage:
                    criterion.isFulfilled
                    ? "checkmark.circle.fill"
                    : "minus.circle.fill"
            )
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(
                criterion.isFulfilled
                    ? ZAZUColors.success
                    : ZAZUColors.textSecondary
            )
        }
    }

    // MARK: - Requirement Summary

    private func requirementPill(
        value: String,
        title: String,
        color: Color
    ) -> some View {
        VStack(spacing: ZAZUSpacing.xSmall) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(color)

            Text(title)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(ZAZUColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, ZAZUSpacing.medium)
        .background(
            color.opacity(0.08)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: ZAZURadius.medium
            )
        )
    }

    private var detailHint: some View {
        HStack {
            Image(systemName: "hand.tap")
                .font(.caption)

            Text("Tippen für Matching-Details")
                .font(.caption)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
        }
        .foregroundStyle(ZAZUColors.textSecondary)
        .padding(.top, ZAZUSpacing.small)
    }

    // MARK: - Swipe Overlay

    @ViewBuilder
    private func swipeOverlay(
        progress: CGFloat,
        direction: CardSwipeDirection
    ) -> some View {
        VStack {
            HStack {
                if direction == .right {
                    swipeBadge(
                        title: "MATCH",
                        systemImage: "heart.fill",
                        color: ZAZUColors.primary,
                        rotation: -10
                    )
                    .opacity(progress)

                    Spacer()
                } else if direction == .left {
                    Spacer()

                    swipeBadge(
                        title: "PASS",
                        systemImage: "xmark",
                        color: ZAZUColors.textSecondary,
                        rotation: 10
                    )
                    .opacity(progress)
                }
            }

            Spacer()
        }
        .padding(ZAZUSpacing.large)
        .allowsHitTesting(false)
    }

    private func swipeBadge(
        title: String,
        systemImage: String,
        color: Color,
        rotation: Double
    ) -> some View {
        Label(
            title,
            systemImage: systemImage
        )
        .font(.headline)
        .fontWeight(.bold)
        .foregroundStyle(color)
        .padding(.horizontal, ZAZUSpacing.medium)
        .padding(.vertical, ZAZUSpacing.small)
        .background(
            ZAZUColors.white.opacity(0.95)
        )
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .stroke(
                    color,
                    lineWidth: 2
                )
        }
        .rotationEffect(
            .degrees(rotation)
        )
    }

    // MARK: - States

    private var loadingView: some View {
        ProgressView()
            .tint(ZAZUColors.primary)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
    }

    private var emptyCandidatesState: some View {
        VStack(spacing: ZAZUSpacing.small) {
            Spacer()

            Image(systemName: "person.slash")
                .font(.system(size: 40))
                .foregroundStyle(ZAZUColors.textSecondary)

            Text("Keine Kandidaten gefunden")
                .font(.headline)
                .foregroundStyle(ZAZUColors.textPrimary)

            Text(
                "Für diesen Job gibt es aktuell keine passenden Kandidaten."
            )
            .font(.subheadline)
            .foregroundStyle(ZAZUColors.textSecondary)
            .multilineTextAlignment(.center)

            Spacer()
        }
        .padding()
    }

    private var emptyJobsState: some View {
        VStack(spacing: ZAZUSpacing.medium) {
            Image(systemName: "briefcase")
                .font(.system(size: 44))
                .foregroundStyle(ZAZUColors.primary)

            Text("Kein aktiver Job")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(ZAZUColors.textPrimary)

            Text(
                "Erstelle oder aktiviere zuerst einen Job, um Kandidaten zu entdecken."
            )
            .foregroundStyle(ZAZUColors.textSecondary)
            .multilineTextAlignment(.center)
        }
        .padding(ZAZUSpacing.large)
    }

    private func errorState(
        _ message: String
    ) -> some View {
        VStack(spacing: ZAZUSpacing.medium) {
            Image(
                systemName: "exclamationmark.triangle.fill"
            )
            .font(.system(size: 40))
            .foregroundStyle(ZAZUColors.danger)

            Text("Kandidaten konnten nicht geladen werden")
                .font(.headline)
                .foregroundStyle(ZAZUColors.textPrimary)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(ZAZUColors.textSecondary)
                .multilineTextAlignment(.center)

            Button("Erneut versuchen") {
                Task {
                    await reloadCards()
                }
            }
            .foregroundStyle(ZAZUColors.primary)
        }
        .padding(ZAZUSpacing.large)
    }

    // MARK: - Loading

    private func reloadCards() async {
        isSwipeStackReady = false

        await viewModel.load()

        swipeMatches = viewModel.matches
        selectedMatch = swipeMatches.first

        isSwipeStackReady = true
    }

    private func selectJob(
        _ job: Job
    ) async {
        isSwipeStackReady = false

        await viewModel.selectJob(job)

        swipeMatches = viewModel.matches
        selectedMatch = swipeMatches.first

        isSwipeStackReady = true
    }
}
