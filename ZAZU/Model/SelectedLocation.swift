//
//  SelectedLocation.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 12.10.2026.
//

//
//  SelectedLocation.swift
//  ZAZU
//

import Foundation

struct SelectedLocation: Identifiable, Hashable, Sendable {
    let name: String
    let latitude: Double
    let longitude: Double

    var id: String {
        "\(latitude),\(longitude)"
    }

    init(
        name: String,
        latitude: Double,
        longitude: Double
    ) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}
