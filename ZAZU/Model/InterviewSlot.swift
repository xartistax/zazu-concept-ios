//
//  InterviewSlot.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 03.10.2026.
//

import Foundation

struct InterviewSlot: Identifiable, Decodable, Sendable, Hashable {
    let id: UUID
    let matchId: UUID
    let startsAt: Date
    let endsAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case matchId = "match_id"
        case startsAt = "starts_at"
        case endsAt = "ends_at"
    }
}
