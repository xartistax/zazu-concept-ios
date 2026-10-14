//
//  CompanyContact.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 14.10.2026.
//

import Foundation

struct CompanyContact: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    let companyId: UUID

    var firstName: String
    var lastName: String
    var position: String?
    var email: String?
    var phone: String?
    var portraitPath: String?

    let createdAt: Date
    let updatedAt: Date

    var fullName: String {
        "\(firstName) \(lastName)"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case companyId = "company_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case position
        case email
        case phone
        case portraitPath = "portrait_path"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
