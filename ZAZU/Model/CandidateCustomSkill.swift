//
//  CandidateCustomSkill.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 05.10.2026.
//

import Foundation

struct CandidateCustomSkill: Identifiable, Decodable, Sendable {
    let id: UUID
    let candidateId: UUID
    let name: String
    let proficiency: SkillProficiency

    enum CodingKeys: String, CodingKey {
        case id
        case candidateId = "candidate_id"
        case name
        case proficiency
    }
}
