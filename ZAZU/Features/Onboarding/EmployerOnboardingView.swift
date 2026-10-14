//
//  EmployerOnboardingView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 07.10.2026.
//

import SwiftUI

struct EmployerOnboardingView: View {
    @State private var viewModel: EmployerOnboardingViewModel

    let onCompleted: () -> Void

    init(
        userId: UUID,
        companyRepository: CompanyRepository,
        onCompleted: @escaping () -> Void
    ) {
        _viewModel = State(
            initialValue: EmployerOnboardingViewModel(
                userId: userId,
                companyRepository: companyRepository
            )
        )

        self.onCompleted = onCompleted
    }

    var body: some View {
        ZStack {
            ZAZUColors.veryLightPurple
                .ignoresSafeArea()

            ScrollView {
                VStack(
                    alignment: .leading,
                    spacing: ZAZUSpacing.large
                ) {
                    header

                    EmployerCompanyForm(
                        companyName: $viewModel.companyName,
                        industry: $viewModel.industry,
                        companySize: $viewModel.companySize,
                        legalForm: $viewModel.legalForm,
                        selectedLocation: $viewModel.selectedLocation,
                        website: $viewModel.website,
                        description: $viewModel.description,

                        // Firmenadresse
                        addressStreet: $viewModel.addressStreet,
                        addressHouseNumber: $viewModel.addressHouseNumber,
                        addressPostalCode: $viewModel.addressPostalCode,
                        addressCity: $viewModel.addressCity,

                        // Kontaktperson
                        contactFirstName: $viewModel.contactFirstName,
                        contactLastName: $viewModel.contactLastName,
                        contactEmail: $viewModel.contactEmail,
                        contactPhone: $viewModel.contactPhone
                    )

                    submitButton
                }
                .padding(ZAZUSpacing.large)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            Text("Unternehmen einrichten")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(ZAZUColors.textPrimary)

            Text(
                "Richte dein Unternehmensprofil ein, um passende Kandidaten zu finden."
            )
            .foregroundStyle(ZAZUColors.textSecondary)
        }
    }

    // MARK: - Submit

    private var submitButton: some View {
        VStack(spacing: ZAZUSpacing.small) {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(ZAZUColors.danger)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
            }

            Button {
                Task {
                    if await viewModel.createCompany() {
                        onCompleted()
                    }
                }
            } label: {
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Unternehmen speichern")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .background(
                viewModel.canSubmit
                    ? ZAZUColors.primary
                    : ZAZUColors.textSecondary.opacity(0.4)
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: ZAZURadius.medium
                )
            )
            .disabled(!viewModel.canSubmit || viewModel.isLoading)
        }
    }
}
