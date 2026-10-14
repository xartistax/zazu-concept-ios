//
//  ZAZUColors.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import SwiftUI

enum ZAZUColors {
    static let primary = Color(hex: "#6D3DF5")
    static let deepPurple = Color(hex: "#4520A8")
    static let lightPurple = Color(hex: "#EEE9FF")
    static let veryLightPurple = Color(hex: "#F8F6FF")

    static let textPrimary = Color(hex: "#17151C")
    static let textSecondary = Color(hex: "#706D78")
    static let white = Color.white
    
    static let danger = Color.orange
    static let success = Color.green
}

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0

        Scanner(string: hex).scanHexInt64(&value)

        let red = Double((value >> 16) & 0xFF) / 255
        let green = Double((value >> 8) & 0xFF) / 255
        let blue = Double(value & 0xFF) / 255

        self.init(red: red, green: green, blue: blue)
    }
}
