//
//  CandidateLanguage.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import Foundation

enum LanguageProficiency: String, Codable, CaseIterable, Sendable {
    case a1
    case a2
    case b1
    case b2
    case c1
    case c2
    case native

    var title: String {
        switch self {
        case .a1:
            return "A1 – Anfänger"
        case .a2:
            return "A2 – Grundlegende Kenntnisse"
        case .b1:
            return "B1 – Fortgeschrittene Sprachverwendung"
        case .b2:
            return "B2 – Selbstständige Sprachverwendung"
        case .c1:
            return "C1 – Fachkundige Sprachkenntnisse"
        case .c2:
            return "C2 – Annähernd muttersprachlich"
        case .native:
            return "Muttersprache"
        }
    }
}

struct CandidateLanguage: Decodable, Sendable {
    let candidateId: UUID
    let languageId: UUID
    let proficiency: LanguageProficiency

    enum CodingKeys: String, CodingKey {
        case candidateId = "candidate_id"
        case languageId = "language_id"
        case proficiency
    }
}
