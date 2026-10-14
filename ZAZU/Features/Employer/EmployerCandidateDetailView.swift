//
//  EmployerCandidateDetailView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 08.10.2026.
//

import SwiftUI

struct EmployerCandidateDetailView: View {
    let match: EmployerCandidateMatch
    let skills: [Skill]
    let languages: [Language]
    let candidateContact: CandidateContact?

    private var result: MatchResult {
        match.matchResult
    }
    
    init(
        match: EmployerCandidateMatch,
        skills: [Skill],
        languages: [Language],
        candidateContact: CandidateContact? = nil
    ) {
        self.match = match
        self.skills = skills
        self.languages = languages
        self.candidateContact = candidateContact
    }

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.large
            ) {
                header

                scoreCard

                compatibilitySection

                criteriaSection(
                    title: "MUSS-Kriterien",
                    criteria: result.mustCriteria
                )

                criteriaSection(
                    title: "OPTIONAL-Kriterien",
                    criteria: result.optionalCriteria
                )
            }
            .padding(ZAZUSpacing.medium)
        }
        .background(
            ZAZUColors.veryLightPurple
                .ignoresSafeArea()
        )
        .navigationTitle("Kandidatenprofil")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
    private func displayTitle(
        for criterion: MatchCriterion
    ) -> String {
        switch criterion.type {
        case .skill:
            return skillName(from: criterion.id) ?? "Skill"

        case .language:
            return languageName(from: criterion.id) ?? "Sprache"

        default:
            return criterion.title
        }
    }

    private func skillName(
        from criterionId: String
    ) -> String? {
        let prefix = "skill-"

        guard criterionId.hasPrefix(prefix) else {
            return nil
        }

        let idString = String(
            criterionId.dropFirst(prefix.count)
        )

        guard let id = UUID(uuidString: idString) else {
            return nil
        }

        return skills.first {
            $0.id == id
        }?.name
    }

    private func languageName(
        from criterionId: String
    ) -> String? {
        let prefix = "language-"

        guard criterionId.hasPrefix(prefix) else {
            return nil
        }

        let idString = String(
            criterionId.dropFirst(prefix.count)
        )

        guard let id = UUID(uuidString: idString) else {
            return nil
        }

        return languages.first {
            $0.id == id
        }?.name
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: ZAZUSpacing.medium) {
            ZStack {
                Circle()
                    .fill(ZAZUColors.lightPurple)
                    .frame(width: 56, height: 56)

                Image(
                    systemName:
                        candidateContact == nil
                        ? "person.fill"
                        : "person.crop.circle.fill"
                )
                .font(.title2)
                .foregroundStyle(ZAZUColors.primary)
            }

            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.xSmall
            ) {
                if let candidateContact {
                    Text(
                        candidateContact.fullName.isEmpty
                        ? "Kandidatenprofil"
                        : candidateContact.fullName
                    )
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(ZAZUColors.textPrimary)

                    if let phoneNumber = candidateContact.phoneNumber,
                       !phoneNumber.isEmpty {
                        Label(
                            phoneNumber,
                            systemImage: "phone.fill"
                        )
                        .font(.caption)
                        .foregroundStyle(ZAZUColors.textSecondary)
                    }
                } else {
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
            }

            Spacer()
        }
    }

    // MARK: - Score

    private var scoreCard: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            HStack {
                VStack(alignment: .leading) {
                    Text("ZAZU Match")
                        .font(.caption)
                        .foregroundStyle(ZAZUColors.textSecondary)

                    Text("\(result.score)%")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(ZAZUColors.primary)
                }

                Spacer()

                Label(
                    result.fulfillsAllMustCriteria
                        ? "Alle MUSS erfüllt"
                        : "\(result.missingMustCriteria.count) MUSS fehlen",
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
        }
        .padding(ZAZUSpacing.medium)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: ZAZURadius.medium
            )
        )
    }

    // MARK: - Compatibility

    private var compatibilitySection: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            Text("Kompatibilität")
                .font(.headline)
                .foregroundStyle(ZAZUColors.textPrimary)

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
        .padding(ZAZUSpacing.medium)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: ZAZURadius.medium
            )
        )
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
                    .foregroundStyle(ZAZUColors.textSecondary)

                if let requirementDetail = criterion.requirementDetail {
                    Text(requirementDetail)
                        .font(.caption)
                        .foregroundStyle(ZAZUColors.textSecondary)
                }
            }

            Spacer()
        }
    }

    // MARK: - Criteria

    @ViewBuilder
    private func criteriaSection(
        title: String,
        criteria: [MatchCriterion]
    ) -> some View {
        if !criteria.isEmpty {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.medium
            ) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(ZAZUColors.textPrimary)

                ForEach(criteria) { criterion in
                    criterionRow(criterion)
                }
            }
            .padding(ZAZUSpacing.medium)
            .background(ZAZUColors.white)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: ZAZURadius.medium
                )
            )
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
                Text(displayTitle(for: criterion))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(ZAZUColors.textPrimary)

                if let requirementDetail = criterion.requirementDetail {
                    Text(requirementDetail)
                        .font(.caption)
                        .foregroundStyle(ZAZUColors.textSecondary)
                }

                Text(criterion.detail)
                    .font(.caption)
                    .foregroundStyle(ZAZUColors.textSecondary)
            }

            Spacer()
        }
    }
}
