//
//  OnboardingViewModel.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class OnboardingViewModel {

    var currentStep = 0
    var region = ""
    var selectedRegion: SelectedLocation?
    var nationality = ""
    var hasWorkAuthorization = true
    var workAuthorizationDetails = ""
    var isInitialLoading = true
    var isLoading = false
    var errorMessage: String?
    var firstName = ""
    var lastName = ""
    var phoneNumber = ""

    private let profileRepository: ProfileRepository
    private let repository: CandidateProfileRepository
    private let userId: UUID

    init(
        repository: CandidateProfileRepository,
        profileRepository: ProfileRepository,
        userId: UUID
    ) {
        self.repository = repository
        self.profileRepository = profileRepository
        self.userId = userId
    }

    var canContinue: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedRegion != nil &&
        !nationality.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !isLoading

    }

    func load() async {
        guard isInitialLoading else {
            return
        }

        errorMessage = nil

        do {
            async let candidateProfileRequest =
                repository.fetchProfile(userId: userId)

            async let profileRequest =
                profileRepository.fetchProfile(userId: userId)

            let (
                candidateProfile,
                accountProfile
            ) = try await (
                candidateProfileRequest,
                profileRequest
            )

            // Allgemeine Profildaten
            firstName = accountProfile.firstName ?? ""
            lastName = accountProfile.lastName ?? ""
            phoneNumber = accountProfile.phoneNumber ?? ""

            // Kandidatenprofil
            region = candidateProfile.region ?? ""

            if let name = candidateProfile.region,
               let latitude = candidateProfile.regionLatitude,
               let longitude = candidateProfile.regionLongitude,
               !name.isEmpty {
                selectedRegion = SelectedLocation(
                    name: name,
                    latitude: latitude,
                    longitude: longitude
                )
            } else {
                selectedRegion = nil
            }

            nationality = candidateProfile.nationality ?? ""

            hasWorkAuthorization =
                candidateProfile.hasWorkAuthorization ?? false

            workAuthorizationDetails =
                candidateProfile.workAuthorizationDetails ?? ""


            // Persistierten Onboarding-Fortschritt wiederherstellen
            currentStep = candidateProfile.onboardingStep

        } catch {
            errorMessage = error.localizedDescription
        }

        isInitialLoading = false
    }

    func saveBasicInformation() async -> Bool {
        guard canContinue else {
            return false
        }
        
        guard let selectedRegion else {
            errorMessage = "Bitte wähle einen gültigen Wohnort aus."
            return false
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {

            try await profileRepository.updateBasicInformation(
                userId: userId,
                firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
                phoneNumber: normalizedPhoneNumber
            )

            try await repository.updateBasicInformation(
                userId: userId,
                region: selectedRegion.name,
                regionLatitude: selectedRegion.latitude,
                regionLongitude: selectedRegion.longitude,
                nationality: nationality.trimmingCharacters(in: .whitespacesAndNewlines),
                hasWorkAuthorization: hasWorkAuthorization,
                workAuthorizationDetails: normalizedWorkAuthorizationDetails
            )

            currentStep = max(currentStep, 1)

            return true

        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private var normalizedWorkAuthorizationDetails: String? {
        let value = workAuthorizationDetails
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return value.isEmpty ? nil : value
    }
    
    
    private var normalizedPhoneNumber: String? {
        let value = phoneNumber
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return value.isEmpty ? nil : value
    }
}
