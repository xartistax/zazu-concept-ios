//
//  WorkAndSalaryViewModel.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class WorkAndSalaryViewModel {

    var preferredWorkModel: PreferredWorkModel = .hybrid

    var homeofficePreference: HomeofficePreference = .yes
    var desiredHomeofficeDays = 2
    var preferredHomeofficeSchedule: HomeofficeSchedulePreference = .flexible
    var acceptsFullyRemote = true

    var salaryMin = 80_000
    var salaryMax = 100_000

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
        salaryMin >= 0 &&
        salaryMax >= salaryMin &&
        desiredHomeofficeDays >= 0 &&
        desiredHomeofficeDays <= 5 &&
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

            preferredWorkModel =
                profile.preferredWorkModel ?? .hybrid

            homeofficePreference =
                profile.homeofficePreference ?? .yes

            desiredHomeofficeDays =
                profile.desiredHomeofficeDays ?? 2

            preferredHomeofficeSchedule =
                profile.preferredHomeofficeSchedule ?? .flexible

            acceptsFullyRemote =
                profile.acceptsFullyRemote ?? true

            salaryMin =
                profile.salaryMin ?? 80_000

            salaryMax =
                profile.salaryMax ?? 100_000

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

        do {
            try await repository.updateWorkAndSalaryPreferences(
                userId: userId,
                preferredWorkModel: preferredWorkModel,
                homeofficePreference: homeofficePreference,
                desiredHomeofficeDays: desiredHomeofficeDays,
                preferredHomeofficeSchedule: preferredHomeofficeSchedule,
                acceptsFullyRemote: acceptsFullyRemote,
                salaryMin: salaryMin,
                salaryMax: salaryMax
            )

            return true

        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
