import SwiftUI

struct InterviewSelectionView: View {
    @State private var viewModel: InterviewSelectionViewModel

    let job: Job
    let company: Company?
    let matchResult: MatchResult?
    let skillRequirements: [JobSkillRequirement]
    let languageRequirements: [JobLanguageRequirement]
    let educationRequirements: [JobEducationRequirement]
    let skillName: (UUID) -> String
    let languageName: (UUID) -> String

    init(
        viewModel: InterviewSelectionViewModel,
        job: Job,
        company: Company?,
        matchResult: MatchResult?,
        skillRequirements: [JobSkillRequirement],
        languageRequirements: [JobLanguageRequirement],
        educationRequirements: [JobEducationRequirement],
        skillName: @escaping (UUID) -> String,
        languageName: @escaping (UUID) -> String
    ) {
        _viewModel = State(initialValue: viewModel)
        self.job = job
        self.company = company
        self.matchResult = matchResult
        self.skillRequirements = skillRequirements
        self.languageRequirements = languageRequirements
        self.educationRequirements = educationRequirements
        self.skillName = skillName
        self.languageName = languageName
    }

    var body: some View {
        ZStack {
            ZAZUColors.veryLightPurple
                .ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView("Termine werden geladen …")
                    .tint(ZAZUColors.primary)
            } else if let errorMessage = viewModel.errorMessage,
                      viewModel.slots.isEmpty {
                errorView(errorMessage)
            } else {
                content
            }
        }
        .navigationTitle("Interview")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
    }

    private var content: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.large
            ) {
                header

                if let selectedSlot = viewModel.selectedSlot {
                    confirmedView(selectedSlot)
                } else if viewModel.slots.isEmpty {
                    emptyView
                } else {
                    slotSelection
                }
            }
            .padding(ZAZUSpacing.large)
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            Label(
                "IT’S A JOB MATCH!",
                systemImage: "heart.fill"
            )
            .font(.caption)
            .fontWeight(.bold)
            .foregroundStyle(ZAZUColors.primary)

            Text(job.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(ZAZUColors.textPrimary)

            if let company {
                Text(company.name)
                    .font(.headline)
                    .foregroundStyle(ZAZUColors.textSecondary)
            }
            
            
            NavigationLink {
                JobDetailView(
                    job: job,
                    company: company,
                    matchResult: matchResult,
                    skillRequirements: skillRequirements,
                    languageRequirements: languageRequirements,
                    educationRequirements: educationRequirements,
                    skillName: skillName,
                    languageName: languageName
                )
            } label: {
                Label(
                    "Job ansehen",
                    systemImage: "briefcase.fill"
                )
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(ZAZUColors.primary)
                .padding(.top, ZAZUSpacing.small)
            }
            .buttonStyle(.plain)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }

    // MARK: - Selection

    private var slotSelection: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.xSmall
            ) {
                Text("Interviewtermin auswählen")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(ZAZUColors.textPrimary)

                Text(
                    "Wähle einen der vorgeschlagenen Termine."
                )
                .foregroundStyle(ZAZUColors.textSecondary)
            }

            ForEach(viewModel.slots) { slot in
                slotButton(slot)
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(ZAZUColors.danger)
            }
        }
    }

    private func slotButton(
        _ slot: InterviewSlot
    ) -> some View {
        Button {
            Task {
                _ = await viewModel.select(slot)
            }
        } label: {
            HStack(spacing: ZAZUSpacing.medium) {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundStyle(ZAZUColors.primary)

                VStack(
                    alignment: .leading,
                    spacing: ZAZUSpacing.xSmall
                ) {
                    Text(
                        slot.startsAt,
                        format: .dateTime
                            .weekday(.wide)
                            .day()
                            .month(.wide)
                    )
                    .fontWeight(.semibold)
                    .foregroundStyle(ZAZUColors.textPrimary)

                    Text(
                        "\(slot.startsAt.formatted(date: .omitted, time: .shortened)) – \(slot.endsAt.formatted(date: .omitted, time: .shortened)) Uhr"
                    )
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
        .buttonStyle(.plain)
        .disabled(viewModel.isConfirming)
    }

    // MARK: - Confirmed

    private func confirmedView(
        _ slot: InterviewSlot
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            Label(
                "Interview bestätigt",
                systemImage: "checkmark.circle.fill"
            )
            .font(.title3)
            .fontWeight(.bold)
            .foregroundStyle(ZAZUColors.success)

            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.small
            ) {
                Text(
                    slot.startsAt,
                    format: .dateTime
                        .weekday(.wide)
                        .day()
                        .month(.wide)
                        .year()
                )
                .font(.headline)
                .foregroundStyle(ZAZUColors.textPrimary)

                Text(
                    "\(slot.startsAt.formatted(date: .omitted, time: .shortened)) – \(slot.endsAt.formatted(date: .omitted, time: .shortened)) Uhr"
                )
                .foregroundStyle(ZAZUColors.textSecondary)
            }
            .padding(ZAZUSpacing.large)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .background(ZAZUColors.white)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: ZAZURadius.medium
                )
            )
        }
    }

    // MARK: - States

    private var emptyView: some View {
        ContentUnavailableView(
            "Keine Termine verfügbar",
            systemImage: "calendar.badge.exclamationmark",
            description: Text(
                "Aktuell wurden noch keine Interviewtermine vorgeschlagen."
            )
        )
    }

    private func errorView(
        _ message: String
    ) -> some View {
        ContentUnavailableView {
            Label(
                "Termine konnten nicht geladen werden",
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
