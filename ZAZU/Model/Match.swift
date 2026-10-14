//
//  Match.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 03.10.2026.
//

import Foundation

struct Match: Identifiable, Decodable, Sendable {
    let id: UUID
    let candidateId: UUID
    let jobId: UUID
    let matchedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case candidateId = "candidate_id"
        case jobId = "job_id"
        case matchedAt = "matched_at"
    }
}
