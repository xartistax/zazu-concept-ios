//
//  EducationView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import SwiftUI

struct EducationView: View {
    @State private var viewModel: EducationViewModel
    
    enum Mode {
        case onboarding
        case editing
    }

    private let mode: Mode

    let onContinue: () -> Void

    init(
        viewModel: EducationViewModel,
        mode: Mode = .onboarding,
        onContinue: @escaping () -> Void = {}
    ) {
        _viewModel = State(initialValue: viewModel)
        self.mode = mode
        self.onContinue = onContinue
    }

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.large
            ) {
                if mode == .onboarding {
                    progressHeader
                }

                title

                if viewModel.isLoading {
                    loadingView
                } else {
                    educationList
                    form
                    errorMessage

                    if mode == .onboarding {
                        continueButton
                    }
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
                Text(
                    mode == .onboarding
                        ? "Füge relevante Ausbildungen und Qualifikationen zu deinem Profil hinzu."
                        : "Verwalte deine Ausbildungen und Qualifikationen."
                )
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(ZAZUColors.primary)

                Spacer()

                Text("4 von 8")
                    .font(.subheadline)
                    .foregroundStyle(ZAZUColors.textSecondary)
            }

            ProgressView(value: 4, total: 8)
                .tint(ZAZUColors.primary)
        }
    }

    private var title: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            Text("Ausbildung & Qualifikationen")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(ZAZUColors.textPrimary)

            Text(
                "Füge relevante Ausbildungen und Qualifikationen zu deinem Profil hinzu."
            )
            .foregroundStyle(ZAZUColors.textSecondary)
        }
    }

    // MARK: - Existing Educations

    @ViewBuilder
    private var educationList: some View {
        if !viewModel.educations.isEmpty {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.medium
            ) {
                Text("Deine Einträge")
                    .font(.headline)
                    .foregroundStyle(ZAZUColors.textPrimary)

                ForEach(viewModel.educations) { education in
                    educationCard(education)
                }
            }
        }
    }

    private func educationCard(
        _ education: Education
    ) -> some View {
        HStack(
            alignment: .top,
            spacing: ZAZUSpacing.medium
        ) {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.xSmall
            ) {
                Text(education.degree)
                    .font(.headline)
                    .foregroundStyle(ZAZUColors.textPrimary)

                Text(education.institutionName)
                    .foregroundStyle(ZAZUColors.textSecondary)

                if let field = education.fieldOfStudy {
                    Text(field)
                        .font(.subheadline)
                        .foregroundStyle(ZAZUColors.textSecondary)
                }

                Text(dateDescription(for: education))
                    .font(.caption)
                    .foregroundStyle(ZAZUColors.textSecondary)

                if education.isCurrent {
                    Text("Aktuell")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(ZAZUColors.primary)
                }
            }

            Spacer()

            Button {
                Task {
                    await viewModel.deleteEducation(education)
                }
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(ZAZUSpacing.medium)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(cornerRadius: ZAZURadius.medium)
        )
    }

    // MARK: - Form

    private var form: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            Text("Eintrag hinzufügen")
                .font(.headline)
                .foregroundStyle(ZAZUColors.textPrimary)

            textField(
                "Institution / Schule",
                text: $viewModel.institutionName
            )

            textField(
                "Abschluss / Qualifikation",
                text: $viewModel.degree
            )

            textField(
                "Fachrichtung (optional)",
                text: $viewModel.fieldOfStudy
            )

            startDateSection

            Toggle(
                "Läuft aktuell",
                isOn: $viewModel.isCurrent
            )
            .tint(ZAZUColors.primary)

            if !viewModel.isCurrent {
                endDateSection
            }

            descriptionSection

            addButton
        }
        .padding(ZAZUSpacing.medium)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(cornerRadius: ZAZURadius.large)
        )
    }

    private var startDateSection: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            Toggle(
                "Startdatum bekannt",
                isOn: $viewModel.hasStartDate
            )
            .tint(ZAZUColors.primary)

            if viewModel.hasStartDate {
                DatePicker(
                    "Startdatum",
                    selection: $viewModel.startDate,
                    displayedComponents: .date
                )
            }
        }
    }

    private var endDateSection: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            Toggle(
                "Enddatum bekannt",
                isOn: $viewModel.hasEndDate
            )
            .tint(ZAZUColors.primary)

            if viewModel.hasEndDate {
                DatePicker(
                    "Enddatum",
                    selection: $viewModel.endDate,
                    displayedComponents: .date
                )
            }
        }
    }

    private var descriptionSection: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            Text("Beschreibung (optional)")
                .font(.subheadline)
                .fontWeight(.medium)

            TextEditor(text: $viewModel.description)
                .frame(minHeight: 100)
                .padding(ZAZUSpacing.small)
                .background(ZAZUColors.veryLightPurple)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: ZAZURadius.medium
                    )
                )
        }
    }

    private var addButton: some View {
        Button {
            Task {
                _ = await viewModel.addEducation()
            }
        } label: {
            Group {
                if viewModel.isSaving {
                    ProgressView()
                        .tint(ZAZUColors.primary)
                } else {
                    Label(
                        "Eintrag hinzufügen",
                        systemImage: "plus"
                    )
                    .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
        .buttonStyle(.plain)
        .foregroundStyle(ZAZUColors.primary)
        .background(ZAZUColors.lightPurple)
        .clipShape(
            RoundedRectangle(cornerRadius: ZAZURadius.medium)
        )
        .disabled(!viewModel.canSaveEducation)
        .opacity(viewModel.canSaveEducation ? 1 : 0.5)
    }

    // MARK: - Continue

    private var continueButton: some View {
        Button {
            Task {
                let didComplete = await viewModel.completeStep()

                if didComplete {
                    onContinue()
                }
            }
        } label: {
            Text(
                viewModel.educations.isEmpty
                    ? "Ohne Eintrag weiter"
                    : "Weiter"
            )
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .background(ZAZUColors.primary)
        .clipShape(
            RoundedRectangle(cornerRadius: ZAZURadius.medium)
        )
    }

    // MARK: - State

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
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Helpers

    private func textField(
        _ title: String,
        text: Binding<String>
    ) -> some View {
        TextField(title, text: text)
            .padding(ZAZUSpacing.medium)
            .background(ZAZUColors.veryLightPurple)
            .clipShape(
                RoundedRectangle(cornerRadius: ZAZURadius.medium)
            )
    }

    private func dateDescription(
        for education: Education
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
}
