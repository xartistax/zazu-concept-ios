//
//  WorkExperienceViewModel.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class WorkExperienceViewModel {

    var experiences: [WorkExperience] = []

    var jobTitle = ""
    var employerName = ""
    var location = ""

    var startDate = Date()
    var endDate = Date()
    var isCurrent = false

    var description = ""

    var isLoading = false
    var isSaving = false
    var errorMessage: String?

    private let workExperienceRepository: WorkExperienceRepository
    private let candidateProfileRepository: CandidateProfileRepository
    private let candidateId: UUID

    init(
        workExperienceRepository: WorkExperienceRepository,
        candidateProfileRepository: CandidateProfileRepository,
        candidateId: UUID
    ) {
        self.workExperienceRepository = workExperienceRepository
        self.candidateProfileRepository = candidateProfileRepository
        self.candidateId = candidateId
    }

    var canSaveExperience: Bool {
        !jobTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !employerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (isCurrent || endDate >= startDate) &&
        !isSaving
    }

    func load() async {
        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            experiences = try await workExperienceRepository.fetchAll(
                candidateId: candidateId
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addExperience() async -> Bool {
        guard canSaveExperience else {
            return false
        }

        isSaving = true
        errorMessage = nil

        defer {
            isSaving = false
        }

        do {
            try await workExperienceRepository.create(
                candidateId: candidateId,
                jobTitle: normalizedJobTitle,
                employerName: normalizedEmployerName,
                location: normalizedOptional(location),
                startDate: startDate,
                endDate: isCurrent ? nil : endDate,
                isCurrent: isCurrent,
                description: normalizedOptional(description)
            )

            experiences = try await workExperienceRepository.fetchAll(
                candidateId: candidateId
            )

            resetForm()

            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func deleteExperience(_ experience: WorkExperience) async {
        errorMessage = nil

        do {
            try await workExperienceRepository.delete(id: experience.id)

            experiences.removeAll {
                $0.id == experience.id
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func completeStep() async -> Bool {
        guard !experiences.isEmpty else {
            errorMessage = "Füge mindestens eine Berufserfahrung hinzu."
            return false
        }

        errorMessage = nil

        do {
            try await candidateProfileRepository.updateOnboardingStep(
                userId: candidateId,
                step: 2
            )

            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private var normalizedJobTitle: String {
        jobTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var normalizedEmployerName: String {
        employerName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func normalizedOptional(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        return trimmed.isEmpty ? nil : trimmed
    }

    private func resetForm() {
        jobTitle = ""
        employerName = ""
        location = ""
        startDate = Date()
        endDate = Date()
        isCurrent = false
        description = ""
    }
}
