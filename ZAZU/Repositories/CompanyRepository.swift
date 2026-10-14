//
//  CompanyRepository.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 07.10.2026.
//

import Foundation
import Supabase

final class CompanyRepository {
    private let client: SupabaseClient
    
    init(client: SupabaseClient) {
        self.client = client
    }
    
    func clearCompanyHeaderImagePath(companyId: UUID) async throws {
        struct ClearHeaderImagePayload: Encodable {
            enum CodingKeys: String, CodingKey {
                case headerImagePath = "header_image_path"
            }

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encodeNil(forKey: .headerImagePath)
            }
        }

        struct UpdatedCompany: Decodable {
            let id: UUID
            let headerImagePath: String?

            enum CodingKeys: String, CodingKey {
                case id
                case headerImagePath = "header_image_path"
            }
        }

        let updatedCompanies: [UpdatedCompany] = try await client
            .from("companies")
            .update(ClearHeaderImagePayload())
            .eq("id", value: companyId)
            .select("id, header_image_path")
            .execute()
            .value

        guard updatedCompanies.count == 1,
              updatedCompanies[0].headerImagePath == nil else {
            throw CompanyImageUpdateError.headerRemovalFailed
        }
    }
    
    
    private enum CompanyImageUpdateError: LocalizedError {
        case headerRemovalFailed

        var errorDescription: String? {
            switch self {
            case .headerRemovalFailed:
                return "Das Firmenbanner konnte in der Datenbank nicht entfernt werden."
            }
        }
    }
    
    func fetchOwnMembership(
        userId: UUID
    ) async throws -> CompanyMembership? {
        let memberships: [CompanyMembership] = try await client
            .from("company_memberships")
            .select(
                """
                id,
                company_id,
                user_id,
                role,
                verification_status
                """
            )
            .eq("user_id", value: userId)
            .limit(1)
            .execute()
            .value
        
        return memberships.first
    }
    
    func fetchCompany(
        companyId: UUID
    ) async throws -> Company {
        try await client
            .from("companies")
            .select(
                """
                id,
                name,
                description,
                industry,
                company_size,
                legal_form,
                website,
                logo_path,
                header_image_path,
                location,
                location_latitude,
                location_longitude,
                address_street,
                address_house_number,
                address_postal_code,
                address_city,
                contact_first_name,
                contact_last_name,
                contact_email,
                contact_phone,
                onboarding_completed
                """
            )
            .eq("id", value: companyId)
            .single()
            .execute()
            .value
    }
    
    func createCompany(
        name: String,
        description: String?,
        industry: String?,
        companySize: String?,
        website: String?,
        location: String?,
        contactFirstName: String?,
        contactLastName: String?,
        contactEmail: String?,
        contactPhone: String?,
        legalForm: String? = nil,
        locationLatitude: Double? = nil,
        locationLongitude: Double? = nil,
        addressStreet: String? = nil,
        addressHouseNumber: String? = nil,
        addressPostalCode: String? = nil,
        addressCity: String? = nil
    ) async throws -> UUID {
        
        struct Parameters: Encodable {
            let name: String
            let description: String?
            let industry: String?
            let companySize: String?
            let website: String?
            let location: String?
            
            let contactFirstName: String?
            let contactLastName: String?
            let contactEmail: String?
            let contactPhone: String?
            
            let legalForm: String?
            let locationLatitude: Double?
            let locationLongitude: Double?
            
            let addressStreet: String?
            let addressHouseNumber: String?
            let addressPostalCode: String?
            let addressCity: String?
            
            enum CodingKeys: String, CodingKey {
                case name = "p_name"
                case description = "p_description"
                case industry = "p_industry"
                case companySize = "p_company_size"
                case website = "p_website"
                case location = "p_location"
                
                case contactFirstName = "p_contact_first_name"
                case contactLastName = "p_contact_last_name"
                case contactEmail = "p_contact_email"
                case contactPhone = "p_contact_phone"
                
                case legalForm = "p_legal_form"
                case locationLatitude = "p_location_latitude"
                case locationLongitude = "p_location_longitude"
                
                case addressStreet = "p_address_street"
                case addressHouseNumber = "p_address_house_number"
                case addressPostalCode = "p_address_postal_code"
                case addressCity = "p_address_city"
            }
        }
        
        let parameters = Parameters(
            name: name,
            description: description,
            industry: industry,
            companySize: companySize,
            website: website,
            location: location,
            
            contactFirstName: contactFirstName,
            contactLastName: contactLastName,
            contactEmail: contactEmail,
            contactPhone: contactPhone,
            
            legalForm: legalForm,
            locationLatitude: locationLatitude,
            locationLongitude: locationLongitude,
            
            addressStreet: addressStreet,
            addressHouseNumber: addressHouseNumber,
            addressPostalCode: addressPostalCode,
            addressCity: addressCity
        )
        
        return try await client
            .rpc(
                "create_employer_company",
                params: parameters
            )
            .execute()
            .value
    }
    
    func updateCompany(
        companyId: UUID,
        name: String,
        description: String?,
        industry: String?,
        companySize: String?,
        website: String?,
        location: String?,
        contactFirstName: String?,
        contactLastName: String?,
        contactEmail: String?,
        contactPhone: String?,
        locationLatitude: Double? = nil,
        locationLongitude: Double? = nil,
        legalForm: String? = nil,
        addressStreet: String? = nil,
        addressHouseNumber: String? = nil,
        addressPostalCode: String? = nil,
        addressCity: String? = nil
    ) async throws {
        
        struct Payload: Encodable {
            let name: String
            let description: String?
            let industry: String?
            let companySize: String?
            let legalForm: String?
            let website: String?
            let location: String?
            let locationLatitude: Double?
            let locationLongitude: Double?
            
            let addressStreet: String?
            let addressHouseNumber: String?
            let addressPostalCode: String?
            let addressCity: String?
            
            let contactFirstName: String?
            let contactLastName: String?
            let contactEmail: String?
            let contactPhone: String?
            let onboardingCompleted: Bool
            
            enum CodingKeys: String, CodingKey {
                case name
                case description
                case industry
                case companySize = "company_size"
                case legalForm = "legal_form"
                case website
                case location
                case locationLatitude = "location_latitude"
                case locationLongitude = "location_longitude"
                
                case addressStreet = "address_street"
                case addressHouseNumber = "address_house_number"
                case addressPostalCode = "address_postal_code"
                case addressCity = "address_city"
                
                case contactFirstName = "contact_first_name"
                case contactLastName = "contact_last_name"
                case contactEmail = "contact_email"
                case contactPhone = "contact_phone"
                case onboardingCompleted = "onboarding_completed"
            }
        }
        
        let payload = Payload(
            name: name,
            description: description,
            industry: industry,
            companySize: companySize,
            legalForm: legalForm,
            website: website,
            location: location,
            locationLatitude: locationLatitude,
            locationLongitude: locationLongitude,
            
            addressStreet: addressStreet,
            addressHouseNumber: addressHouseNumber,
            addressPostalCode: addressPostalCode,
            addressCity: addressCity,
            
            contactFirstName: contactFirstName,
            contactLastName: contactLastName,
            contactEmail: contactEmail,
            contactPhone: contactPhone,
            onboardingCompleted: true
        )
        
        try await client
            .from("companies")
            .update(payload)
            .eq("id", value: companyId)
            .execute()
    }
    
    // MARK: - Company Branding

    enum CompanyImageField {
        case logo
        case header

        var columnName: String {
            switch self {
            case .logo:
                return "logo_path"
            case .header:
                return "header_image_path"
            }
        }
    }
    
    



    // MARK: - Remove Company Logo

    func clearCompanyLogoPath(
        companyId: UUID
    ) async throws {

        struct Payload: Encodable {
            let logoPath: String?

            enum CodingKeys: String, CodingKey {
                case logoPath = "logo_path"
            }

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(
                    keyedBy: CodingKeys.self
                )

                // NULL ausdrücklich in JSON schreiben.
                try container.encodeNil(forKey: .logoPath)
            }
        }

        struct UpdatedCompany: Decodable {
            let id: UUID
            let logoPath: String?

            enum CodingKeys: String, CodingKey {
                case id
                case logoPath = "logo_path"
            }
        }

        let updatedCompanies: [UpdatedCompany] = try await client
            .from("companies")
            .update(Payload(logoPath: nil))
            .eq("id", value: companyId)
            .select("id, logo_path")
            .execute()
            .value

        guard let updatedCompany = updatedCompanies.first else {
            throw CompanyLogoError.updateNotPermitted
        }

        guard updatedCompany.logoPath == nil else {
            throw CompanyLogoError.logoPathNotCleared
        }
    }

    private enum CompanyLogoError: LocalizedError {
        case updateNotPermitted
        case logoPathNotCleared

        var errorDescription: String? {
            switch self {
            case .updateNotPermitted:
                return "Das Firmenlogo konnte nicht zurückgesetzt werden. Bitte die Unternehmensberechtigung prüfen."

            case .logoPathNotCleared:
                return "Der Logo-Pfad wurde nicht aus dem Unternehmensprofil entfernt."
            }
        }
    }

    func updateCompanyImagePath(
        companyId: UUID,
        path: String,
        field: CompanyImageField
    ) async throws {

        let payload = [
            field.columnName: path
        ]

        try await client
            .from("companies")
            .update(payload)
            .eq("id", value: companyId)
            .execute()
    }
}
