//
//  OnboardingSummaryView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import SwiftUI

struct OnboardingSummaryView: View {
    @State private var viewModel: OnboardingSummaryViewModel

    let onComplete: () -> Void

    init(
        viewModel: OnboardingSummaryViewModel,
        onComplete: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onComplete = onComplete
    }

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.large
            ) {
                progressHeader
                title

                if viewModel.isLoading {
                    loadingView
                } else if let profile = viewModel.profile {
                    basicInformationSection(profile)
                    workExperienceSection
                    skillsSection
                    educationSection
                    languagesSection
                    jobPreferencesSection(profile)
                    workAndSalarySection(profile)
                    errorMessage
                    finishPlaceholder
                } else {
                    errorMessage
                }
            }
            .padding(ZAZUSpacing.large)
        }
        .background(ZAZUColors.veryLightPurple)
        .task {
            await viewModel.load()
        }
    }

    // MARK: - Header

    private var progressHeader: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            HStack {
                Text("Profil erstellen")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(ZAZUColors.primary)

                Spacer()

                Text("8 von 8")
                    .font(.subheadline)
                    .foregroundStyle(ZAZUColors.textSecondary)
            }

            ProgressView(value: 8, total: 8)
                .tint(ZAZUColors.primary)
        }
    }

    private var title: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            Text("Dein Profil")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(ZAZUColors.textPrimary)

            Text(
                "Prüfe deine Angaben, bevor wir dein Profil für das Job-Matching verwenden."
            )
            .foregroundStyle(ZAZUColors.textSecondary)
        }
    }

    // MARK: - Basic Information

    private func basicInformationSection(
        _ profile: CandidateProfile
    ) -> some View {
        
        summaryCard(
            
            title: "Basisinformationen",
            systemImage: "person"
        ) {
            if let accountProfile = viewModel.accountProfile {
                let fullName = [
                    accountProfile.firstName,
                    accountProfile.lastName
                ]
                .compactMap { $0 }
                .filter { !$0.isEmpty }
                .joined(separator: " ")

                summaryRow(
                    title: "Name",
                    value: fullName.isEmpty
                        ? "Nicht angegeben"
                        : fullName
                )
            }
            summaryRow(
                title: "Region",
                value: profile.region ?? "Nicht angegeben"
            )

            summaryRow(
                title: "Staatsangehörigkeit",
                value: profile.nationality ?? "Nicht angegeben"
            )

            summaryRow(
                title: "Arbeitsberechtigung",
                value: yesNo(
                    profile.hasWorkAuthorization
                )
            )

            if let details = profile.workAuthorizationDetails,
               !details.isEmpty {
                summaryRow(
                    title: "Bewilligung",
                    value: details
                )
            }

            
        }
    }

    // MARK: - Work Experience

    private var workExperienceSection: some View {
        summaryCard(
            title: "Berufserfahrung",
            systemImage: "briefcase"
        ) {
            if viewModel.workExperiences.isEmpty {
                emptyText("Keine Berufserfahrung eingetragen")
            } else {
                ForEach(viewModel.workExperiences) { experience in
                    VStack(
                        alignment: .leading,
                        spacing: ZAZUSpacing.xSmall
                    ) {
                        Text(experience.jobTitle)
                            .fontWeight(.semibold)
                            .foregroundStyle(
                                ZAZUColors.textPrimary
                            )

                        Text(experience.employerName)
                            .foregroundStyle(
                                ZAZUColors.textSecondary
                            )

                        Text(workExperiencePeriod(experience))
                            .font(.caption)
                            .foregroundStyle(
                                ZAZUColors.textSecondary
                            )
                    }

                    if experience.id !=
                        viewModel.workExperiences.last?.id {
                        Divider()
                    }
                }
            }
        }
    }

    // MARK: - Skills

    private var skillsSection: some View {
        summaryCard(
            title: "Skills & Systemkenntnisse",
            systemImage: "hammer"
        ) {
            if viewModel.selectedSkills.isEmpty {
                emptyText("Keine Skills ausgewählt")
            } else {
                ForEach(
                    viewModel.selectedSkills,
                    id: \.skill.id
                ) { item in
                    summaryRow(
                        title: item.skill.name,
                        value: item.proficiency.title
                    )
                }
            }
        }
    }

    // MARK: - Education

    private var educationSection: some View {
        summaryCard(
            title: "Ausbildung & Qualifikationen",
            systemImage: "graduationcap"
        ) {
            if viewModel.educations.isEmpty {
                emptyText(
                    "Keine Ausbildung oder Qualifikation eingetragen"
                )
            } else {
                ForEach(viewModel.educations) { education in
                    VStack(
                        alignment: .leading,
                        spacing: ZAZUSpacing.xSmall
                    ) {
                        Text(education.degree)
                            .fontWeight(.semibold)
                            .foregroundStyle(
                                ZAZUColors.textPrimary
                            )

                        Text(education.institutionName)
                            .foregroundStyle(
                                ZAZUColors.textSecondary
                            )

                        if let field = education.fieldOfStudy {
                            Text(field)
                                .font(.subheadline)
                                .foregroundStyle(
                                    ZAZUColors.textSecondary
                                )
                        }

                        Text(educationPeriod(education))
                            .font(.caption)
                            .foregroundStyle(
                                ZAZUColors.textSecondary
                            )
                    }

                    if education.id !=
                        viewModel.educations.last?.id {
                        Divider()
                    }
                }
            }
        }
    }

    // MARK: - Languages

    private var languagesSection: some View {
        summaryCard(
            title: "Sprachen",
            systemImage: "globe"
        ) {
            if viewModel.selectedLanguages.isEmpty {
                emptyText("Keine Sprachen ausgewählt")
            } else {
                ForEach(
                    viewModel.selectedLanguages,
                    id: \.language.id
                ) { item in
                    summaryRow(
                        title: item.language.name,
                        value: item.proficiency.title
                    )
                }
            }
        }
    }

    // MARK: - Job Preferences

    private func jobPreferencesSection(
        _ profile: CandidateProfile
    ) -> some View {
        summaryCard(
            title: "Jobpräferenzen",
            systemImage: "slider.horizontal.3"
        ) {
            if let minimum = profile.desiredWorkloadMin,
               let maximum = profile.desiredWorkloadMax {
                summaryRow(
                    title: "Arbeitspensum",
                    value: "\(minimum)–\(maximum) %"
                )
            }

            summaryRow(
                title: "Arbeitsort",
                value:
                    profile.desiredWorkLocation
                    ?? "Nicht angegeben"
            )

            if let radius = profile.workRadiusKm {
                summaryRow(
                    title: "Arbeitsradius",
                    value: "\(radius) km"
                )
            }

            summaryRow(
                title: "Pendelbereit",
                value: yesNo(
                    profile.willingToCommute
                )
            )

            summaryRow(
                title: "Umzugsbereit",
                value: yesNo(
                    profile.willingToRelocate
                )
            )

            if let date = profile.earliestStartDate {
                summaryRow(
                    title: "Frühester Eintritt",
                    value: date
                )
            }
        }
    }

    // MARK: - Work & Salary

    private func workAndSalarySection(
        _ profile: CandidateProfile
    ) -> some View {
        summaryCard(
            title: "Arbeitsmodell & Lohn",
            systemImage: "banknote"
        ) {
            summaryRow(
                title: "Arbeitsmodell",
                value:
                    profile.preferredWorkModel?.title
                    ?? "Nicht angegeben"
            )

            summaryRow(
                title: "Homeoffice",
                value:
                    profile.homeofficePreference?.title
                    ?? "Nicht angegeben"
            )

            if profile.homeofficePreference != .no {
                if let days = profile.desiredHomeofficeDays {
                    summaryRow(
                        title: "Homeoffice-Tage",
                        value: "\(days) pro Woche"
                    )
                }

                summaryRow(
                    title: "Verteilung",
                    value:
                        profile
                            .preferredHomeofficeSchedule?
                            .title
                        ?? "Nicht angegeben"
                )

                summaryRow(
                    title: "Fully Remote möglich",
                    value: yesNo(
                        profile.acceptsFullyRemote
                    )
                )
            }

            if let minimum = profile.salaryMin,
               let maximum = profile.salaryMax {
                summaryRow(
                    title: "Lohnvorstellung",
                    value:
                        "\(formattedSalary(minimum)) – \(formattedSalary(maximum))"
                )
            }
        }
    }

    // MARK: - Finish

    private var finishPlaceholder: some View {
        VStack(spacing: ZAZUSpacing.small) {
            Button {
                Task {
                    let didComplete =
                        await viewModel.completeOnboarding()

                    if didComplete {
                        onComplete()
                    }
                }
            } label: {
                Group {
                    if viewModel.isCompleting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Profil erstellen")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .background(ZAZUColors.primary)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: ZAZURadius.medium
                )
            )
            .disabled(viewModel.isCompleting)

            Text(
                "Dein Profil wird anschließend für das Job-Matching vorbereitet."
            )
            .font(.footnote)
            .foregroundStyle(ZAZUColors.textSecondary)
            .multilineTextAlignment(.center)
        }
    }

    // MARK: - Components

    private func summaryCard<Content: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(ZAZUColors.textPrimary)

            Divider()

            content()
        }
        .padding(ZAZUSpacing.medium)
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
    }

    private func summaryRow(
        title: String,
        value: String
    ) -> some View {
        HStack(
            alignment: .top,
            spacing: ZAZUSpacing.medium
        ) {
            Text(title)
                .foregroundStyle(ZAZUColors.textSecondary)

            Spacer()

            Text(value)
                .foregroundStyle(ZAZUColors.textPrimary)
                .multilineTextAlignment(.trailing)
        }
    }

    private func emptyText(
        _ text: String
    ) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(ZAZUColors.textSecondary)
    }

    // MARK: - States

    private var loadingView: some View {
        ProgressView()
            .tint(ZAZUColors.primary)
            .frame(maxWidth: .infinity)
            .padding(ZAZUSpacing.xLarge)
    }

    @ViewBuilder
    private var errorMessage: some View {
        if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .font(.footnote)
                .foregroundStyle(.red)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
        }
    }

    // MARK: - Formatting

    private func yesNo(
        _ value: Bool?
    ) -> String {
        guard let value else {
            return "Nicht angegeben"
        }

        return value ? "Ja" : "Nein"
    }

    private func workExperiencePeriod(
        _ experience: WorkExperience
    ) -> String {
        if experience.isCurrent {
            return "\(experience.startDate) – heute"
        }

        if let endDate = experience.endDate {
            return "\(experience.startDate) – \(endDate)"
        }

        return experience.startDate
    }

    private func educationPeriod(
        _ education: Education
    ) -> String {
        switch (
            education.startDate,
            education.endDate,
            education.isCurrent
        ) {
        case let (.some(start), _, true):
            return "\(start) – heute"

        case let (.some(start), .some(end), false):
            return "\(start) – \(end)"

        case let (.some(start), nil, false):
            return "Seit \(start)"

        case let (nil, .some(end), false):
            return "Bis \(end)"

        default:
            return "Zeitraum nicht angegeben"
        }
    }

    private func formattedSalary(
        _ value: Int
    ) -> String {
        value.formatted(
            .currency(code: "CHF")
                .precision(.fractionLength(0))
        )
    }
}
