//
//  SkillCategory.swift
//  ZAZU
//
//  Created by Demian on 31.10.2026.
//

import Foundation

struct SkillCategory: Identifiable, Decodable, Sendable {
    let id: UUID
    let name: String
    let sortOrder: Int

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case sortOrder = "sort_order"
    }
}
