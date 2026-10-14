//
//  AddressAutocompleteService.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 13.10.2026.
//

import Foundation
import MapKit
import Observation

@MainActor
@Observable
final class AddressAutocompleteService: NSObject {

    private(set) var suggestions: [AddressSuggestion] = []
    private(set) var isSearching = false
    private(set) var errorMessage: String?

    @ObservationIgnored
    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()

        completer.delegate = self
        completer.resultTypes = .address

        completer.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 46.8182,
                longitude: 8.2275
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 3.5,
                longitudeDelta: 5.5
            )
        )
    }

    func search(query: String) {
        let trimmedQuery = query.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard trimmedQuery.count >= 3 else {
            completer.queryFragment = ""
            suggestions = []
            isSearching = false
            errorMessage = nil
            return
        }

        suggestions = []
        errorMessage = nil
        isSearching = true

        completer.queryFragment = trimmedQuery
    }

    func clear() {
        completer.queryFragment = ""
        suggestions = []
        isSearching = false
        errorMessage = nil
    }
}

// MARK: - MKLocalSearchCompleterDelegate

extension AddressAutocompleteService: MKLocalSearchCompleterDelegate {

    nonisolated func completerDidUpdateResults(
        _ completer: MKLocalSearchCompleter
    ) {
        let results = completer.results.map {
            AddressSuggestion(
                title: $0.title,
                subtitle: $0.subtitle
            )
        }

        Task { @MainActor [weak self] in
            guard let self else { return }

            self.suggestions = results
            self.isSearching = false
            self.errorMessage = nil
        }
    }

    nonisolated func completer(
        _ completer: MKLocalSearchCompleter,
        didFailWithError error: Error
    ) {
        Task { @MainActor [weak self] in
            guard let self else { return }

            self.suggestions = []
            self.isSearching = false
            self.errorMessage =
                "Die Adressvorschläge sind momentan nicht verfügbar."
        }
    }
}
