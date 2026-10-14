//
//  EmployerSkillRequirementsView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 07.10.2026.
//

import SwiftUI

struct EmployerSkillRequirementsView: View {
    @Bindable var jobViewModel: EmployerJobFormViewModel
    @State private var skillViewModel: EmployerSkillRequirementsViewModel

    init(
        jobViewModel: EmployerJobFormViewModel,
        skillRepository: SkillRepository
    ) {
        self.jobViewModel = jobViewModel

        _skillViewModel = State(
            initialValue: EmployerSkillRequirementsViewModel(
                skillRepository: skillRepository
            )
        )
    }

    var body: some View {
        Group {
            if skillViewModel.isLoading && skillViewModel.skills.isEmpty {
                ProgressView()
            } else if let errorMessage = skillViewModel.errorMessage {
                ContentUnavailableView(
                    "Skills konnten nicht geladen werden",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            } else {
                skillList
            }
        }
        .navigationTitle("Skills")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(
            text: $skillViewModel.searchText,
            prompt: "Skill oder System suchen"
        )
        .task {
            await skillViewModel.loadSkills()
        }
    }

    private var skillList: some View {
        List {
            if !jobViewModel.skillRequirements.isEmpty {
                Section("Ausgewählt") {
                    ForEach(jobViewModel.skillRequirements) { requirement in
                        selectedSkillRow(requirement)
                    }
                }
            }

            Section("Skills & Systemkenntnisse") {
                ForEach(skillViewModel.filteredSkills) { skill in
                    Button {
                        jobViewModel.toggleSkill(skill)
                    } label: {
                        HStack {
                            VStack(
                                alignment: .leading,
                                spacing: ZAZUSpacing.xSmall
                            ) {
                                Text(skill.name)
                                    .foregroundStyle(
                                        ZAZUColors.textPrimary
                                    )

                                Text(skill.category)
                                    .font(.caption)
                                    .foregroundStyle(
                                        ZAZUColors.textSecondary
                                    )
                            }

                            Spacer()

                            Image(
                                systemName:
                                    jobViewModel.isSkillSelected(skill)
                                    ? "checkmark.circle.fill"
                                    : "circle"
                            )
                            .foregroundStyle(
                                jobViewModel.isSkillSelected(skill)
                                ? ZAZUColors.primary
                                : ZAZUColors.textSecondary
                            )
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func selectedSkillRow(
        _ requirement: EmployerSkillRequirementDraft
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            HStack {
                Text(requirement.skill.name)
                    .font(.headline)

                Spacer()

                Button {
                    jobViewModel.toggleSkill(
                        requirement.skill
                    )
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(
                            ZAZUColors.textSecondary
                        )
                }
                .buttonStyle(.plain)
            }

            Picker(
                "Mindestlevel",
                selection: Binding(
                    get: {
                        requirement.minimumProficiency
                    },
                    set: { newValue in
                        jobViewModel.updateSkillProficiency(
                            skillId: requirement.skill.id,
                            proficiency: newValue
                        )
                    }
                )
            ) {
                ForEach(
                    SkillProficiency.allCases,
                    id: \.self
                ) { level in
                    Text(level.title)
                        .tag(level)
                }
            }

            Picker(
                "Priorität",
                selection: Binding(
                    get: {
                        requirement.requirementType
                    },
                    set: { newValue in
                        jobViewModel.updateSkillRequirementType(
                            skillId: requirement.skill.id,
                            requirementType: newValue
                        )
                    }
                )
            ) {
                Text(RequirementType.must.title)
                    .tag(RequirementType.must)

                Text(RequirementType.optional.title)
                    .tag(RequirementType.optional)
            }
            .pickerStyle(.segmented)
        }
        .padding(.vertical, ZAZUSpacing.xSmall)
    }
}
