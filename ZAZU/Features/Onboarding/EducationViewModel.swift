//
//  EducationViewModel.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class EducationViewModel {

    var educations: [Education] = []

    var institutionName = ""
    var degree = ""
    var fieldOfStudy = ""
    var educationLevel = "other"
    var completionStatus = "completed"
    var qualificationSearchText = ""
    var qualifications: [EducationQualification] = []
    var selectedQualification: EducationQualification?

    var isLoadingQualifications = false

    var startDate = Date()
    var endDate = Date()
    var hasStartDate = true
    var hasEndDate = true
    var isCurrent = false

    var description = ""

    var isLoading = false
    var isSaving = false
    var errorMessage: String?
    
    var hasNoFormalQualification = false

    private let educationRepository: EducationRepository
    private let candidateProfileRepository: CandidateProfileRepository
    private let candidateId: UUID

    init(
        educationRepository: EducationRepository,
        candidateProfileRepository: CandidateProfileRepository,
        candidateId: UUID
    ) {
        self.educationRepository = educationRepository
        self.candidateProfileRepository = candidateProfileRepository
        self.candidateId = candidateId
    }

    // MARK: - Validation

    var canSaveEducation: Bool {
        let hasRequiredFields =
            !institutionName
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty &&
            selectedQualification != nil

        guard hasRequiredFields, !isSaving else {
            return false
        }

        guard
            hasStartDate,
            !isCurrent,
            hasEndDate
        else {
            return true
        }

        return endDate >= startDate
    }

    // MARK: - Loading

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
            educations = try await educationRepository.fetchAll(
                candidateId: candidateId
            )

            let educationStatus =
                try await candidateProfileRepository.fetchEducationStatus(
                    userId: candidateId
                )

            hasNoFormalQualification =
                educationStatus == "no_formal_qualification"
                && educations.isEmpty

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Create

    func addEducation() async -> Bool {
        guard canSaveEducation else {
            return false
        }

        isSaving = true
        errorMessage = nil

        defer {
            isSaving = false
        }

        do {
            try await educationRepository.create(
                candidateId: candidateId,
                institutionName: normalizedInstitutionName,
                degree: normalizedDegree,
                fieldOfStudy: normalizedOptional(fieldOfStudy),
                startDate: hasStartDate ? startDate : nil,
                endDate: normalizedEndDate,
                isCurrent: isCurrent,
                description: normalizedOptional(description),
                educationLevel: educationLevel,
                completionStatus: isCurrent ? "in_progress" : completionStatus,
                qualificationId: selectedQualification?.id
            )

            educations = try await educationRepository.fetchAll(
                candidateId: candidateId
            )

            resetForm()

            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Delete

    func deleteEducation(
        _ education: Education
    ) async {
        errorMessage = nil

        do {
            try await educationRepository.delete(
                id: education.id
            )

            educations.removeAll {
                $0.id == education.id
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Onboarding

    func completeStep() async -> Bool {
        errorMessage = nil

        guard !educations.isEmpty || hasNoFormalQualification else {
            errorMessage = """
            Bitte füge eine Ausbildung hinzu oder wähle \
            «Ich habe keinen formalen Bildungsabschluss».
            """
            return false
        }

        let status: String

        if !educations.isEmpty {
            status = "has_education"
        } else {
            status = "no_formal_qualification"
        }

        do {
            try await candidateProfileRepository.updateEducationStatus(
                userId: candidateId,
                status: status
            )

            try await candidateProfileRepository.updateOnboardingStep(
                userId: candidateId,
                step: 4
            )

            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    func searchQualifications() async {
        isLoadingQualifications = true
        errorMessage = nil

        defer {
            isLoadingQualifications = false
        }

        do {
            qualifications = try await educationRepository.searchQualifications(
                educationLevel: educationLevel,
                searchText: qualificationSearchText
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    
    func selectQualification(_ qualification: EducationQualification) {
        guard qualification.educationLevel == educationLevel else {
            return
        }

        selectedQualification = qualification
        degree = qualification.name
        qualificationSearchText = qualification.name
    }

    // MARK: - Normalization

    private var normalizedInstitutionName: String {
        institutionName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    private var normalizedDegree: String {
        degree.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    private var normalizedEndDate: Date? {
        guard !isCurrent, hasEndDate else {
            return nil
        }

        return endDate
    }

    private func normalizedOptional(
        _ value: String
    ) -> String? {
        let trimmed = value.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        return trimmed.isEmpty ? nil : trimmed
    }

    // MARK: - Reset

    private func resetForm() {
        institutionName = ""
        degree = ""
        fieldOfStudy = ""
        educationLevel = "other"
        completionStatus = "completed"
        qualificationSearchText = ""
        qualifications = []
        selectedQualification = nil

        startDate = Date()
        endDate = Date()
        hasStartDate = true
        hasEndDate = true
        isCurrent = false

        description = ""
    }
}
