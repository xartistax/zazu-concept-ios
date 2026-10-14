//
//  JobPreferencesViewModel.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class JobPreferencesViewModel {

    var desiredWorkloadMin = 80
    var desiredWorkloadMax = 100

    var desiredWorkLocation = ""
    var selectedLocation: SelectedLocation?
    var workRadiusKm = 30

    var willingToCommute = true
    var willingToRelocate = false

    var earliestStartDate = Date()

    var isInitialLoading = true
    var isSaving = false
    var errorMessage: String?

    private let repository: CandidateProfileRepository
    private let userId: UUID

    init(
        repository: CandidateProfileRepository,
        userId: UUID
    ) {
        self.repository = repository
        self.userId = userId
    }

    // MARK: - Validation

    var canContinue: Bool {
        selectedLocation != nil
        &&
        desiredWorkloadMin <= desiredWorkloadMax
        &&
        !isSaving
    }

    // MARK: - Load

    func load() async {
        guard isInitialLoading else {
            return
        }

        errorMessage = nil

        do {
            let profile = try await repository.fetchProfile(
                userId: userId
            )

            desiredWorkloadMin =
                profile.desiredWorkloadMin ?? 80

            desiredWorkloadMax =
                profile.desiredWorkloadMax ?? 100

            desiredWorkLocation =
                profile.desiredWorkLocation ?? ""
            
            if let latitude = profile.desiredWorkLatitude,
               let longitude = profile.desiredWorkLongitude,
               let name = profile.desiredWorkLocation,
               !name.isEmpty {
                selectedLocation = SelectedLocation(
                    name: name,
                    latitude: latitude,
                    longitude: longitude
                )
            } else {
                selectedLocation = nil
            }

            workRadiusKm =
                profile.workRadiusKm ?? 30

            willingToCommute =
                profile.willingToCommute ?? true

            willingToRelocate =
                profile.willingToRelocate ?? false

            if let value = profile.earliestStartDate,
               let date = Self.dateOnlyFormatter.date(from: value) {
                earliestStartDate = date
            }

        } catch {
            errorMessage = error.localizedDescription
        }

        isInitialLoading = false
    }

    // MARK: - Save

    func save() async -> Bool {
        guard canContinue else {
            return false
        }

        isSaving = true
        errorMessage = nil

        defer {
            isSaving = false
        }

        guard let selectedLocation else {
            errorMessage = "Bitte wähle einen gültigen Arbeitsort aus."
            return false
        }

        let location = selectedLocation.name

        do {
            try await repository.updateJobPreferences(
                userId: userId,
                desiredWorkloadMin: desiredWorkloadMin,
                desiredWorkloadMax: desiredWorkloadMax,
                desiredWorkLocation: location,
                desiredWorkLatitude: selectedLocation.latitude,
                desiredWorkLongitude: selectedLocation.longitude,
                workRadiusKm: workRadiusKm,
                willingToCommute: willingToCommute,
                willingToRelocate: willingToRelocate,
                earliestStartDate: earliestStartDate
            )

            return true

        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Location

    private static func coordinates(
        for location: String
    ) -> (
        latitude: Double,
        longitude: Double
    )? {
        switch normalizedLocation(location) {
        case "zürich", "zurich":
            return (
                latitude: 47.3769,
                longitude: 8.5417
            )

        case "baden":
            return (
                latitude: 47.4733,
                longitude: 8.3059
            )

        case "basel":
            return (
                latitude: 47.5596,
                longitude: 7.5886
            )

        case "bern":
            return (
                latitude: 46.9480,
                longitude: 7.4474
            )

        default:
            return nil
        }
    }

    private static func normalizedLocation(
        _ location: String
    ) -> String {
        location
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .lowercased()
    }

    // MARK: - Date

    private static let dateOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar =
            Calendar(identifier: .gregorian)
        formatter.locale =
            Locale(identifier: "en_US_POSIX")
        formatter.timeZone =
            TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
