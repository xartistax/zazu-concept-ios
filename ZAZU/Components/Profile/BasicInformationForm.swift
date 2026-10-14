//
//  BasicInformationForm.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 29.09.2026.
//

import SwiftUI

struct BasicInformationForm: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: ZAZUSpacing.medium) {
            field("Vorname", text: $viewModel.firstName)
            field("Nachname", text: $viewModel.lastName)
            phoneField(

                    "Telefonnummer",

                    text: $viewModel.phoneNumber

                )
            VStack(alignment: .leading, spacing: ZAZUSpacing.small) {
                Text("Wohnort / Region")
                    .font(.headline)
                    .foregroundStyle(ZAZUColors.textPrimary)

                LocationPickerView(
                    selectedLocation: $viewModel.selectedRegion
                )
            }

            field(
                "Staatsangehörigkeit / Staatszugehörigkeit",
                text: $viewModel.nationality
            )

            VStack(alignment: .leading, spacing: ZAZUSpacing.small) {
                Text("Arbeitsberechtigung vorhanden?")
                    .font(.headline)

                Picker(
                    "Arbeitsberechtigung",
                    selection: $viewModel.hasWorkAuthorization
                ) {
                    Text("Ja").tag(true)
                    Text("Nein").tag(false)
                }
                .pickerStyle(.segmented)
            }

            field(
                "Bewilligung / Details (optional)",
                text: $viewModel.workAuthorizationDetails
            )



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
        .padding(ZAZUSpacing.medium)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: ZAZURadius.large
            )
        )
    }

    private func field(
        _ title: String,
        text: Binding<String>
    ) -> some View {
        TextField(
            "",
            text: text,
            prompt: Text(title)
                .foregroundStyle(ZAZUColors.textSecondary)
        )
        .foregroundStyle(ZAZUColors.textPrimary)
        .textInputAutocapitalization(.words)
        .padding(ZAZUSpacing.medium)
        .background(ZAZUColors.veryLightPurple)
        .clipShape(
            RoundedRectangle(
                cornerRadius: ZAZURadius.medium
            )
        )
    }
    
    
    private func phoneField(
        _ title: String,
        text: Binding<String>
    ) -> some View {
        TextField(
            "",
            text: text,
            prompt: Text(title)
                .foregroundStyle(ZAZUColors.textSecondary)
        )
        .foregroundStyle(ZAZUColors.textPrimary)
        .keyboardType(.phonePad)
        .textContentType(.telephoneNumber)
        .textInputAutocapitalization(.never)
        .padding(ZAZUSpacing.medium)
        .background(ZAZUColors.veryLightPurple)
        .clipShape(
            RoundedRectangle(
                cornerRadius: ZAZURadius.medium
            )
        )
    }
}
