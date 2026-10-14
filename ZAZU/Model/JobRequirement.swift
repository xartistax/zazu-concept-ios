//
//  JobRequirement.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 29.09.2026.
//

import Foundation

struct JobSkillRequirement: Decodable, Sendable {
    let jobId: UUID
    let skillId: UUID
    let minimumProficiency: SkillProficiency
    let requirementType: RequirementType

    enum CodingKeys: String, CodingKey {
        case jobId = "job_id"
        case skillId = "skill_id"
        case minimumProficiency = "minimum_proficiency"
        case requirementType = "requirement_type"
    }
}

struct JobLanguageRequirement: Decodable, Sendable {
    let jobId: UUID
    let languageId: UUID
    let minimumProficiency: LanguageProficiency
    let requirementType: RequirementType

    enum CodingKeys: String, CodingKey {
        case jobId = "job_id"
        case languageId = "language_id"
        case minimumProficiency = "minimum_proficiency"
        case requirementType = "requirement_type"
    }
}
