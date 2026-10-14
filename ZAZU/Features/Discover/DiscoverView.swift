//
//  DiscoverView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 29.09.2026.
//


// TODO: POC
// SwipeCardsKit popTrigger has an animation edge case
// on the first/last card.
// Revisit swipe implementation during UI polish.

import SwiftUI
import SwipeCardsKit

struct DiscoverView: View {
    @State private var viewModel: DiscoverViewModel

    @State private var isSwipeStackReady = false
    @State private var swipeJobs: [Job] = []
    @State private var selectedJob: Job?
    @State private var detailJob: Job?
    @State private var popTrigger: CardSwipeDirection?


    init(viewModel: DiscoverViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    loadingView
                } else if let errorMessage = viewModel.errorMessage {
                    errorView(errorMessage)
                } else if swipeJobs.isEmpty {
                    emptyView
                } else if isSwipeStackReady {
                    jobList
                } else {
                    loadingView
                }
            }
            .background(ZAZUColors.veryLightPurple)
            .navigationTitle("Entdecken")
            }
            .sheet(item: $detailJob) { job in
                NavigationStack {
                    JobDetailView(
                        job: job,
                        company: viewModel.company(for: job),
                        matchResult: viewModel.matchResult(for: job),
                        skillRequirements:
                            viewModel.skillRequirements(for: job),
                        languageRequirements:
                            viewModel.languageRequirements(for: job),
                        educationRequirements:
                            viewModel.educationRequirements(for: job),
                        skillName: { skillId in
                            viewModel.skillName(for: skillId)
                        },
                        languageName: { languageId in
                            viewModel.languageName(for: languageId)
                        }
                    )
                }
            }
            .fullScreenCover(
                item: $viewModel.mutualMatchJob
            ) { job in
                JobMatchCelebrationView(
                    job: job,
                    company: viewModel.company(for: job),
                    onContinue: {
                        viewModel.mutualMatchJob = nil
                        viewModel.mutualMatchId = nil
                    }
                )
            }
            .onAppear {
            Task {
                await reloadCards()
            }
        }
    }

    // MARK: - Swipe Stack

    private var jobList: some View {
        VStack(spacing: ZAZUSpacing.medium) {
            CardSwipeView(
                items: $swipeJobs,
                selectedItem: $selectedJob,
                popTrigger: $popTrigger
            ) { job, progress, direction in
                ZStack {
                    compactJobCard(job)

                    swipeOverlay(
                        progress: progress,
                        direction: direction
                    )
                }
                .frame(maxHeight: .infinity)
                .padding(.horizontal, ZAZUSpacing.medium)
                .contentShape(Rectangle())
                .onTapGesture {
                    detailJob = job
                }
            }
            .configure(
                threshold: 140,
                minimumDistance: 20,
                animateOnYAxes: false
            )
            .onSwipeEnd { job, direction in
                handleGestureSwipe(
                    job: job,
                    direction: direction
                )
            }
            .onThresholdPassed {
                UIImpactFeedbackGenerator(
                    style: .medium
                ).impactOccurred()
            }

            swipeButtons
        }
        .padding(.vertical, ZAZUSpacing.medium)
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

    // MARK: - Swipe Buttons

    private var swipeButtons: some View {
        HStack(spacing: ZAZUSpacing.xLarge) {
            Button {
                triggerButtonSwipe(.left)
            }
            label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        ZAZUColors.textSecondary
                    )
                    .frame(
                        width: 58,
                        height: 58
                    )
                    .background(
                        ZAZUColors.white
                    )
                    .clipShape(Circle())
                    .shadow(
                        color: .black.opacity(0.08),
                        radius: 8,
                        y: 4
                    )
            }
            .disabled(viewModel.isDeciding)

            Button {
                triggerButtonSwipe(.right)
            } label: {
                Image(systemName: "heart.fill")
                    .font(.title2)
                    .foregroundStyle(
                        ZAZUColors.white
                    )
                    .frame(
                        width: 64,
                        height: 64
                    )
                    .background(
                        ZAZUColors.primary
                    )
                    .clipShape(Circle())
                    .shadow(
                        color: ZAZUColors.primary.opacity(0.25),
                        radius: 10,
                        y: 5
                    )
            }
            .disabled(viewModel.isDeciding)
        }
    }

    // MARK: - Button Swipe

    private func triggerButtonSwipe(
        _ direction: CardSwipeDirection
    ) {
        guard
            !viewModel.isDeciding,
            let job = swipeJobs.first
        else {
            return
        }

        let decision: CandidateJobDecision

        switch direction {
        case .left:
            decision = .pass

        case .right:
            decision = .match

        case .idle:
            return
        }

        UIImpactFeedbackGenerator(
            style: .medium
        ).impactOccurred()

        // SwipeCardsKit animiert und entfernt die Karte.
        // Bei programmatic swipes ruft die Library
        // onSwipeEnd absichtlich NICHT auf.
        popTrigger = direction

        // Deshalb persistieren wir Button-Entscheidungen
        // hier separat.
        Task {
            let wasSaved = await viewModel.decide(
                on: job,
                decision: decision
            )

            if !wasSaved {
                await reloadCards()
            }
        }
    }

    // MARK: - Gesture Swipe

    private func handleGestureSwipe(
        job: Job,
        direction: CardSwipeDirection
    ) {
        
        guard !viewModel.isDeciding else {
            Task {
                await reloadCards()
            }
            return
        }
        
        let decision: CandidateJobDecision

        switch direction {
        case .left:
            decision = .pass

        case .right:
            decision = .match

        case .idle:
            return
        }

        Task {
            let wasSaved = await viewModel.decide(
                on: job,
                decision: decision
            )

            if !wasSaved {
                await reloadCards()
            }
        }
    }

    // MARK: - Compact Swipe Card

    private func compactJobCard(
        _ job: Job
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            if let result = viewModel.matchResult(for: job) {
                HStack {
                    Text("ZAZU Match")
                        .font(.caption)
                        .foregroundStyle(
                            ZAZUColors.textSecondary
                        )

                    Spacer()

                    Text("\(result.score) %")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            ZAZUColors.primary
                        )
                }
            }

            Spacer()

            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.small
            ) {
                Text(job.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        ZAZUColors.textPrimary
                    )

                if let company = viewModel.company(for: job) {
                    Text(company.name)
                        .font(.headline)
                        .foregroundStyle(
                            ZAZUColors.primary
                        )
                }
            }

            Divider()

            Label(
                job.location,
                systemImage: "mappin.and.ellipse"
            )

            Label(
                "\(job.workloadMin)–\(job.workloadMax) %",
                systemImage: "percent"
            )

            Label(
                job.workModel.title,
                systemImage: "building.2"
            )

            if let salary = salaryText(for: job) {
                Label(
                    salary,
                    systemImage: "banknote"
                )
            }

            if let result = viewModel.matchResult(for: job) {
                Divider()

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

            HStack {
                Spacer()

                Text("Tippen für Details")
                    .font(.caption)
                    .foregroundStyle(
                        ZAZUColors.textSecondary
                    )

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(
                        ZAZUColors.textSecondary
                    )
            }
        }
        .font(.subheadline)
        .foregroundStyle(
            ZAZUColors.textSecondary
        )
        .padding(ZAZUSpacing.large)
        .frame(
            maxWidth: .infinity,
            minHeight: 430,
            maxHeight: 520,
            alignment: .leading
        )
        .background(
            ZAZUColors.white
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: ZAZURadius.large
            )
        )
        .shadow(
            color: .black.opacity(0.08),
            radius: 14,
            y: 6
        )
    }

    // MARK: - Job Card

    private func jobCard(
        _ job: Job
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.xSmall
            ) {
                Text(job.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        ZAZUColors.textPrimary
                    )

                if let company = viewModel.company(for: job) {
                    Text(company.name)
                        .foregroundStyle(
                            ZAZUColors.primary
                        )
                }
            }

            HStack {
                Label(
                    job.location,
                    systemImage: "mappin.and.ellipse"
                )

                Spacer()

                Text(job.workModel.title)
            }
            .font(.subheadline)
            .foregroundStyle(
                ZAZUColors.textSecondary
            )

            HStack {
                Label(
                    "\(job.workloadMin)–\(job.workloadMax) %",
                    systemImage: "percent"
                )

                Spacer()

                if let salary = salaryText(for: job) {
                    Text(salary)
                }
            }
            .font(.subheadline)
            .foregroundStyle(
                ZAZUColors.textSecondary
            )

            let skillCount =
                viewModel.skillRequirements(for: job).count

            let languageCount =
                viewModel.languageRequirements(for: job).count

            Text(
                "\(skillCount) Skill-Anforderungen · \(languageCount) Sprach-Anforderungen"
            )
            .font(.caption)
            .foregroundStyle(
                ZAZUColors.textSecondary
            )

            if let result = viewModel.matchResult(for: job) {
                Divider()

                matchSummary(result)
            }
        }
        .padding(ZAZUSpacing.large)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            ZAZUColors.white
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: ZAZURadius.large
            )
        )
    }

    // MARK: - Match Summary

    @ViewBuilder
    private func matchSummary(
        _ result: MatchResult
    ) -> some View {
        HStack {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.xSmall
            ) {
                Text("ZAZU Match")
                    .font(.caption)
                    .foregroundStyle(
                        ZAZUColors.textSecondary
                    )

                Text("\(result.score) %")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        ZAZUColors.primary
                    )
            }

            Spacer()

            ZStack {
                Circle()
                    .stroke(
                        ZAZUColors.lightPurple,
                        lineWidth: 6
                    )

                Circle()
                    .trim(
                        from: 0,
                        to: Double(result.score) / 100
                    )
                    .stroke(
                        ZAZUColors.primary,
                        style: StrokeStyle(
                            lineWidth: 6,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(
                        .degrees(-90)
                    )

                Text("\(result.score)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        ZAZUColors.textPrimary
                    )
            }
            .frame(
                width: 54,
                height: 54
            )
        }
        .padding(
            .bottom,
            ZAZUSpacing.small
        )

        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            HStack(
                spacing: ZAZUSpacing.small
            ) {
                Image(
                    systemName:
                        result.fulfillsAllMustCriteria
                        ? "checkmark.circle.fill"
                        : "exclamationmark.circle.fill"
                )

                Text(
                    result.fulfillsAllMustCriteria
                        ? "Alle MUSS-Kriterien erfüllt"
                        : "\(result.missingMustCriteria.count) MUSS-Kriterien fehlen"
                )
                .font(.caption)
                .fontWeight(.semibold)
            }
            .foregroundStyle(
                result.fulfillsAllMustCriteria
                    ? ZAZUColors.success
                    : ZAZUColors.danger
            )

            compatibilityRow(
                title: "Lohn",
                criterion: result.salaryCompatibility
            )

            compatibilityRow(
                title: "Arbeitsmodell",
                criterion: result.workModelCompatibility
            )

            compatibilityRow(
                title: "Homeoffice",
                criterion: result.homeofficeCompatibility
            )

            if !result.optionalCriteria.isEmpty {
                let fulfilled =
                    result.fulfilledOptionalCriteria.count

                let total =
                    result.optionalCriteria.count

                Text(
                    "\(fulfilled) von \(total) OPTIONAL-Kriterien erfüllt"
                )
                .font(.caption)
                .foregroundStyle(
                    ZAZUColors.textSecondary
                )
            }

            requirementDetails(
                for: result
            )
        }
    }

    // MARK: - Requirement Details

    @ViewBuilder
    private func requirementDetails(
        for result: MatchResult
    ) -> some View {
        if !result.mustCriteria.isEmpty {
            requirementSection(
                title: "MUSS",
                criteria: result.mustCriteria
            )
        }

        if !result.optionalCriteria.isEmpty {
            requirementSection(
                title: "OPTIONAL",
                criteria: result.optionalCriteria
            )
        }
    }

    private func requirementSection(
        title: String,
        criteria: [MatchCriterion]
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(
                    ZAZUColors.textSecondary
                )

            ForEach(criteria) { criterion in
                requirementRow(
                    criterion
                )
            }
        }
        .padding(
            .top,
            ZAZUSpacing.small
        )
    }

    private func requirementRow(
        _ criterion: MatchCriterion
    ) -> some View {
        HStack(
            alignment: .top,
            spacing: ZAZUSpacing.small
        ) {
            Image(
                systemName:
                    criterion.isFulfilled
                    ? "checkmark.circle.fill"
                    : "xmark.circle.fill"
            )
            .foregroundStyle(
                criterion.isFulfilled
                    ? ZAZUColors.success
                    : ZAZUColors.danger
            )

            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.xSmall
            ) {
                Text(
                    requirementTitle(
                        for: criterion
                    )
                )
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(
                    ZAZUColors.textPrimary
                )

                if let requirementDetail =
                    criterion.requirementDetail {

                    Text(requirementDetail)
                        .font(.caption)
                        .foregroundStyle(
                            ZAZUColors.textSecondary
                        )
                }

                Text(criterion.detail)
                    .font(.caption)
                    .foregroundStyle(
                        ZAZUColors.textSecondary
                    )
            }
        }
    }

    // MARK: - Requirement Titles

    private func requirementTitle(
        for criterion: MatchCriterion
    ) -> String {
        switch criterion.type {
        case .skill:
            guard
                let id = requirementUUID(
                    from: criterion.id,
                    prefix: "skill-"
                )
            else {
                return criterion.title
            }

            return viewModel.skillName(
                for: id
            )

        case .language:
            guard
                let id = requirementUUID(
                    from: criterion.id,
                    prefix: "language-"
                )
            else {
                return criterion.title
            }

            return viewModel.languageName(
                for: id
            )

        default:
            return criterion.title
        }
    }

    private func requirementUUID(
        from criterionId: String,
        prefix: String
    ) -> UUID? {
        guard criterionId.hasPrefix(prefix) else {
            return nil
        }

        let value = String(
            criterionId.dropFirst(
                prefix.count
            )
        )

        return UUID(
            uuidString: value
        )
    }

    // MARK: - Compatibility

    private func compatibilityRow(
        title: String,
        criterion: MatchCriterion
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.xSmall
        ) {
            HStack(
                spacing: ZAZUSpacing.small
            ) {
                Image(
                    systemName:
                        criterion.isFulfilled
                        ? "checkmark.circle"
                        : "minus.circle"
                )

                Text(title)

                Spacer()

                Text(
                    criterion.isFulfilled
                        ? "Passt"
                        : "Abweichung"
                )
            }

            Text(criterion.detail)
                .padding(
                    .leading,
                    ZAZUSpacing.large
                )
                .foregroundStyle(
                    ZAZUColors.textSecondary
                )

            if let requirementDetail =
                criterion.requirementDetail {

                Text(requirementDetail)
                    .padding(
                        .leading,
                        ZAZUSpacing.large
                    )
                    .foregroundStyle(
                        ZAZUColors.textSecondary
                    )
            }
        }
        .font(.caption)
        .foregroundStyle(
            criterion.isFulfilled
                ? ZAZUColors.textPrimary
                : ZAZUColors.textSecondary
        )
    }

    // MARK: - State Views

    private var loadingView: some View {
        ProgressView(
            "Jobs werden geladen …"
        )
        .tint(
            ZAZUColors.primary
        )
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }

    private var emptyView: some View {
        ContentUnavailableView(
            "Keine Jobs verfügbar",
            systemImage: "briefcase",
            description: Text(
                "Du hast aktuell alle verfügbaren Stellen bewertet."
            )
        )
    }

    private func errorView(
        _ message: String
    ) -> some View {
        ContentUnavailableView {
            Label(
                "Jobs konnten nicht geladen werden",
                systemImage:
                    "exclamationmark.triangle"
            )
        } description: {
            Text(message)
        } actions: {
            Button(
                "Erneut versuchen"
            ) {
                Task {
                    await reloadCards()
                }
            }
            .buttonStyle(
                .borderedProminent
            )
            .tint(
                ZAZUColors.primary
            )
        }
    }

    // MARK: - Salary

    private func salaryText(
        for job: Job
    ) -> String? {
        guard
            let minimum = job.salaryMin,
            let maximum = job.salaryMax
        else {
            return nil
        }

        return "\(formatSalary(minimum))–\(formatSalary(maximum))"
    }

    private func formatSalary(
        _ value: Int
    ) -> String {
        value.formatted(
            .currency(
                code: "CHF"
            )
            .precision(
                .fractionLength(0)
            )
        )
    }

    // MARK: - Reload

    private func reloadCards() async {
        isSwipeStackReady = false

        await viewModel.load()

        swipeJobs = viewModel.jobs
        selectedJob = swipeJobs.first

        isSwipeStackReady = true
    }
}
