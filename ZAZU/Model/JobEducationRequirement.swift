//
//  JobEducationRequirement.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 04.10.2026.
//

import Foundation

struct JobEducationRequirement: Identifiable, Decodable, Sendable {
    let id: UUID
    let jobId: UUID

    let degree: String
    let fieldOfStudy: String?
    let requirementType: RequirementType

    enum CodingKeys: String, CodingKey {
        case id
        case jobId = "job_id"
        case degree
        case fieldOfStudy = "field_of_study"
        case requirementType = "requirement_type"
    }
}
