//
//  EducationCatalog.swift
//  ZAZU
//
//  Created by Demian on 30.10.2026.
//



import Foundation

struct EducationType: Identifiable, Decodable, Sendable {
    let id: UUID
    let code: String
    let nameDe: String
    let sortOrder: Int

    enum CodingKeys: String, CodingKey {
        case id, code
        case nameDe = "name_de"
        case sortOrder = "sort_order"
    }
}

struct EducationTypeDegree: Identifiable, Decodable, Sendable {
    let id: UUID
    let educationTypeId: UUID
    let nameDe: String
    let note: String?
    let sortOrder: Int

    enum CodingKeys: String, CodingKey {
        case id
        case educationTypeId = "education_type_id"
        case nameDe = "name_de"
        case note
        case sortOrder = "sort_order"
    }
}

struct EducationField: Identifiable, Decodable, Sendable {
    let id: UUID
    let code: String
    let nameDe: String
    let parentId: UUID?
    let fieldKind: String?
    let countryCode: String?

    enum CodingKeys: String, CodingKey {
        case id, code
        case nameDe = "name_de"
        case parentId = "parent_id"
        case fieldKind = "field_kind"
        case countryCode = "country_code"
    }
}

struct EducationInstitutionType: Identifiable, Decodable, Sendable {
    let id: UUID
    let nameDe: String
    let typicalEducationType: String?
    let countries: [String]
    let note: String?
    let sortOrder: Int

    enum CodingKeys: String, CodingKey {
        case id
        case nameDe = "name_de"
        case typicalEducationType = "typical_education_type"
        case countries, note
        case sortOrder = "sort_order"
    }
}

struct EducationInstitution: Identifiable, Decodable, Sendable {
    let id: UUID
    let institutionTypeId: UUID
    let name: String
    let countryCode: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case institutionTypeId = "institution_type_id"
        case countryCode = "country_code"
    }
}
