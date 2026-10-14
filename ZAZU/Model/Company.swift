//
//  Company.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 29.09.2026.
//

import Foundation

struct Company: Decodable, Sendable, Identifiable {

    // MARK: - Identity

    let id: UUID

    // MARK: - Company Information

    let name: String
    let description: String?
    let industry: String?
    let companySize: String?
    let legalForm: String?
    let website: String?
    
    // MARK: - Branding
    let logoPath: String?
    let headerImagePath: String?

    // MARK: - Location

    let location: String?
    let locationLatitude: Double?
    let locationLongitude: Double?

    // MARK: - Address

    let addressStreet: String?
    let addressHouseNumber: String?
    let addressPostalCode: String?
    let addressCity: String?

    // MARK: - Contact

    let contactFirstName: String?
    let contactLastName: String?
    let contactEmail: String?
    let contactPhone: String?

    // MARK: - Onboarding

    let onboardingCompleted: Bool

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case industry
        case companySize = "company_size"
        case legalForm = "legal_form"
        case website
        
        // Branding
        case logoPath = "logo_path"
        case headerImagePath = "header_image_path"

        // Location
        case location
        case locationLatitude = "location_latitude"
        case locationLongitude = "location_longitude"

        // Address
        case addressStreet = "address_street"
        case addressHouseNumber = "address_house_number"
        case addressPostalCode = "address_postal_code"
        case addressCity = "address_city"

        // Contact
        case contactFirstName = "contact_first_name"
        case contactLastName = "contact_last_name"
        case contactEmail = "contact_email"
        case contactPhone = "contact_phone"

        // Onboarding
        case onboardingCompleted = "onboarding_completed"
    }
}
