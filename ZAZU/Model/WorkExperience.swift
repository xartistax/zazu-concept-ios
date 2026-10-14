//
//  WorkExperience.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import Foundation

struct WorkExperience: Identifiable, Decodable, Sendable {
    let id: UUID
    let candidateId: UUID

    let jobTitle: String
    let employerName: String
    let location: String?

    let startDate: String
    let endDate: String?
    let isCurrent: Bool

    let description: String?

    enum CodingKeys: String, CodingKey {
        case id
        case candidateId = "candidate_id"
        case jobTitle = "job_title"
        case employerName = "employer_name"
        case location
        case startDate = "start_date"
        case endDate = "end_date"
        case isCurrent = "is_current"
        case description
    }
    
    
    
}
