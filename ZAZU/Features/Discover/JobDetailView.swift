//
//  JobDetailView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 30.09.2026.
//

import SwiftUI

struct JobDetailView: View {
    let job: Job
    let company: Company?
    let matchResult: MatchResult?
    let skillRequirements: [JobSkillRequirement]
    let languageRequirements: [JobLanguageRequirement]
    let educationRequirements: [JobEducationRequirement]
    let skillName: (UUID) -> String
    let languageName: (UUID) -> String
    

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.large
            ) {
                header

                if let matchResult {
                    matchSummary(matchResult)
                }

                jobInformation

                descriptionSection

                if !skillRequirements.isEmpty {
                    skillSection
                }

                if !languageRequirements.isEmpty {
                    languageSection
                }
                
                if !educationRequirements.isEmpty {
                    educationSection
                }

                if let matchResult {
                    matchDetails(matchResult)
                }
            }
            .padding(ZAZUSpacing.medium)
        }
        .background(ZAZUColors.veryLightPurple)
        .navigationTitle("Jobdetails")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var header: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            Text(job.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(ZAZUColors.textPrimary)

            if let company {
                NavigationLink {
                    CandidateCompanyDetailView(
                        company: company
                    )
                } label: {
                    HStack(spacing: ZAZUSpacing.xSmall) {
                        Text(company.name)
                            .font(.headline)

                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundStyle(ZAZUColors.primary)
                }
                .buttonStyle(.plain)
            }

            if let activityArea = job.activityArea {
                Text(activityArea)
                    .font(.subheadline)
                    .foregroundStyle(ZAZUColors.textSecondary)
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }
    
    
    // MARK: - Education

    private var educationSection: some View {
        sectionCard {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.medium
            ) {
                sectionTitle("Ausbildung & Qualifikationen")

                ForEach(educationRequirements) { requirement in
                    VStack(
                        alignment: .leading,
                        spacing: ZAZUSpacing.xSmall
                    ) {
                        requirementHeader(
                            title: requirement.degree,
                            type: requirement.requirementType
                        )

                        if let field = requirement.fieldOfStudy,
                           !field.isEmpty {
                            Text("Fachrichtung: \(field)")
                                .font(.caption)
                                .foregroundStyle(
                                    ZAZUColors.textSecondary
                                )
                        }
                    }
                }
            }
        }
    }

    // MARK: - Match

    private func matchSummary(
        _ result: MatchResult
    ) -> some View {
        sectionCard {
            HStack {
                VStack(
                    alignment: .leading,
                    spacing: ZAZUSpacing.xSmall
                ) {
                    Text("Dein ZAZU Match")
                        .font(.subheadline)
                        .foregroundStyle(
                            ZAZUColors.textSecondary
                        )

                    Text("\(result.score) %")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            ZAZUColors.primary
                        )
                }

                Spacer()

                VStack {
                    Image(
                        systemName:
                            result.fulfillsAllMustCriteria
                            ? "checkmark.circle.fill"
                            : "exclamationmark.circle.fill"
                    )
                    .font(.largeTitle)
                    .foregroundStyle(
                        result.fulfillsAllMustCriteria
                        ? ZAZUColors.success
                        : ZAZUColors.danger
                    )

                    Text(
                        result.fulfillsAllMustCriteria
                        ? "Passt"
                        : "Details ansehen"
                    )
                    .font(.caption)
                }
            }
        }
    }

    @ViewBuilder
    private func criteriaSection(
        title: String,
        criteria: [MatchCriterion]
    ) -> some View {
        if !criteria.isEmpty {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.small
            ) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(ZAZUColors.textPrimary)

                ForEach(criteria) { criterion in
                    criterionRow(criterion)
                }
            }
        }
    }

    private func criterionRow(
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
                .fontWeight(.semibold)
                .foregroundStyle(ZAZUColors.textPrimary)

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

    private func compatibilityRow(
        title: String,
        criterion: MatchCriterion
    ) -> some View {
        HStack(
            alignment: .top,
            spacing: ZAZUSpacing.small
        ) {
            Image(
                systemName:
                    criterion.isFulfilled
                    ? "checkmark.circle.fill"
                    : "minus.circle.fill"
            )
            .foregroundStyle(
                criterion.isFulfilled
                    ? ZAZUColors.success
                    : ZAZUColors.textSecondary
            )

            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.xSmall
            ) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(ZAZUColors.textPrimary)

                Text(criterion.detail)
                    .font(.caption)
                    .foregroundStyle(
                        ZAZUColors.textSecondary
                    )

                if let requirementDetail =
                    criterion.requirementDetail {

                    Text(requirementDetail)
                        .font(.caption)
                        .foregroundStyle(
                            ZAZUColors.textSecondary
                        )
                }
            }

            Spacer()

            Text(
                criterion.isFulfilled
                    ? "Passt"
                    : "Abweichung"
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

    // MARK: - Job Information

    private var jobInformation: some View {
        sectionCard {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.medium
            ) {
                sectionTitle("Stelle")

                infoRow(
                    icon: "mappin.and.ellipse",
                    title: "Standort",
                    value: job.location
                )

                infoRow(
                    icon: "building.2",
                    title: "Arbeitsmodell",
                    value: job.workModel.title
                )

                infoRow(
                    icon: "percent",
                    title: "Pensum",
                    value:
                        "\(job.workloadMin)–\(job.workloadMax) %"
                )

                if let salary = salaryText {
                    infoRow(
                        icon: "banknote",
                        title: "Lohnband",
                        value: salary
                    )
                }

                if let startDate = job.earliestStartDate {
                    infoRow(
                        icon: "calendar",
                        title: "Eintritt",
                        value: startDate
                    )
                }

                if let years =
                    job.requiredWorkExperienceYears {

                    infoRow(
                        icon: "briefcase",
                        title: "Berufserfahrung",
                        value: experienceText(
                            years: years,
                            type:
                                job.workExperienceRequirementType
                        )
                    )
                }

                infoRow(
                    icon: "house",
                    title: "Homeoffice",
                    value: homeofficeText
                )
            }
        }
    }

    // MARK: - Description

    private var descriptionSection: some View {
        sectionCard {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.small
            ) {
                sectionTitle("Über die Stelle")

                Text(job.description)
                    .font(.body)
                    .foregroundStyle(ZAZUColors.textPrimary)
            }
        }
    }

    // MARK: - Skills

    private var skillSection: some View {
        sectionCard {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.medium
            ) {
                sectionTitle("Skills & Systeme")

                ForEach(
                    skillRequirements,
                    id: \.skillId
                ) { requirement in
                    VStack(
                        alignment: .leading,
                        spacing: ZAZUSpacing.xSmall
                    ) {
                        requirementHeader(
                            title:
                                skillName(
                                    requirement.skillId
                                ),
                            type:
                                requirement.requirementType
                        )

                        Text(
                            "Mindestlevel: \(requirement.minimumProficiency.title)"
                        )
                        .font(.caption)
                        .foregroundStyle(
                            ZAZUColors.textSecondary
                        )
                    }
                }
            }
        }
    }

    // MARK: - Languages

    private var languageSection: some View {
        sectionCard {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.medium
            ) {
                sectionTitle("Sprachen")

                ForEach(
                    languageRequirements,
                    id: \.languageId
                ) { requirement in
                    VStack(
                        alignment: .leading,
                        spacing: ZAZUSpacing.xSmall
                    ) {
                        requirementHeader(
                            title:
                                languageName(
                                    requirement.languageId
                                ),
                            type:
                                requirement.requirementType
                        )

                        Text(
                            "Mindestlevel: \(requirement.minimumProficiency.title)"
                        )
                        .font(.caption)
                        .foregroundStyle(
                            ZAZUColors.textSecondary
                        )
                    }
                }
            }
        }
    }
    
    
    private func matchDetails(
        _ result: MatchResult
    ) -> some View {
        sectionCard {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.medium
            ) {
                sectionTitle("Dein Match im Detail")

                Divider()

                Text(
                    result.fulfillsAllMustCriteria
                    ? "Alle MUSS-Kriterien erfüllt"
                    : "\(result.missingMustCriteria.count) MUSS-Kriterien nicht erfüllt"
                )
                .font(.headline)
                .foregroundStyle(
                    result.fulfillsAllMustCriteria
                    ? ZAZUColors.success
                    : ZAZUColors.danger
                )

                criteriaSection(
                    title: "MUSS-Kriterien",
                    criteria: result.mustCriteria
                )

                criteriaSection(
                    title: "OPTIONAL-Kriterien",
                    criteria: result.optionalCriteria
                )

                Divider()

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
            }
        }
    }

    // MARK: - Components

    private func requirementHeader(
        title: String,
        type: RequirementType
    ) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(ZAZUColors.textPrimary)

            Spacer()

            Text(type.title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(
                    type == .must
                        ? ZAZUColors.primary
                        : ZAZUColors.textSecondary
                )
                .padding(
                    .horizontal,
                    ZAZUSpacing.small
                )
                .padding(
                    .vertical,
                    ZAZUSpacing.xSmall
                )
                .background(
                    type == .must
                        ? ZAZUColors.lightPurple
                        : ZAZUColors.veryLightPurple
                )
                .clipShape(Capsule())
        }
    }

    private func infoRow(
        icon: String,
        title: String,
        value: String
    ) -> some View {
        HStack(
            alignment: .top,
            spacing: ZAZUSpacing.medium
        ) {
            Image(systemName: icon)
                .foregroundStyle(ZAZUColors.primary)
                .frame(width: 24)

            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.xSmall
            ) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(
                        ZAZUColors.textSecondary
                    )

                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(
                        ZAZUColors.textPrimary
                    )
            }
        }
    }

    private func sectionTitle(
        _ title: String
    ) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(ZAZUColors.textPrimary)
    }

    private func sectionCard<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(ZAZUSpacing.medium)
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
            .shadow(
                color: .black.opacity(0.04),
                radius: 8,
                y: 3
            )
    }

    // MARK: - Helpers

    private var salaryText: String? {
        guard
            let minimum = job.salaryMin,
            let maximum = job.salaryMax
        else {
            return nil
        }

        return
            "\(formatSalary(minimum))–\(formatSalary(maximum))"
    }

    private func formatSalary(
        _ value: Int
    ) -> String {
        value.formatted(
            .currency(code: "CHF")
                .precision(.fractionLength(0))
        )
    }

    private func experienceText(
        years: Int,
        type: RequirementType
    ) -> String {
        let yearsText =
            years == 1
            ? "1 Jahr"
            : "\(years) Jahre"

        return "Mindestens \(yearsText) · \(type.title)"
    }

    private var homeofficeText: String {
        guard job.homeofficeAvailable else {
            return "Nicht verfügbar"
        }

        if job.fullyRemoteAvailable {
            return "Remote möglich"
        }

        if let days = job.homeofficeDays {
            if let schedule = job.homeofficeSchedule {
                return "\(days) Tage/Woche · \(schedule.title)"
            }

            return "\(days) Tage/Woche"
        }

        return "Verfügbar"
    }

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

            return skillName(id)

        case .language:
            guard
                let id = requirementUUID(
                    from: criterion.id,
                    prefix: "language-"
                )
            else {
                return criterion.title
            }

            return languageName(id)

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
            criterionId.dropFirst(prefix.count)
        )

        return UUID(
            uuidString: value
        )
    }
}
