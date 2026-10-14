//
//  EmployerJobFormViewModel.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 07.10.2026.
//

import Foundation
import Observation

struct EmployerLanguageRequirementDraft: Identifiable {
    let language: Language
    var minimumProficiency: LanguageProficiency
    var requirementType: RequirementType

    

    var id: UUID {
        language.id
    }
}

struct EmployerEducationRequirementDraft: Identifiable {
    let id: UUID
    var degree: String
    var fieldOfStudy: String
    var requirementType: RequirementType

    init(
        id: UUID = UUID(),
        degree: String = "",
        fieldOfStudy: String = "",
        requirementType: RequirementType = .optional
    ) {
        self.id = id
        self.degree = degree
        self.fieldOfStudy = fieldOfStudy
        self.requirementType = requirementType
    }
}

@Observable
@MainActor
final class EmployerJobFormViewModel {

    var title = ""
    var description = ""
    var activityArea = ""
    var location = ""
    
    var availableContacts: [CompanyContact] = []
    var selectedContactId: UUID?
    var isLoadingContacts = false

    var workloadMin = 80
    var workloadMax = 100

    var salaryMin = ""
    var salaryMax = ""

    var requiredWorkExperienceYears = 0
    var workExperienceRequirementType: RequirementType = .optional

    var requiresWorkAuthorization = true
    var workAuthorizationRequirementType: RequirementType = .must

    var homeofficeAvailable = false
    var homeofficeDays = 0
    var homeofficeSchedule: JobHomeofficeSchedule = .flexible
    var fullyRemoteAvailable = false
    var homeofficeRequirementType: RequirementType = .optional

    var workModel: PreferredWorkModel = .hybrid
    var workModelRequirementType: RequirementType = .optional

    var isLoading = false
    var errorMessage: String?

    var skillRequirements: [EmployerSkillRequirementDraft] = []
    var languageRequirements: [EmployerLanguageRequirementDraft] = []
    var educationRequirements: [EmployerEducationRequirementDraft] = []

    private(set) var editingJob: Job?

    private var didLoadEditingRequirements = false

    private let userId: UUID
    private let companyRepository: CompanyRepository
    private let jobRepository: JobRepository
    private let skillRepository: SkillRepository
    private let languageRepository: LanguageRepository
    private let contactRepository: CompanyContactRepository

    var isEditing: Bool {
        editingJob != nil
    }

    var canSubmit: Bool {
        hasValue(title) &&
        hasValue(description) &&
        hasValue(location) &&
        workloadMin > 0 &&
        workloadMax <= 100 &&
        workloadMin <= workloadMax &&
        !isLoading
    }

    init(
        userId: UUID,
        companyRepository: CompanyRepository,
        jobRepository: JobRepository,
        skillRepository: SkillRepository,
        languageRepository: LanguageRepository,
        editingJob: Job? = nil,
        contactRepository: CompanyContactRepository,
    ) {
        self.userId = userId
        self.companyRepository = companyRepository
        self.jobRepository = jobRepository
        self.skillRepository = skillRepository
        self.languageRepository = languageRepository
        self.editingJob = editingJob
        self.contactRepository = contactRepository

        if let job = editingJob {
            title = job.title
            description = job.description
            activityArea = job.activityArea ?? ""
            location = job.location

            workloadMin = job.workloadMin
            workloadMax = job.workloadMax

            salaryMin = job.salaryMin.map(String.init) ?? ""
            salaryMax = job.salaryMax.map(String.init) ?? ""

            requiredWorkExperienceYears =
                job.requiredWorkExperienceYears ?? 0
            workExperienceRequirementType =
                job.workExperienceRequirementType

            requiresWorkAuthorization =
                job.requiresWorkAuthorization
            workAuthorizationRequirementType =
                job.workAuthorizationRequirementType

            homeofficeAvailable =
                job.homeofficeAvailable
            homeofficeDays =
                job.homeofficeDays ?? 0
            homeofficeSchedule =
                job.homeofficeSchedule ?? .flexible
            fullyRemoteAvailable =
                job.fullyRemoteAvailable
            homeofficeRequirementType =
                job.homeofficeRequirementType

            workModel =
                job.workModel
            workModelRequirementType =
                job.workModelRequirementType
            selectedContactId = job.responsibleContactId
        }
    }
    
    
    // MARK: - Company Contacts

    func loadContacts() async {
        guard !isLoadingContacts else { return }

        isLoadingContacts = true
        defer { isLoadingContacts = false }

        do {
            let companyId: UUID

            if let editingJob {
                companyId = editingJob.companyId
            } else {
                guard let membership =
                    try await companyRepository.fetchOwnMembership(
                        userId: userId
                    )
                else {
                    errorMessage = "Dein Unternehmen konnte nicht gefunden werden."
                    return
                }

                companyId = membership.companyId
            }

            availableContacts = try await contactRepository.fetchContacts(
                companyId: companyId
            )

        } catch {
            errorMessage = "Kontaktpersonen konnten nicht geladen werden: \(error.localizedDescription)"
        }
    }

