//
//  Interview.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 03.10.2026.
//

import Foundation

struct Interview: Identifiable, Decodable, Sendable, Hashable {
    let id: UUID
    let matchId: UUID
    let interviewSlotId: UUID
    let confirmedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case matchId = "match_id"
        case interviewSlotId = "interview_slot_id"
        case confirmedAt = "confirmed_at"
    }
}
