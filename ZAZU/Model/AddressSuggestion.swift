//
//  AddressSuggestion.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 13.10.2026.
//

import Foundation

struct AddressSuggestion: Identifiable, Equatable, Sendable {
    let title: String
    let subtitle: String

    var id: String {
        "\(title)|\(subtitle)"
    }

    var displayText: String {
        subtitle.isEmpty
            ? title
            : "\(title), \(subtitle)"
    }
}
