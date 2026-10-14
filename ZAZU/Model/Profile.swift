//
//  Profile.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//
import Foundation

struct Profile: Decodable, Sendable {
    let id: UUID
    let firstName: String?
    let lastName: String?
    let phoneNumber: String?
    let accountRole: AccountRole

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case phoneNumber = "phone_number"
        case accountRole = "account_role"
    }
}