    // MARK: - Editing Requirements

    func loadRequirementsForEditing() async {
        guard let editingJob else {
            return
        }

        guard !didLoadEditingRequirements else {
            return
        }

        didLoadEditingRequirements = true
        errorMessage = nil

        do {
            async let skillsTask =
                skillRepository.fetchSkills()

            async let languagesTask =
                languageRepository.fetchLanguages()

            async let skillRequirementsTask =
                jobRepository.fetchSkillRequirements(
                    jobId: editingJob.id
                )

            async let languageRequirementsTask =
                jobRepository.fetchLanguageRequirements(
                    jobId: editingJob.id
                )

            async let educationRequirementsTask =
                jobRepository.fetchEducationRequirements(
                    jobId: editingJob.id
                )

            let (
                skills,
                languages,
                existingSkillRequirements,
                existingLanguageRequirements,
                existingEducationRequirements
            ) = try await (
                skillsTask,
                languagesTask,
                skillRequirementsTask,
                languageRequirementsTask,
                educationRequirementsTask
            )

            skillRequirements =
                existingSkillRequirements.compactMap { requirement in
                    guard let skill = skills.first(
                        where: {
                            $0.id == requirement.skillId
                        }
                    ) else {
                        return nil
                    }

                    return EmployerSkillRequirementDraft(
                        skill: skill,
                        minimumProficiency:
                            requirement.minimumProficiency,
                        requirementType:
                            requirement.requirementType
                    )
                }

            languageRequirements =
                existingLanguageRequirements.compactMap { requirement in
                    guard let language = languages.first(
                        where: {
                            $0.id == requirement.languageId
                        }
                    ) else {
                        return nil
                    }

                    return EmployerLanguageRequirementDraft(
                        language: language,
                        minimumProficiency:
                            requirement.minimumProficiency,
                        requirementType:
                            requirement.requirementType
                    )
                }

            educationRequirements =
                existingEducationRequirements.map { requirement in
                    EmployerEducationRequirementDraft(
                        id: requirement.id,
                        degree: requirement.degree,
                        fieldOfStudy:
                            requirement.fieldOfStudy ?? "",
                        requirementType:
                            requirement.requirementType
                    )
                }

        } catch {
            didLoadEditingRequirements = false
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Save

    func saveJob() async -> Bool {
        if let editingJob {
            return await updateJob(editingJob)
        }

        return await createJob()
    }

    private func updateJob(_ job: Job) async -> Bool {
        guard canSubmit else {
            return false
        }
        
       

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            try await jobRepository.updateJob(
                jobId: job.id,
                title: title.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
                description: description.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
                activityArea:
                    normalizedOptionalText(activityArea),
                location: location.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
                workModel: workModel,
                workloadMin: workloadMin,
                workloadMax: workloadMax,
                salaryMin: Int(salaryMin),
                salaryMax: Int(salaryMax),
                requiredWorkExperienceYears:
                    requiredWorkExperienceYears > 0
                    ? requiredWorkExperienceYears
                    : nil,
                workExperienceRequirementType:
                    workExperienceRequirementType,
                requiresWorkAuthorization:
                    requiresWorkAuthorization,
                workAuthorizationRequirementType:
                    workAuthorizationRequirementType,
                homeofficeAvailable:
                    homeofficeAvailable,
                homeofficeDays:
                    homeofficeAvailable
                    ? homeofficeDays
                    : nil,
                homeofficeSchedule:
                    homeofficeAvailable
                    ? homeofficeSchedule
                    : nil,
                fullyRemoteAvailable:
                    fullyRemoteAvailable,
                homeofficeRequirementType:
                    homeofficeRequirementType,
                workModelRequirementType:
                    workModelRequirementType,
                responsibleContactId:
                    selectedContactId
            )
            
            try await syncSkillRequirements(

                jobId: job.id

            )

            try await syncLanguageRequirements(

                jobId: job.id

            )

            try await syncEducationRequirements(

                jobId: job.id

            )

            return true

        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Create

    func createJob() async -> Bool {
        guard canSubmit else {
            return false
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            guard let membership =
                    try await companyRepository.fetchOwnMembership(
                        userId: userId
                    ) else {
                errorMessage =
                    "Dein Unternehmen konnte nicht gefunden werden."
                return false
            }

            let createdJob =
                try await jobRepository.createJob(
                    companyId: membership.companyId,
                    title: title.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ),
                    description: description.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ),
                    activityArea:
                        optionalValue(activityArea),
                    location: location.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ),
                    latitude: nil,
                    longitude: nil,
                    workModel: workModel,
                    workloadMin: workloadMin,
                    workloadMax: workloadMax,
                    earliestStartDate: nil,
                    salaryMin: Int(salaryMin),
                    salaryMax: Int(salaryMax),
                    requiredWorkExperienceYears:
                        requiredWorkExperienceYears > 0
                        ? requiredWorkExperienceYears
                        : nil,
                    workExperienceRequirementType:
                        workExperienceRequirementType,
                    requiresWorkAuthorization:
                        requiresWorkAuthorization,
                    workAuthorizationRequirementType:
                        workAuthorizationRequirementType,
                    homeofficeAvailable:
                        homeofficeAvailable,
                    homeofficeDays:
                        homeofficeAvailable &&
                        homeofficeDays > 0
                        ? homeofficeDays
                        : nil,
                    homeofficeSchedule:
                        homeofficeAvailable
                        ? homeofficeSchedule
                        : nil,
                    fullyRemoteAvailable:
                        fullyRemoteAvailable,
                    homeofficeRequirementType:
                        homeofficeRequirementType,
                    workModelRequirementType:
                        workModelRequirementType,
                    responsibleContactId: selectedContactId
                )

            for requirement in skillRequirements {
                try await jobRepository.saveSkillRequirement(
                    jobId: createdJob.id,
                    skillId: requirement.skill.id,
                    minimumProficiency:
                        requirement.minimumProficiency,
                    requirementType:
                        requirement.requirementType
                )
            }

            for requirement in languageRequirements {
                try await jobRepository.saveLanguageRequirement(
                    jobId: createdJob.id,
                    languageId: requirement.language.id,
                    minimumProficiency:
                        requirement.minimumProficiency,
                    requirementType:
                        requirement.requirementType
                )
            }

            for requirement in educationRequirements {
                let degree =
                    requirement.degree.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )

                guard !degree.isEmpty else {
                    continue
                }

                let trimmedField =
                    requirement.fieldOfStudy.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )

                try await jobRepository.saveEducationRequirement(
                    jobId: createdJob.id,
                    degree: degree,
                    fieldOfStudy:
                        trimmedField.isEmpty
                        ? nil
                        : trimmedField,
                    requirementType:
                        requirement.requirementType
                )
            }

