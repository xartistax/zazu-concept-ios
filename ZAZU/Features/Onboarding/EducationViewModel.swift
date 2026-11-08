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
    
    
    // MARK: - Education Catalog

    var educationTypes: [EducationType] = []
    var educationTypeDegrees: [EducationTypeDegree] = []
    var educationFields: [EducationField] = []
    var educationInstitutionTypes: [EducationInstitutionType] = []
    var educationInstitutions: [EducationInstitution] = []

    var selectedEducationType: EducationType?
    var selectedEducationTypeDegree: EducationTypeDegree?
    var selectedEducationField: EducationField?
    var selectedInstitutionType: EducationInstitutionType?
    var selectedInstitution: EducationInstitution?

    var educationFieldSearchText = ""
    var institutionSearchText = ""

    var isLoadingCatalog = false
    var isLoadingDegrees = false
    var isLoadingFields = false
    var isLoadingInstitutions = false

    var catalogErrorMessage: String?

    

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
    private var hasLoaded = false
    private var qualificationRequestID = UUID()
    private var loadedQualificationContextID: String?

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
        guard !isSaving, !isLoadingQualifications else {
            return false
        }

        if let selectedQualification {
            guard loadedQualificationContextID == qualificationContextID,
                  qualifications.contains(
                      where: { $0.id == selectedQualification.id }
                  )
            else {
                return false
            }
        }

        guard let selectedEducationType,
              let selectedDegree = selectedEducationTypeDegree,
              selectedDegree.educationTypeId == selectedEducationType.id
        else {
            return false
        }

        let isHigherEducation =
            selectedEducationType.code == "A01"
            || selectedEducationType.code == "A10"

        if isHigherEducation {
            guard let selectedInstitution,
                  educationInstitutions.contains(
                      where: { $0.id == selectedInstitution.id }
                  )
            else {
                return false
            }
        } else {
            guard !institutionName
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty
            else {
                return false
            }
        }

        if hasStartDate && !isCurrent && hasEndDate {
            guard endDate >= startDate else {
                return false
            }
        }
        
        if selectedEducationType.code == "A01" {
            guard let selectedEducationField,
                  educationFields.contains(
                      where: { $0.id == selectedEducationField.id }
                  )
            else {
                return false
            }
        }

        return true
    }



    // MARK: - Loading

    func load() async {
        guard !isLoading, !hasLoaded else {
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
            hasLoaded = true

        } catch {
            errorMessage = error.localizedDescription
        }
        
        await loadEducationCatalog()
        
    }

    // MARK: - Create

    
    func addEducation() async -> Bool {
        guard canSaveEducation,
              let selectedEducationType,
              let selectedEducationTypeDegree
        else {
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
                degree: selectedEducationTypeDegree.nameDe,
                fieldOfStudy: normalizedOptional(fieldOfStudy),
                startDate: hasStartDate ? startDate : nil,
                endDate: normalizedEndDate,
                isCurrent: isCurrent,
                description: normalizedOptional(description),
                educationLevel: nil,
                completionStatus: isCurrent
                    ? "in_progress"
                    : completionStatus,
                qualificationId: selectedQualification?.id,
                educationTypeId: selectedEducationType.id,
                educationTypeDegreeId: selectedEducationTypeDegree.id,
                educationFieldId: selectedEducationField?.id,
                institutionTypeId: selectedInstitutionType?.id,
                institutionId: selectedInstitution?.id
            )

            educations = try await educationRepository.fetchAll(
                candidateId: candidateId
            )
            
            hasNoFormalQualification = false

            try await candidateProfileRepository.updateEducationStatus(
                userId: candidateId,
                status: "has_education"
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
                step: 2
            )

            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    var qualificationContextID: String {
        [
            selectedEducationTypeDegree?.id.uuidString ?? "",
            selectedEducationField?.id.uuidString ?? "",
            selectedInstitution?.id.uuidString ?? ""
        ]
        .joined(separator: ":")
    }

    func loadQualificationOptions() async {
        let requestID = UUID()
        qualificationRequestID = requestID

        let contextID = qualificationContextID
        loadedQualificationContextID = nil

        selectedQualification = nil
        qualifications = []
        qualificationSearchText = ""

        guard let degreeID = selectedEducationTypeDegree?.id else {
            isLoadingQualifications = false
            return
        }

        isLoadingQualifications = true
        catalogErrorMessage = nil

        defer {
            if qualificationRequestID == requestID {
                isLoadingQualifications = false
            }
        }

        do {
            let options =
                try await educationRepository.fetchQualificationOptions(
                    degreeId: degreeID,
                    fieldId: selectedEducationField?.id,
                    institutionId: selectedInstitution?.id
                )

            guard qualificationRequestID == requestID,
                  qualificationContextID == contextID,
                  !Task.isCancelled else {
                return
            }

            loadedQualificationContextID = contextID
            qualifications = options
        } catch {
            guard qualificationRequestID == requestID,
                  qualificationContextID == contextID,
                  !Task.isCancelled else {
                return
            }

            catalogErrorMessage =
                "Abschlusstitel konnten nicht geladen werden: \(error.localizedDescription)"
        }
    }

    func selectQualification(
        _ qualification: EducationQualification
    ) {
        guard qualifications.contains(
            where: { $0.id == qualification.id }
        ) else {
            return
        }

        selectedQualification = qualification
    }
    
    
    
    
    
    // MARK: - Catalog Loading

    func loadEducationCatalog() async {
        guard !isLoadingCatalog else { return }

        isLoadingCatalog = true
        catalogErrorMessage = nil

        defer {
            isLoadingCatalog = false
        }

        do {
            async let types = educationRepository.fetchEducationTypes()
            async let institutionTypes =
                educationRepository.fetchEducationInstitutionTypes()

            educationTypes = try await types
            educationInstitutionTypes = try await institutionTypes
        } catch {
            catalogErrorMessage = error.localizedDescription
        }
    }

    func selectEducationType(_ type: EducationType) async {
        selectedEducationType = type
        
        selectedInstitution = nil
        selectedInstitutionType = nil
        institutionName = ""
        institutionSearchText = ""
        educationInstitutions = []

        selectedEducationTypeDegree = nil
        selectedEducationField = nil

        educationTypeDegrees = []
        educationFields = []

        degree = ""
        fieldOfStudy = ""
        educationFieldSearchText = ""

        // Alte Qualifikationsauswahl zurücksetzen.
        selectedQualification = nil
        qualificationSearchText = ""
        qualifications = []

        isLoadingDegrees = true
        catalogErrorMessage = nil

        defer {
            isLoadingDegrees = false
        }

        do {
            educationTypeDegrees =
                try await educationRepository.fetchEducationTypeDegrees(
                    educationTypeId: type.id
                )
        } catch {
            catalogErrorMessage = error.localizedDescription
        }
        
        if type.code == "A01" || type.code == "A10" {
            await loadHigherEducationInstitutions()
        }
    }

    func selectEducationTypeDegree(
        _ selectedDegree: EducationTypeDegree
    ) async {
        guard selectedDegree.educationTypeId ==
                selectedEducationType?.id else {
            return
        }

        selectedEducationTypeDegree = selectedDegree
        selectedEducationField = nil

        degree = selectedDegree.nameDe
        fieldOfStudy = ""
        educationFields = []

        await loadFieldsForSelectedDegree()
    }

    func loadFieldsForSelectedDegree() async {
        guard let selectedEducationTypeDegree else {
            educationFields = []
            return
        }

        isLoadingFields = true
        catalogErrorMessage = nil

        defer {
            isLoadingFields = false
        }

        do {
            educationFields =
                try await educationRepository.fetchFieldsForDegree(
                    degreeId: selectedEducationTypeDegree.id
                )
        } catch {
            catalogErrorMessage = error.localizedDescription
        }
    }

    func searchEducationFields(
        kind: String
    ) async {
        isLoadingFields = true
        catalogErrorMessage = nil

        defer {
            isLoadingFields = false
        }

        do {
            educationFields =
                try await educationRepository.fetchEducationFields(
                    kind: kind,
                    searchText: educationFieldSearchText
                )
        } catch {
            catalogErrorMessage = error.localizedDescription
        }
    }

    func selectEducationField(_ field: EducationField) {
        selectedEducationField = field
        fieldOfStudy = field.nameDe
        educationFieldSearchText = field.nameDe
    }

    func searchInstitutions() async {
        isLoadingInstitutions = true
        catalogErrorMessage = nil

        defer {
            isLoadingInstitutions = false
        }

        do {
            educationInstitutions =
                try await educationRepository.searchEducationInstitutions(
                    searchText: institutionSearchText
                )
        } catch {
            catalogErrorMessage = error.localizedDescription
        }
    }

    func selectInstitution(_ institution: EducationInstitution) {
        selectedInstitution = institution
        institutionName = institution.name
        institutionSearchText = institution.name

        selectedInstitutionType =
            educationInstitutionTypes.first {
                $0.id == institution.institutionTypeId
            }
    }
    
    
    
    func loadHigherEducationInstitutions() async {
        guard let educationTypeId = selectedEducationType?.id else {
            return
        }

        isLoadingInstitutions = true
        catalogErrorMessage = nil

        defer {
            isLoadingInstitutions = false
        }

        do {
            let institutions =
                try await educationRepository.searchEducationInstitutions(
                    searchText: ""
                )

            guard selectedEducationType?.id == educationTypeId else {
                return
            }

            educationInstitutions = institutions
        } catch {
            guard selectedEducationType?.id == educationTypeId else {
                return
            }

            catalogErrorMessage =
                "Hochschulen konnten nicht geladen werden: \(error.localizedDescription)"
        }
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
        
        selectedEducationType = nil
        selectedEducationTypeDegree = nil
        selectedEducationField = nil
        selectedInstitutionType = nil
        selectedInstitution = nil

        educationTypeDegrees = []
        educationFields = []
        educationInstitutions = []

        educationFieldSearchText = ""
        institutionSearchText = ""
    }
}
