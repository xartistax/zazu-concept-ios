//
//  SelectedAddress.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 13.10.2026.
//

import Foundation

struct SelectedAddress: Identifiable, Equatable, Sendable {
    let street: String
    let houseNumber: String
    let postalCode: String
    let city: String
    let latitude: Double
    let longitude: Double

    var id: String {
        "\(street)|\(houseNumber)|\(postalCode)|\(city)"
    }

    var formattedAddress: String {
        "\(street) \(houseNumber), \(postalCode) \(city)"
    }

    var selectedLocation: SelectedLocation {
        SelectedLocation(
            name: city,
            latitude: latitude,
            longitude: longitude
        )
    }
}
