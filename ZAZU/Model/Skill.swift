//
//  Skill.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//


import Foundation

struct Skill: Identifiable, Decodable, Sendable {
    let id: UUID
    let name: String
    let category: String
    let categoryId: UUID?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case category
        case categoryId = "category_id"
    }
}
