//
//  EmployerOnboardingViewModel.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 07.10.2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class EmployerOnboardingViewModel {

    var companyName = ""
    var description = ""
    var industry = ""
    var companySize = ""
    var legalForm = ""
    var website = ""
    var selectedLocation: SelectedLocation?
    var addressStreet = ""
    var addressHouseNumber = ""
    var addressPostalCode = ""
    var addressCity = ""

    var contactFirstName = ""
    var contactLastName = ""
    var contactEmail = ""
    var contactPhone = ""

    var isLoading = false
    var errorMessage: String?

    private let userId: UUID
    private let companyRepository: CompanyRepository

    init(
        userId: UUID,
        companyRepository: CompanyRepository
    ) {
        self.userId = userId
        self.companyRepository = companyRepository
    }

    var canSubmit: Bool {
        hasValue(companyName) &&
        hasValue(industry) &&

        // Vollständige Firmenadresse
        hasValue(addressStreet) &&
        hasValue(addressHouseNumber) &&
        hasValue(addressPostalCode) &&
        hasValue(addressCity) &&
        selectedLocation != nil &&

        // Kontaktperson
        hasValue(contactFirstName) &&
        hasValue(contactLastName) &&
        hasValue(contactEmail) &&

        !isLoading
    }

    func createCompany() async -> Bool {
        guard canSubmit,
              let selectedLocation,
              !isLoading else {
            return false
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            if let membership = try await companyRepository.fetchOwnMembership(
                userId: userId
            ) {
                // Bestehendes Unternehmen aktualisieren
                try await companyRepository.updateCompany(
                    companyId: membership.companyId,
                    name: companyName,
                    description: optionalValue(description),
                    industry: optionalValue(industry),
                    companySize: optionalValue(companySize),
                    website: optionalValue(website),
                    location: selectedLocation.name,
                    contactFirstName: optionalValue(contactFirstName),
                    contactLastName: optionalValue(contactLastName),
                    contactEmail: optionalValue(contactEmail),
                    contactPhone: optionalValue(contactPhone),
                    locationLatitude: selectedLocation.latitude,
                    locationLongitude: selectedLocation.longitude,
                    legalForm: optionalValue(legalForm),
                    addressStreet: optionalValue(addressStreet),
                    addressHouseNumber: optionalValue(addressHouseNumber),
                    addressPostalCode: optionalValue(addressPostalCode),
                    addressCity: optionalValue(addressCity)
                )

            }  else {
                // Neues Unternehmen erstellen
                _ = try await companyRepository.createCompany(
                    name: companyName,
                    description: optionalValue(description),
                    industry: optionalValue(industry),
                    companySize: optionalValue(companySize),
                    website: optionalValue(website),
                    location: selectedLocation.name,
                    contactFirstName: optionalValue(contactFirstName),
                    contactLastName: optionalValue(contactLastName),
                    contactEmail: optionalValue(contactEmail),
                    contactPhone: optionalValue(contactPhone),
                    legalForm: optionalValue(legalForm),
                    locationLatitude: selectedLocation.latitude,
                    locationLongitude: selectedLocation.longitude,
                    addressStreet: optionalValue(addressStreet),
                    addressHouseNumber: optionalValue(addressHouseNumber),
                    addressPostalCode: optionalValue(addressPostalCode),
                    addressCity: optionalValue(addressCity)
                )
            }
            return true

        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }


    private func optionalValue(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        return trimmed.isEmpty ? nil : trimmed
    }

    private func hasValue(_ value: String) -> Bool {
        !value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }
}
