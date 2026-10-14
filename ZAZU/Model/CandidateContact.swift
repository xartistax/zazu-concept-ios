//
//  CandidateContact.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 10.10.2026.
//

import Foundation

struct CandidateContact: Decodable, Sendable {
    let firstName: String?
    let lastName: String?
    let phoneNumber: String?

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case phoneNumber = "phone_number"
    }

    var fullName: String {
        [firstName, lastName]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}
