//
//  WorkExperienceView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import SwiftUI

struct WorkExperienceView: View {
    @State private var viewModel: WorkExperienceViewModel
    enum Mode {
        case onboarding
        case editing
    }

    private let mode: Mode
    let onContinue: () -> Void
    



    init(
        viewModel: WorkExperienceViewModel,
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
                    ProgressView()
                        .tint(ZAZUColors.primary)
                        .frame(maxWidth: .infinity)
                } else {
                    experiencesSection
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

    private var progressHeader: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            HStack {
                Text(
                    mode == .onboarding
                        ? "Füge deine aktuellen und bisherigen beruflichen Stationen hinzu."
                        : "Verwalte deine aktuellen und bisherigen beruflichen Stationen."
                )
                .foregroundStyle(ZAZUColors.textSecondary)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(ZAZUColors.primary)

                Spacer()

                Text("2 von 8")
                    .font(.subheadline)
                    .foregroundStyle(ZAZUColors.textSecondary)
            }

            ProgressView(value: 2, total: 8)
                .tint(ZAZUColors.primary)
        }
    }

    private var title: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            Text("Berufserfahrung")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(ZAZUColors.textPrimary)

            Text("Füge deine aktuellen und bisherigen beruflichen Stationen hinzu.")
                .foregroundStyle(ZAZUColors.textSecondary)
        }
    }

    @ViewBuilder
    private var experiencesSection: some View {
        if !viewModel.experiences.isEmpty {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.medium
            ) {
                Text("Deine Stationen")
                    .font(.headline)
                    .foregroundStyle(ZAZUColors.textPrimary)

                ForEach(viewModel.experiences) { experience in
                    experienceCard(experience)
                }
            }
        }
    }

    private func experienceCard(
        _ experience: WorkExperience
    ) -> some View {
        HStack(alignment: .top, spacing: ZAZUSpacing.medium) {
            VStack(alignment: .leading, spacing: ZAZUSpacing.xSmall) {
                Text(experience.jobTitle)
                    .font(.headline)
                    .foregroundStyle(ZAZUColors.textPrimary)

                Text(experience.employerName)
                    .foregroundStyle(ZAZUColors.textSecondary)

                if experience.isCurrent {
                    Text("Aktuelle Position")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(ZAZUColors.primary)
                }
            }

            Spacer()

            Button {
                Task {
                    await viewModel.deleteExperience(experience)
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

    private var form: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            Text("Station hinzufügen")
                .font(.headline)
                .foregroundStyle(ZAZUColors.textPrimary)

            textField(
                "Position / Jobtitel",
                text: $viewModel.jobTitle
            )

            textField(
                "Arbeitgeber",
                text: $viewModel.employerName
            )

            textField(
                "Ort (optional)",
                text: $viewModel.location
            )

            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.small
            ) {
                Text("Startdatum")
                    .font(.subheadline)
                    .fontWeight(.medium)

                DatePicker(
                    "Startdatum",
                    selection: $viewModel.startDate,
                    displayedComponents: .date
                )
                .labelsHidden()
            }

            Toggle(
                "Aktuelle Position",
                isOn: $viewModel.isCurrent
            )
            .tint(ZAZUColors.primary)

            if !viewModel.isCurrent {
                VStack(
                    alignment: .leading,
                    spacing: ZAZUSpacing.small
                ) {
                    Text("Enddatum")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    DatePicker(
                        "Enddatum",
                        selection: $viewModel.endDate,
                        in: viewModel.startDate...,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                }
            }

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

            Button {
                Task {
                    _ = await viewModel.addExperience()
                }
            } label: {
                Group {
                    if viewModel.isSaving {
                        ProgressView()
                            .tint(ZAZUColors.primary)
                    } else {
                        Label(
                            "Station hinzufügen",
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
            .disabled(!viewModel.canSaveExperience)
            .opacity(viewModel.canSaveExperience ? 1 : 0.5)
        }
        .padding(ZAZUSpacing.medium)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(cornerRadius: ZAZURadius.large)
        )
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

    private var continueButton: some View {
        Button {
            Task {
                let didComplete = await viewModel.completeStep()

                if didComplete {
                    onContinue()
                }
            }
        } label: {
            Text("Weiter")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .background(
            viewModel.experiences.isEmpty
                ? ZAZUColors.textSecondary.opacity(0.4)
                : ZAZUColors.primary
        )
        .clipShape(
            RoundedRectangle(cornerRadius: ZAZURadius.medium)
        )
        .disabled(viewModel.experiences.isEmpty)
    }

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
}
