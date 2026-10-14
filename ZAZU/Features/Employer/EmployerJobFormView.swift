//
//  EmployerJobFormView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 07.10.2026.
//

import SwiftUI
import Supabase

struct EmployerJobFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: EmployerJobFormViewModel

    private let skillRepository: SkillRepository
    private let languageRepository: LanguageRepository
    private let supabaseClient: SupabaseClient

    init(
        userId: UUID,
        companyRepository: CompanyRepository,
        jobRepository: JobRepository,
        skillRepository: SkillRepository,
        languageRepository: LanguageRepository,
        editingJob: Job? = nil,
        supabaseClient: SupabaseClient,
    ) {
        self.skillRepository = skillRepository
        self.languageRepository = languageRepository
        self.supabaseClient = supabaseClient

        _viewModel = State(
            initialValue: EmployerJobFormViewModel(
                userId: userId,
                companyRepository: companyRepository,
                jobRepository: jobRepository,
                skillRepository: skillRepository,
                languageRepository: languageRepository,
                editingJob: editingJob,
                contactRepository: CompanyContactRepository(
                    client: supabaseClient
                ),
            )
        )
    }
    
    var body: some View {
        Form {
            Section("Job") {
                TextField("Jobtitel", text: $viewModel.title)

                TextField(
                    "Beschreibung",
                    text: $viewModel.description,
                    axis: .vertical
                )
                .lineLimit(4...8)

                TextField(
                    "Tätigkeitsbereich",
                    text: $viewModel.activityArea
                )

                TextField(
                    "Arbeitsort",
                    text: $viewModel.location
                )
            }
            
            Section("Verantwortliche Kontaktperson") {

                if viewModel.isLoadingContacts {
                    ProgressView("Kontaktpersonen werden geladen …")

                } else if viewModel.availableContacts.isEmpty {
                    ContentUnavailableView(
                        "Keine Kontaktpersonen",
                        systemImage: "person.crop.circle.badge.plus",
                        description: Text(
                            "Erstelle zuerst eine Kontaktperson unter Unternehmen → Jobverantwortliche."
                        )
                    )

                } else {
                    Picker(
                        "Kontaktperson",
                        selection: $viewModel.selectedContactId
                    ) {
                        Text("Keine Kontaktperson")
                            .tag(nil as UUID?)

                        ForEach(viewModel.availableContacts) { contact in
                            Text(contact.fullName)
                                .tag(Optional(contact.id))
                        }
                    }

                    if let selectedContact = viewModel.availableContacts.first(
                        where: { $0.id == viewModel.selectedContactId }
                    ) {
                        HStack(spacing: ZAZUSpacing.medium) {
                            ContactAvatarView(
                                contactId: selectedContact.id,
                                size: 56,
                                portraitPath: selectedContact.portraitPath,
                                imageStorageService: CompanyImageStorageService(
                                    client: supabaseClient
                                )
                            )
                            VStack(alignment: .leading, spacing: 4) {
                                Text(selectedContact.fullName)
                                    .font(.headline)

                                if let position = selectedContact.position {
                                    Text(position)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            
            Section("Anforderungen") {
                NavigationLink {
                    EmployerSkillRequirementsView(
                        jobViewModel: viewModel,
                        skillRepository: skillRepository
                    )
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: ZAZUSpacing.xSmall) {
                            Text("Skills & Systemkenntnisse")
                                .foregroundStyle(ZAZUColors.textPrimary)

                            Text(
                                viewModel.skillRequirements.isEmpty
                                ? "Noch keine ausgewählt"
                                : "\(viewModel.skillRequirements.count) ausgewählt"
                            )
                            .font(.caption)
                            .foregroundStyle(ZAZUColors.textSecondary)
                        }

                        Spacer()
                    }
                }
                
                NavigationLink {
                    EmployerLanguageRequirementsView(
                        jobViewModel: viewModel,
                        languageRepository: languageRepository
                    )
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: ZAZUSpacing.xSmall) {
                            Text("Sprachen")
                                .foregroundStyle(ZAZUColors.textPrimary)

                            Text(
                                viewModel.languageRequirements.isEmpty
                                    ? "Noch keine ausgewählt"
                                    : "\(viewModel.languageRequirements.count) ausgewählt"
                            )
                            .font(.caption)
                            .foregroundStyle(ZAZUColors.textSecondary)
                        }

                        Spacer()
                    }
                }
                
                NavigationLink {
                    EmployerEducationRequirementsView(
                        jobViewModel: viewModel
                    )
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: ZAZUSpacing.xSmall) {
                            Text("Ausbildung & Qualifikationen")
                                .foregroundStyle(ZAZUColors.textPrimary)

                            Text(
                                viewModel.educationRequirements.isEmpty
                                    ? "Noch keine hinzugefügt"
                                    : "\(viewModel.educationRequirements.count) hinzugefügt"
                            )
                            .font(.caption)
                            .foregroundStyle(ZAZUColors.textSecondary)
                        }

                        Spacer()
                    }
                }
            }

            Section("Arbeitsmodell") {
                Picker(
                    "Arbeitsmodell",
                    selection: $viewModel.workModel
                ) {
                    ForEach(
                        PreferredWorkModel.allCases,
                        id: \.self
                    ) { model in
                        Text(model.title)
                            .tag(model)
                    }
                }

                requirementPicker(
                    title: "Priorität",
                    selection: $viewModel.workModelRequirementType
                )
            }

            Section("Pensum") {
                Stepper(
                    "Minimum: \(viewModel.workloadMin) %",
                    value: $viewModel.workloadMin,
                    in: 10...100,
                    step: 10
                )

                Stepper(
                    "Maximum: \(viewModel.workloadMax) %",
                    value: $viewModel.workloadMax,
                    in: 10...100,
                    step: 10
                )

                if viewModel.workloadMin > viewModel.workloadMax {
                    Text("Das Minimum darf nicht über dem Maximum liegen.")
                        .font(.footnote)
                        .foregroundStyle(ZAZUColors.danger)
                }
            }

            Section("Lohn") {
                TextField(
                    "Minimum CHF / Jahr",
                    text: $viewModel.salaryMin
                )
                .keyboardType(.numberPad)

                TextField(
                    "Maximum CHF / Jahr",
                    text: $viewModel.salaryMax
                )
                .keyboardType(.numberPad)
            }

            Section("Berufserfahrung") {
                Stepper(
                    viewModel.requiredWorkExperienceYears == 0
                        ? "Keine Mindestanforderung"
                        : "\(viewModel.requiredWorkExperienceYears) Jahre",
                    value: $viewModel.requiredWorkExperienceYears,
                    in: 0...30
                )

                if viewModel.requiredWorkExperienceYears > 0 {
                    requirementPicker(
                        title: "Priorität",
                        selection:
                            $viewModel.workExperienceRequirementType
                    )
                }
            }

            Section("Arbeitsbewilligung") {
                Toggle(
                    "Arbeitsbewilligung erforderlich",
                    isOn: $viewModel.requiresWorkAuthorization
                )

                if viewModel.requiresWorkAuthorization {
                    requirementPicker(
                        title: "Priorität",
                        selection:
                            $viewModel.workAuthorizationRequirementType
                    )
                }
            }

            Section("Homeoffice") {
                Toggle(
                    "Homeoffice möglich",
                    isOn: $viewModel.homeofficeAvailable
                )

                if viewModel.homeofficeAvailable {
                    Stepper(
                        "Bis \(viewModel.homeofficeDays) Tage / Woche",
                        value: $viewModel.homeofficeDays,
                        in: 0...5
                    )

                    Picker(
                        "Regelung",
                        selection: $viewModel.homeofficeSchedule
                    ) {
                        Text(JobHomeofficeSchedule.fixed.title)
                            .tag(JobHomeofficeSchedule.fixed)

                        Text(JobHomeofficeSchedule.flexible.title)
                            .tag(JobHomeofficeSchedule.flexible)
                    }

                    requirementPicker(
                        title: "Priorität",
                        selection:
                            $viewModel.homeofficeRequirementType
                    )
                }

                Toggle(
                    "Vollständig remote möglich",
                    isOn: $viewModel.fullyRemoteAvailable
                )
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(ZAZUColors.danger)
                }
            }

            Section {
                Button {
                    Task {
                        if await viewModel.saveJob() {
                            dismiss()
                        }
                    }
                } label: {
                    HStack {
                        Spacer()

                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text(
                                viewModel.editingJob == nil
                                    ? "Job erstellen"
                                    : "Änderungen speichern"
                            )
                            .fontWeight(.semibold)
                        }

                        Spacer()
                    }
                }
                .disabled(!viewModel.canSubmit)
            }
        }
        .navigationTitle(
            viewModel.editingJob == nil
                ? "Neuer Job"
                : "Job bearbeiten"
        )
        .navigationBarTitleDisplayMode(.inline)
        .task {
            async let contacts: Void = viewModel.loadContacts()
            async let requirements: Void = viewModel.loadRequirementsForEditing()

            _ = await (contacts, requirements)
        }

    }

    @ViewBuilder
    private func requirementPicker(
        title: String,
        selection: Binding<RequirementType>
    ) -> some View {
        Picker(title, selection: selection) {
            Text(RequirementType.must.title)
                .tag(RequirementType.must)

            Text(RequirementType.optional.title)
                .tag(RequirementType.optional)
        }
        .pickerStyle(.segmented)
    }
}
