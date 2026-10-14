//
//  EmployerCompanyViewModel.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 10.10.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class EmployerCompanyViewModel {

    // MARK: - Dependencies

    private let companyRepository: CompanyRepository
    private let userId: UUID

    // MARK: - Company

    var company: Company?

    // MARK: - Company Information

    var name = ""
    var description = ""
    var industry = ""
    var companySize = ""
    var legalForm = ""
    var website = ""

    // MARK: - Location

    var location = ""
    var selectedLocation: SelectedLocation?

    // MARK: - Address

    var addressStreet = ""
    var addressHouseNumber = ""
    var addressPostalCode = ""
    var addressCity = ""

    // MARK: - Contact

    var contactFirstName = ""
    var contactLastName = ""
    var contactEmail = ""
    var contactPhone = ""

    // MARK: - State

    var isLoading = false
    var isSaving = false

    var errorMessage: String?
    var successMessage: String?
    
    var logoRevision = 0
    var bannerRevision = 0
    

    // MARK: - Initialization

    init(
        companyRepository: CompanyRepository,
        userId: UUID
    ) {
        self.companyRepository = companyRepository
        self.userId = userId
    }

    // MARK: - Validation

 

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !industry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&

        // Vollständige Firmenadresse
        !addressStreet.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !addressHouseNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !addressPostalCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !addressCity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedLocation != nil &&

        // Kontaktperson
        !contactFirstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !contactLastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !contactEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Load Company

    func load() async {
        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            guard let membership = try await companyRepository
                .fetchOwnMembership(userId: userId) else {

                errorMessage = "Unternehmenszugehörigkeit nicht gefunden."
                return
            }

            let loadedCompany = try await companyRepository
                .fetchCompany(companyId: membership.companyId)

            company = loadedCompany
            apply(loadedCompany)

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Save Company

    func save() async -> Bool {
        guard
            let company,
            let selectedLocation,
            canSave,
            !isSaving
        else {
            return false
        }

        isSaving = true
        errorMessage = nil
        successMessage = nil

        defer {
            isSaving = false
        }

        do {
            try await companyRepository.updateCompany(
                companyId: company.id,

                // Company
                name: cleaned(name) ?? "",
                description: cleaned(description),
                industry: cleaned(industry),
                companySize: cleaned(companySize),
                website: cleaned(website),

                // Location
                location: selectedLocation.name,

                // Contact
                contactFirstName: cleaned(contactFirstName),
                contactLastName: cleaned(contactLastName),
                contactEmail: cleaned(contactEmail),
                contactPhone: cleaned(contactPhone),

                // Coordinates
                locationLatitude: selectedLocation.latitude,
                locationLongitude: selectedLocation.longitude,

                // Legal Form
                legalForm: cleaned(legalForm),

                // Address
                addressStreet: cleaned(addressStreet),
                addressHouseNumber: cleaned(addressHouseNumber),
                addressPostalCode: cleaned(addressPostalCode),
                addressCity: cleaned(addressCity)
            )

            successMessage = "Unternehmensprofil gespeichert."

            await load()

            return true

        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Apply Company Data

    private func apply(_ company: Company) {

        // Company
        name = company.name
        description = company.description ?? ""
        industry = company.industry ?? ""
        companySize = company.companySize ?? ""
        legalForm = company.legalForm ?? ""
        website = company.website ?? ""

        // Location
        location = company.location ?? ""

        if let name = company.location,
           let latitude = company.locationLatitude,
           let longitude = company.locationLongitude,
           !name.isEmpty {

            selectedLocation = SelectedLocation(
                name: name,
                latitude: latitude,
                longitude: longitude
            )

        } else {
            selectedLocation = nil
        }

        // Address
        addressStreet = company.addressStreet ?? ""
        addressHouseNumber = company.addressHouseNumber ?? ""
        addressPostalCode = company.addressPostalCode ?? ""
        addressCity = company.addressCity ?? ""

        // Contact
        contactFirstName = company.contactFirstName ?? ""
        contactLastName = company.contactLastName ?? ""
        contactEmail = company.contactEmail ?? ""
        contactPhone = company.contactPhone ?? ""
    }

    // MARK: - Helpers

    private func cleaned(_ value: String) -> String? {
        let trimmedValue = value.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        return trimmedValue.isEmpty ? nil : trimmedValue
    }
}