            return true

        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    private func syncEducationRequirements(
        jobId: UUID
    ) async throws {
        let existingRequirements =
            try await jobRepository.fetchEducationRequirements(
                jobId: jobId
            )

        let existingIds = Set(
            existingRequirements.map(\.id)
        )

        let selectedIds = Set(
            educationRequirements
                .map(\.id)
                .filter { existingIds.contains($0) }
        )

        // Entfernte bestehende Anforderungen löschen
        for existing in existingRequirements {
            if !selectedIds.contains(existing.id) {
                try await jobRepository.deleteEducationRequirement(
                    id: existing.id
                )
            }
        }

        for requirement in educationRequirements {
            let degree = requirement.degree
                .trimmingCharacters(in: .whitespacesAndNewlines)

            guard !degree.isEmpty else {
                continue
            }

            let trimmedField = requirement.fieldOfStudy
                .trimmingCharacters(in: .whitespacesAndNewlines)

            let fieldOfStudy =
                trimmedField.isEmpty ? nil : trimmedField

            if existingIds.contains(requirement.id) {
                // Bestehende Anforderung aktualisieren
                try await jobRepository.updateEducationRequirement(
                    id: requirement.id,
                    degree: degree,
                    fieldOfStudy: fieldOfStudy,
                    requirementType: requirement.requirementType
                )
            } else {
                // Neu hinzugefügte Anforderung speichern
                try await jobRepository.saveEducationRequirement(
                    jobId: jobId,
                    degree: degree,
                    fieldOfStudy: fieldOfStudy,
                    requirementType: requirement.requirementType
                )
            }
        }
    }
    
    private func syncLanguageRequirements(
        jobId: UUID
    ) async throws {
        let existingRequirements =
            try await jobRepository.fetchLanguageRequirements(
                jobId: jobId
            )

        let selectedLanguageIds = Set(
            languageRequirements.map {
                $0.language.id
            }
        )

        // Entfernte Sprachen löschen
        for existing in existingRequirements {
            if !selectedLanguageIds.contains(existing.languageId) {
                try await jobRepository.deleteLanguageRequirement(
                    jobId: jobId,
                    languageId: existing.languageId
                )
            }
        }

        // Neue oder geänderte Sprachen speichern
        for requirement in languageRequirements {
            try await jobRepository.saveLanguageRequirement(
                jobId: jobId,
                languageId: requirement.language.id,
                minimumProficiency:
                    requirement.minimumProficiency,
                requirementType:
                    requirement.requirementType
            )
        }
    }
    
