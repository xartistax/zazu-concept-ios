//
//  EmployerLanguageRequirementsView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 08.10.2026.
//

import SwiftUI

struct EmployerLanguageRequirementsView: View {
    @Bindable var jobViewModel: EmployerJobFormViewModel
    @State private var languageViewModel: EmployerLanguageRequirementsViewModel

    init(
        jobViewModel: EmployerJobFormViewModel,
        languageRepository: LanguageRepository
    ) {
        self.jobViewModel = jobViewModel
        _languageViewModel = State(
            initialValue: EmployerLanguageRequirementsViewModel(
                languageRepository: languageRepository
            )
        )
    }

    var body: some View {
        Group {
            if languageViewModel.isLoading && languageViewModel.languages.isEmpty {
                ProgressView()
            } else if let errorMessage = languageViewModel.errorMessage {
                ContentUnavailableView(
                    "Sprachen konnten nicht geladen werden",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            } else {
                languageList
            }
        }
        .navigationTitle("Sprachen")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(
            text: $languageViewModel.searchText,
            prompt: "Sprache suchen"
        )
        .task {
            await languageViewModel.loadLanguages()
        }
    }

    private var languageList: some View {
        List {
            if !jobViewModel.languageRequirements.isEmpty {
                Section("Ausgewählt") {
                    ForEach(jobViewModel.languageRequirements) { requirement in
                        selectedLanguageRow(requirement)
                    }
                }
            }

            Section("Sprachen") {
                ForEach(languageViewModel.filteredLanguages) { language in
                    Button {
                        jobViewModel.toggleLanguage(language)
                    } label: {
                        HStack {
                            Text(language.name)
                                .foregroundStyle(ZAZUColors.textPrimary)

                            Spacer()

                            Image(
                                systemName: jobViewModel.isLanguageSelected(language)
                                    ? "checkmark.circle.fill"
                                    : "circle"
                            )
                            .foregroundStyle(
                                jobViewModel.isLanguageSelected(language)
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

    private func selectedLanguageRow(
        _ requirement: EmployerLanguageRequirementDraft
    ) -> some View {
        VStack(alignment: .leading, spacing: ZAZUSpacing.small) {
            HStack {
                Text(requirement.language.name)
                    .font(.headline)

                Spacer()

                Button {
                    jobViewModel.toggleLanguage(requirement.language)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(ZAZUColors.textSecondary)
                }
                .buttonStyle(.plain)
            }

            Picker(
                "Mindestniveau",
                selection: Binding(
                    get: { requirement.minimumProficiency },
                    set: { newValue in
                        jobViewModel.updateLanguageProficiency(
                            languageId: requirement.language.id,
                            proficiency: newValue
                        )
                    }
                )
            ) {
                ForEach(LanguageProficiency.allCases, id: \.self) { level in
                    Text(level.title)
                        .tag(level)
                }
            }

            Picker(
                "Priorität",
                selection: Binding(
                    get: { requirement.requirementType },
                    set: { newValue in
                        jobViewModel.updateLanguageRequirementType(
                            languageId: requirement.language.id,
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
