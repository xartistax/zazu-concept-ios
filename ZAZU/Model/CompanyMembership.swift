//
//  CompanyMembership.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 07.10.2026.
//

import Foundation

struct CompanyMembership: Decodable, Sendable {
    let id: UUID
    let companyId: UUID
    let userId: UUID
    let role: CompanyMembershipRole
    let verificationStatus: CompanyVerificationStatus

    enum CodingKeys: String, CodingKey {
        case id
        case companyId = "company_id"
        case userId = "user_id"
        case role
        case verificationStatus = "verification_status"
    }
}

enum CompanyMembershipRole: String, Codable, Sendable {
    case admin
    case member
}

enum CompanyVerificationStatus: String, Codable, Sendable {
    case unverified
    case pending
    case verified
}