    private func syncSkillRequirements(
        jobId: UUID
    ) async throws {
        let existingRequirements =
            try await jobRepository.fetchSkillRequirements(
                jobId: jobId
            )

        let existingSkillIds = Set(
            existingRequirements.map(\.skillId)
        )

        let selectedSkillIds = Set(
            skillRequirements.map {
                $0.skill.id
            }
        )

        // Entfernte Skills löschen
        for existing in existingRequirements {
            if !selectedSkillIds.contains(existing.skillId) {
                try await jobRepository.deleteSkillRequirement(
                    jobId: jobId,
                    skillId: existing.skillId
                )
            }
        }

        // Bestehende aktualisieren, neue anlegen
        for requirement in skillRequirements {
            if existingSkillIds.contains(requirement.skill.id) {
                try await jobRepository.updateSkillRequirement(
                    jobId: jobId,
                    skillId: requirement.skill.id,
                    minimumProficiency:
                        requirement.minimumProficiency,
                    requirementType:
                        requirement.requirementType
                )
            } else {
                try await jobRepository.saveSkillRequirement(
                    jobId: jobId,
                    skillId: requirement.skill.id,
                    minimumProficiency:
                        requirement.minimumProficiency,
                    requirementType:
                        requirement.requirementType
                )
            }
        }
    }

    // MARK: - Education

    func addEducationRequirement() {
        educationRequirements.append(
            EmployerEducationRequirementDraft()
        )
    }

    func removeEducationRequirement(id: UUID) {
        educationRequirements.removeAll {
            $0.id == id
        }
    }

    // MARK: - Skills

    func isSkillSelected(_ skill: Skill) -> Bool {
        skillRequirements.contains {
            $0.skill.id == skill.id
        }
    }

    func toggleSkill(_ skill: Skill) {
        if let index = skillRequirements.firstIndex(
            where: {
                $0.skill.id == skill.id
            }
        ) {
            skillRequirements.remove(at: index)
        } else {
            skillRequirements.append(
                EmployerSkillRequirementDraft(
                    skill: skill,
                    minimumProficiency: .good,
                    requirementType: .optional
                )
            )
        }
    }

    func updateSkillProficiency(
        skillId: UUID,
        proficiency: SkillProficiency
    ) {
        guard let index = skillRequirements.firstIndex(
            where: {
                $0.skill.id == skillId
            }
        ) else {
            return
        }

        skillRequirements[index].minimumProficiency =
            proficiency
    }

    func updateSkillRequirementType(
        skillId: UUID,
        requirementType: RequirementType
    ) {
        guard let index = skillRequirements.firstIndex(
            where: {
                $0.skill.id == skillId
            }
        ) else {
            return
        }

        skillRequirements[index].requirementType =
            requirementType
    }

    // MARK: - Languages

    func isLanguageSelected(
        _ language: Language
    ) -> Bool {
        languageRequirements.contains {
            $0.language.id == language.id
        }
    }

    func toggleLanguage(
        _ language: Language
    ) {
        if let index = languageRequirements.firstIndex(
            where: {
                $0.language.id == language.id
            }
        ) {
            languageRequirements.remove(at: index)
        } else {
            languageRequirements.append(
                EmployerLanguageRequirementDraft(
                    language: language,
                    minimumProficiency: .b2,
                    requirementType: .optional
                )
            )
        }
    }

    func updateLanguageProficiency(
        languageId: UUID,
        proficiency: LanguageProficiency
    ) {
        guard let index = languageRequirements.firstIndex(
            where: {
                $0.language.id == languageId
            }
        ) else {
            return
        }

        languageRequirements[index].minimumProficiency =
            proficiency
    }

    func updateLanguageRequirementType(
        languageId: UUID,
        requirementType: RequirementType
    ) {
        guard let index = languageRequirements.firstIndex(
            where: {
                $0.language.id == languageId
            }
        ) else {
            return
        }

        languageRequirements[index].requirementType =
            requirementType
    }

    // MARK: - Helpers

    private func hasValue(
        _ value: String
    ) -> Bool {
        !value
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .isEmpty
    }

    private func optionalValue(
        _ value: String
    ) -> String? {
        let trimmed =
            value.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        return trimmed.isEmpty
            ? nil
            : trimmed
    }

    private func normalizedOptionalText(
        _ value: String
    ) -> String? {
        let trimmed =
            value.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        return trimmed.isEmpty
            ? nil
            : trimmed
    }
}
