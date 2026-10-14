//
//  Education.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import Foundation

struct Education: Identifiable, Decodable, Sendable {
    let id: UUID
    let candidateId: UUID

    let institutionName: String
    let degree: String
    let fieldOfStudy: String?

    let startDate: String?
    let endDate: String?
    let isCurrent: Bool

    let description: String?

    enum CodingKeys: String, CodingKey {
        case id
        case candidateId = "candidate_id"
        case institutionName = "institution_name"
        case degree
        case fieldOfStudy = "field_of_study"
        case startDate = "start_date"
        case endDate = "end_date"
        case isCurrent = "is_current"
        case description
    }
}
