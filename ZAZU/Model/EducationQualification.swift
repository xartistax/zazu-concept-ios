//
//  EducationQualification.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 18.10.2026.
//

import Foundation

struct EducationQualification: Identifiable, Decodable, Hashable, Sendable {
    let id: UUID
    let educationLevel: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case id
        case educationLevel = "education_level"
        case name
    }
}
