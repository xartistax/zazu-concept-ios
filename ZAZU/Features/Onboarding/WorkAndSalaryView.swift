//
//  WorkAndSalaryView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import SwiftUI

struct WorkAndSalaryView: View {
    @State private var viewModel: WorkAndSalaryViewModel
    
    enum Mode {
        case onboarding
        case editing
    }

    private let mode: Mode

    let onContinue: () -> Void

    init(
        viewModel: WorkAndSalaryViewModel,
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

                if viewModel.isInitialLoading {
                    loadingView
                } else {
                    workModelSection
                    homeofficeSection
                    salarySection
                    errorMessage
                    continueButton
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
                        ? "Definiere, wie du arbeiten möchtest und welcher Lohnbereich für dich passt."
                        : "Passe dein gewünschtes Arbeitsmodell und deine Lohnvorstellung an."
                )
                
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(ZAZUColors.primary)

                Spacer()

                Text("7 von 8")
                    .font(.subheadline)
                    .foregroundStyle(ZAZUColors.textSecondary)
            }

            ProgressView(value: 7, total: 8)
                .tint(ZAZUColors.primary)
        }
    }

    private var title: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            Text("Arbeitsmodell & Lohn")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(ZAZUColors.textPrimary)

            Text(
                "Definiere, wie du arbeiten möchtest und welcher Lohnbereich für dich passt."
            )
            .foregroundStyle(ZAZUColors.textSecondary)
        }
    }

    // MARK: - Work Model

    private var workModelSection: some View {
        card {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.medium
            ) {
                sectionTitle(
                    "Arbeitsmodell",
                    systemImage: "building.2"
                )

                Text("Wie möchtest du hauptsächlich arbeiten?")
                    .font(.subheadline)
                    .foregroundStyle(ZAZUColors.textSecondary)

                ForEach(
                    PreferredWorkModel.allCases,
                    id: \.self
                ) { model in
                    selectionButton(
                        title: model.title,
                        isSelected:
                            viewModel.preferredWorkModel == model
                    ) {
                        viewModel.preferredWorkModel = model
                    }
                }
            }
        }
    }

    // MARK: - Homeoffice

    private var homeofficeSection: some View {
        card {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.medium
            ) {
                sectionTitle(
                    "Homeoffice",
                    systemImage: "house"
                )

                Text("Möchtest du im Homeoffice arbeiten?")
                    .font(.subheadline)
                    .foregroundStyle(ZAZUColors.textSecondary)

                ForEach(
                    HomeofficePreference.allCases,
                    id: \.self
                ) { preference in
                    selectionButton(
                        title: preference.title,
                        isSelected:
                            viewModel.homeofficePreference == preference
                    ) {
                        viewModel.homeofficePreference = preference
                    }
                }

                if viewModel.homeofficePreference != .no {
                    Divider()

                    VStack(
                        alignment: .leading,
                        spacing: ZAZUSpacing.small
                    ) {
                        Text("Gewünschte Homeoffice-Tage")
                            .font(.subheadline)
                            .foregroundStyle(
                                ZAZUColors.textSecondary
                            )

                        Stepper(
                            "\(viewModel.desiredHomeofficeDays) Tage pro Woche",
                            value:
                                $viewModel.desiredHomeofficeDays,
                            in: 0...5
                        )
                    }

                    Divider()

                    Text("Verteilung der Homeoffice-Tage")
                        .font(.subheadline)
                        .foregroundStyle(
                            ZAZUColors.textSecondary
                        )

                    ForEach(
                        HomeofficeSchedulePreference.allCases,
                        id: \.self
                    ) { preference in
                        selectionButton(
                            title: preference.title,
                            isSelected:
                                viewModel
                                    .preferredHomeofficeSchedule
                                == preference
                        ) {
                            viewModel
                                .preferredHomeofficeSchedule =
                                preference
                        }
                    }

                    Divider()

                    Toggle(
                        "Vollständig Remote kommt für mich infrage",
                        isOn: $viewModel.acceptsFullyRemote
                    )
                    .tint(ZAZUColors.primary)
                }
            }
        }
    }

    // MARK: - Salary

    private var salarySection: some View {
        card {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.medium
            ) {
                sectionTitle(
                    "Lohnvorstellung",
                    systemImage: "banknote"
                )

                Text("Bruttojahreslohn in CHF")
                    .font(.subheadline)
                    .foregroundStyle(ZAZUColors.textSecondary)

                Text(
                    "\(formattedSalary(viewModel.salaryMin)) – \(formattedSalary(viewModel.salaryMax))"
                )
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(ZAZUColors.primary)

                VStack(
                    alignment: .leading,
                    spacing: ZAZUSpacing.small
                ) {
                    Text("Minimum")
                        .font(.subheadline)
                        .foregroundStyle(
                            ZAZUColors.textSecondary
                        )

                    Stepper(
                        formattedSalary(viewModel.salaryMin),
                        value: $viewModel.salaryMin,
                        in: 20_000...300_000,
                        step: 5_000
                    )
                }

                VStack(
                    alignment: .leading,
                    spacing: ZAZUSpacing.small
                ) {
                    Text("Maximum")
                        .font(.subheadline)
                        .foregroundStyle(
                            ZAZUColors.textSecondary
                        )

                    Stepper(
                        formattedSalary(viewModel.salaryMax),
                        value: $viewModel.salaryMax,
                        in: 20_000...300_000,
                        step: 5_000
                    )
                }

                if viewModel.salaryMin > viewModel.salaryMax {
                    Text(
                        "Der minimale Lohn darf nicht über dem maximalen Lohn liegen."
                    )
                    .font(.footnote)
                    .foregroundStyle(.red)
                }

                Text(
                    "Dein Lohnbereich wird später transparent mit dem Lohnband eines Jobs verglichen."
                )
                .font(.footnote)
                .foregroundStyle(ZAZUColors.textSecondary)
            }
        }
    }

    // MARK: - Continue

    private var continueButton: some View {
        Button {
            Task {
                let didSave = await viewModel.save()

                if didSave {
                    onContinue()
                }
            }
        } label: {
            Group {
                if viewModel.isSaving {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(
                        mode == .onboarding
                            ? "Weiter zur Zusammenfassung"
                            : "Änderungen speichern"
                    )
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
        .disabled(!viewModel.canContinue)
        .opacity(viewModel.canContinue ? 1 : 0.5)
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

    // MARK: - Components

    private func sectionTitle(
        _ title: String,
        systemImage: String
    ) -> some View {
        Label(title, systemImage: systemImage)
            .font(.headline)
            .foregroundStyle(ZAZUColors.textPrimary)
    }

    private func selectionButton(
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundStyle(ZAZUColors.textPrimary)

                Spacer()

                Image(
                    systemName: isSelected
                        ? "checkmark.circle.fill"
                        : "circle"
                )
                .foregroundStyle(
                    isSelected
                        ? ZAZUColors.primary
                        : ZAZUColors.textSecondary
                )
            }
            .padding(ZAZUSpacing.medium)
            .background(
                isSelected
                    ? ZAZUColors.lightPurple
                    : ZAZUColors.veryLightPurple
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: ZAZURadius.medium
                )
            )
        }
        .buttonStyle(.plain)
    }

    private func card<Content: View>(
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
                    cornerRadius: ZAZURadius.large
                )
            )
    }

    // MARK: - Formatting

    private func formattedSalary(
        _ value: Int
    ) -> String {
        value.formatted(
            .currency(code: "CHF")
                .precision(.fractionLength(0))
        )
    }
}
