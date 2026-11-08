//
//  CandidateSkill.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import Foundation

enum SkillProficiency: String, Codable, CaseIterable, Sendable {
    case beginner
    case basic
    case good
    case veryGood = "very_good"
    case expert

    var title: String {
        switch self {
        case .beginner:
            return "Anfänger"
        case .basic:
            return "Grundkenntnisse"
        case .good:
            return "Fortgeschritten"
        case .veryGood:
            return "Sehr gut"
        case .expert:
            return "Experte"
        }
    }
}

struct CandidateSkill: Decodable, Sendable {
    let candidateId: UUID
    let skillId: UUID
    let proficiency: SkillProficiency

    enum CodingKeys: String, CodingKey {
        case candidateId = "candidate_id"
        case skillId = "skill_id"
        case proficiency
    }
}
