//
//  EmployerCompanyForm.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 10.10.2026.
//

import SwiftUI

struct EmployerCompanyForm: View {

    // MARK: - Company

    @Binding var companyName: String
    @Binding var industry: String
    @Binding var companySize: String
    @Binding var legalForm: String
    @Binding var selectedLocation: SelectedLocation?
    @Binding var website: String
    @Binding var description: String

    // MARK: - Address

    @Binding var addressStreet: String
    @Binding var addressHouseNumber: String
    @Binding var addressPostalCode: String
    @Binding var addressCity: String

    @State private var selectedAddress: SelectedAddress?

    // MARK: - Contact

    @Binding var contactFirstName: String
    @Binding var contactLastName: String
    @Binding var contactEmail: String
    @Binding var contactPhone: String

    // MARK: - Body

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.large
        ) {
            companySection
            addressSection
            contactSection
        }
        .onAppear {
            restoreSelectedAddress()
        }
        .onChange(of: selectedLocation) { _, _ in
            restoreSelectedAddress()
        }
        .onChange(of: addressStreet) { _, _ in
            restoreSelectedAddress()
        }
        .onChange(of: addressHouseNumber) { _, _ in
            restoreSelectedAddress()
        }
        .onChange(of: addressPostalCode) { _, _ in
            restoreSelectedAddress()
        }
        .onChange(of: addressCity) { _, _ in
            restoreSelectedAddress()
        }
        .onChange(of: selectedAddress) { _, newAddress in
            applySelectedAddress(newAddress)
        }    }

    // MARK: - Unternehmen

    private var companySection: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            sectionTitle("Unternehmen")

            field(
                "Firmenname *",
                text: $companyName
            )

            selectionField(
                "Branche",
                selection: $industry,
                options: CompanyOptions.industries
            )

            selectionField(
                "Rechtsform",
                selection: $legalForm,
                options: CompanyOptions.legalForms
            )

            selectionField(
                "Unternehmensgrösse",
                selection: $companySize,
                options: CompanyOptions.companySizes
            )

            field(
                "Website",
                text: $website
            )
            .textInputAutocapitalization(.never)
            .keyboardType(.URL)

            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.small
            ) {
                Text("Über uns")
                    .font(.headline)
                    .foregroundStyle(ZAZUColors.textPrimary)

                TextEditor(text: $description)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 140)
                    .padding(ZAZUSpacing.small)
                    .background(ZAZUColors.white)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: ZAZURadius.medium
                        )
                    )
                    .accessibilityLabel("Über uns")
            }
        }
    }

    // MARK: - Firmenadresse

    private var addressSection: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            sectionTitle("Firmenadresse")

            Text("Adresse *")
                .font(.headline)
                .foregroundStyle(ZAZUColors.textPrimary)

            AddressPickerView(
                selectedAddress: $selectedAddress
            )

            Text(
                "Bitte wähle die vollständige Firmenadresse aus den Apple-Maps-Suchergebnissen aus."
            )
            .font(.footnote)
            .foregroundStyle(ZAZUColors.textSecondary)
        }
    }

    // MARK: - Adresse übernehmen

    private func applySelectedAddress(
        _ address: SelectedAddress?
    ) {
        guard let address else {
            addressStreet = ""
            addressHouseNumber = ""
            addressPostalCode = ""
            addressCity = ""
            selectedLocation = nil
            return
        }

        // Bereits gespeicherte Werte nicht unnötig überschreiben.
        guard
            addressStreet != address.street
            || addressHouseNumber != address.houseNumber
            || addressPostalCode != address.postalCode
            || addressCity != address.city
            || selectedLocation?.latitude != address.latitude
            || selectedLocation?.longitude != address.longitude
        else {
            return
        }

        addressStreet = address.street
        addressHouseNumber = address.houseNumber
        addressPostalCode = address.postalCode
        addressCity = address.city
        selectedLocation = address.selectedLocation
    }
    // MARK: - Gespeicherte Adresse wiederherstellen

    private func restoreSelectedAddress() {
        guard
            !addressStreet.isEmpty,
            !addressHouseNumber.isEmpty,
            !addressPostalCode.isEmpty,
            !addressCity.isEmpty,
            let location = selectedLocation
        else {
            return
        }

        let restoredAddress = SelectedAddress(
            street: addressStreet,
            houseNumber: addressHouseNumber,
            postalCode: addressPostalCode,
            city: addressCity,
            latitude: location.latitude,
            longitude: location.longitude
        )

        if selectedAddress != restoredAddress {
            selectedAddress = restoredAddress
        }
    }

    // MARK: - Kontaktperson

    private var contactSection: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            sectionTitle("Kontaktperson")

            field(
                "Vorname *",
                text: $contactFirstName
            )

            field(
                "Nachname *",
                text: $contactLastName
            )

            field(
                "E-Mail *",
                text: $contactEmail
            )
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)

            field(
                "Telefon",
                text: $contactPhone
            )
            .keyboardType(.phonePad)
        }
    }

    // MARK: - Components

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundStyle(ZAZUColors.textPrimary)
    }

    private func field(
        _ title: String,
        text: Binding<String>
    ) -> some View {
        TextField(title, text: text)
            .padding()
            .background(ZAZUColors.white)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: ZAZURadius.medium
                )
            )
    }

    private func selectionField(
        _ title: String,
        selection: Binding<String>,
        options: [String]
    ) -> some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button {
                    selection.wrappedValue = option
                } label: {
                    if selection.wrappedValue == option {
                        Label(option, systemImage: "checkmark")
                    } else {
                        Text(option)
                    }
                }
            }
        } label: {
            HStack(spacing: ZAZUSpacing.medium) {
                Text(
                    selection.wrappedValue.isEmpty
                        ? title
                        : selection.wrappedValue
                )
                .foregroundStyle(
                    selection.wrappedValue.isEmpty
                        ? ZAZUColors.textSecondary
                        : ZAZUColors.textPrimary
                )

                Spacer(minLength: 8)

                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(ZAZUColors.textSecondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ZAZUColors.white)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: ZAZURadius.medium
                )
            )
            .contentShape(
                RoundedRectangle(
                    cornerRadius: ZAZURadius.medium
                )
            )
        }
        .buttonStyle(.plain)
    }
}
