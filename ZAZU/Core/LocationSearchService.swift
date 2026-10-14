//
//  LocationSearchService.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 12.10.2026.
//


import Foundation
import MapKit

@MainActor
final class LocationSearchService {

    func search(
        query: String
    ) async throws -> [SelectedLocation] {
        let trimmedQuery = query.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedQuery.isEmpty else {
            return []
        }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = trimmedQuery
        request.resultTypes = .address

        // Bevorzugt Ergebnisse aus der Schweiz.
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 46.8182,
                longitude: 8.2275
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 3.5,
                longitudeDelta: 5.5
            )
        )

        let search = MKLocalSearch(request: request)
        let response = try await search.start()

        var seenNames = Set<String>()

        return response.mapItems.compactMap { item in
            let placemark = item.placemark

            // Nur Ergebnisse aus der Schweiz.
            guard placemark.isoCountryCode == "CH" else {
                return nil
            }

            // Nur Ortschaften, keine einzelnen Adressen.
            guard placemark.thoroughfare == nil,
                  placemark.subThoroughfare == nil,
                  let locality = placemark.locality,
                  !locality.isEmpty else {
                return nil
            }

            let coordinate = placemark.coordinate

            guard CLLocationCoordinate2DIsValid(coordinate) else {
                return nil
            }

            let normalizedName = locality
                .folding(
                    options: [.caseInsensitive, .diacriticInsensitive],
                    locale: Locale(identifier: "de_CH")
                )

            guard seenNames.insert(normalizedName).inserted else {
                return nil
            }

            return SelectedLocation(
                name: locality,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )
        }
    }
    
    
    // MARK: - Adresssuche

    func searchAddresses(
        query: String
    ) async throws -> [SelectedAddress] {
        let trimmedQuery = query.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard trimmedQuery.count >= 3 else {
            return []
        }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = trimmedQuery
        request.resultTypes = .address

        // Schweizer Adressen bevorzugen.
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 46.8182,
                longitude: 8.2275
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 3.5,
                longitudeDelta: 5.5
            )
        )

        let search = MKLocalSearch(request: request)
        let response = try await search.start()

        var seenAddresses = Set<String>()

        return response.mapItems.compactMap { item in
            let placemark = item.placemark

            // Nur Adressen aus der Schweiz.
            guard placemark.isoCountryCode == "CH" else {
                return nil
            }

            // Vollständige Postadresse erforderlich.
            guard
                let street = placemark.thoroughfare,
                !street.isEmpty,
                let houseNumber = placemark.subThoroughfare,
                !houseNumber.isEmpty,
                let postalCode = placemark.postalCode,
                !postalCode.isEmpty,
                let city = placemark.locality,
                !city.isEmpty
            else {
                return nil
            }

            let coordinate = placemark.coordinate

            guard CLLocationCoordinate2DIsValid(coordinate) else {
                return nil
            }

            let address = SelectedAddress(
                street: street,
                houseNumber: houseNumber,
                postalCode: postalCode,
                city: city,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )

            // Doppelte Suchergebnisse entfernen.
            guard seenAddresses.insert(address.id).inserted else {
                return nil
            }

            return address
        }
    }
    
    // MARK: - Adressvorschlag auflösen

    func resolveAddress(
        suggestion: AddressSuggestion
    ) async throws -> SelectedAddress? {

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = suggestion.displayText
        request.resultTypes = .address

        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 46.8182,
                longitude: 8.2275
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 3.5,
                longitudeDelta: 5.5
            )
        )

        let response = try await MKLocalSearch(
            request: request
        ).start()

        for item in response.mapItems {
            let placemark = item.placemark

            guard placemark.isoCountryCode == "CH",
                  let street = placemark.thoroughfare,
                  !street.isEmpty,
                  let houseNumber = placemark.subThoroughfare,
                  !houseNumber.isEmpty,
                  let postalCode = placemark.postalCode,
                  !postalCode.isEmpty,
                  let city = placemark.locality,
                  !city.isEmpty
            else {
                continue
            }

            let coordinate = placemark.coordinate

            guard CLLocationCoordinate2DIsValid(coordinate) else {
                continue
            }

            return SelectedAddress(
                street: street,
                houseNumber: houseNumber,
                postalCode: postalCode,
                city: city,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )
        }

        return nil
    }
}
