//
//  JobPreferencesView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import SwiftUI

struct JobPreferencesView: View {
    @State private var viewModel: JobPreferencesViewModel
    
    enum Mode {
        case onboarding
        case editing
    }

    private let mode: Mode

    let onContinue: () -> Void

    init(
        viewModel: JobPreferencesViewModel,
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
                    workloadSection
                    locationSection
                    mobilitySection
                    startDateSection
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
                        ? "Sag uns, welche Rahmenbedingungen für deinen nächsten Job passen."
                        : "Passe die Rahmenbedingungen für deinen nächsten Job an."
                )
                .foregroundStyle(ZAZUColors.textSecondary)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(ZAZUColors.primary)

                Spacer()

                Text("6 von 8")
                    .font(.subheadline)
                    .foregroundStyle(ZAZUColors.textSecondary)
            }

            ProgressView(value: 6, total: 8)
                .tint(ZAZUColors.primary)
        }
    }

    private var title: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            Text("Jobpräferenzen")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(ZAZUColors.textPrimary)

            Text(
                "Sag uns, welche Rahmenbedingungen für deinen nächsten Job passen."
            )
            .foregroundStyle(ZAZUColors.textSecondary)
        }
    }

    // MARK: - Workload

    private var workloadSection: some View {
        card {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.medium
            ) {
                sectionTitle(
                    "Arbeitspensum",
                    systemImage: "percent"
                )

                Text(
                    "\(viewModel.desiredWorkloadMin)–\(viewModel.desiredWorkloadMax) %"
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
                        .foregroundStyle(ZAZUColors.textSecondary)

                    Stepper(
                        "\(viewModel.desiredWorkloadMin) %",
                        value: $viewModel.desiredWorkloadMin,
                        in: 10...100,
                        step: 10
                    )
                }

                VStack(
                    alignment: .leading,
                    spacing: ZAZUSpacing.small
                ) {
                    Text("Maximum")
                        .font(.subheadline)
                        .foregroundStyle(ZAZUColors.textSecondary)

                    Stepper(
                        "\(viewModel.desiredWorkloadMax) %",
                        value: $viewModel.desiredWorkloadMax,
                        in: 10...100,
                        step: 10
                    )
                }

                if viewModel.desiredWorkloadMin >
                    viewModel.desiredWorkloadMax {
                    Text(
                        "Das minimale Pensum darf nicht über dem maximalen Pensum liegen."
                    )
                    .font(.footnote)
                    .foregroundStyle(.red)
                }
            }
        }
    }

    // MARK: - Location

    private var locationSection: some View {
        card {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.medium
            ) {
                sectionTitle(
                    "Arbeitsort",
                    systemImage: "mappin.and.ellipse"
                )

                LocationPickerView(
                    selectedLocation: $viewModel.selectedLocation
                )

                VStack(
                    alignment: .leading,
                    spacing: ZAZUSpacing.small
                ) {
                    Text("Arbeitsradius")
                        .font(.subheadline)
                        .foregroundStyle(ZAZUColors.textSecondary)

                    Stepper(
                        "\(viewModel.workRadiusKm) km",
                        value: $viewModel.workRadiusKm,
                        in: 0...200,
                        step: 5
                    )

                    Text(
                        viewModel.workRadiusKm == 0
                            ? "Nur am gewünschten Arbeitsort"
                            : "Bis \(viewModel.workRadiusKm) km rund um den gewünschten Arbeitsort"
                    )
                    .font(.footnote)
                    .foregroundStyle(ZAZUColors.textSecondary)
                }
            }
        }
    }

    // MARK: - Mobility

    private var mobilitySection: some View {
        card {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.medium
            ) {
                sectionTitle(
                    "Mobilität",
                    systemImage: "car"
                )

                Toggle(
                    "Ich bin pendelbereit",
                    isOn: $viewModel.willingToCommute
                )
                .tint(ZAZUColors.primary)

                Divider()

                Toggle(
                    "Ich bin umzugsbereit",
                    isOn: $viewModel.willingToRelocate
                )
                .tint(ZAZUColors.primary)
            }
        }
    }

    // MARK: - Start Date

    private var startDateSection: some View {
        card {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.medium
            ) {
                sectionTitle(
                    "Verfügbarkeit",
                    systemImage: "calendar"
                )

                DatePicker(
                    "Frühestmöglicher Eintritt",
                    selection: $viewModel.earliestStartDate,
                    displayedComponents: .date
                )
                .tint(ZAZUColors.primary)
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
                            ? "Weiter"
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
}
