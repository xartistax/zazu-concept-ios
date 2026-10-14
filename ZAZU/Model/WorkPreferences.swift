//
//  WorkPreferences.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import Foundation

enum PreferredWorkModel: String, Codable, CaseIterable, Sendable {
    case onsite
    case hybrid
    case remote

    var title: String {
        switch self {
        case .onsite:
            return "Vor Ort"
        case .hybrid:
            return "Hybrid"
        case .remote:
            return "Remote"
        }
    }
}

enum HomeofficePreference: String, Codable, CaseIterable, Sendable {
    case yes
    case no
    case either

    var title: String {
        switch self {
        case .yes:
            return "Ja"
        case .no:
            return "Nein"
        case .either:
            return "Egal"
        }
    }
}

enum HomeofficeSchedulePreference: String, Codable, CaseIterable, Sendable {
    case fixed
    case flexible
    case either

    var title: String {
        switch self {
        case .fixed:
            return "Fixe Tage"
        case .flexible:
            return "Flexible Tage"
        case .either:
            return "Egal"
        }
    }
}
