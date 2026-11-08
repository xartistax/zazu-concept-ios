//
//  SkillsViewModel.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//
//
//  SkillsViewModel.swift
//  ZAZU
//

import Foundation
import Observation

@Observable
@MainActor
final class SkillsViewModel {

    // MARK: - State

    var skills: [Skill] = []
    var skillCategories: [SkillCategory] = []
    var candidateSkills: [CandidateSkill] = []
    var candidateCustomSkills: [CandidateCustomSkill] = []

    var searchText = ""
    var selectedCategoryIDs: Set<UUID> = []

    var isLoading = false
    var isSearching = false
    var isSaving = false
    var errorMessage: String?
    
    var isSavingCategories = false
    var categorySaveErrorMessage: String?

    private let skillRepository: SkillRepository
    private let candidateProfileRepository: CandidateProfileRepository
    private let candidateId: UUID

    private var searchTask: Task<Void, Never>?
    private var searchGeneration = 0
    
    var hasMoreSkills = true
    private var hasLoaded = false

    private var nextSkillOffset = 0
    private let skillPageSize = 30

    // MARK: - Init

    init(
        skillRepository: SkillRepository,
        candidateProfileRepository: CandidateProfileRepository,
        candidateId: UUID
    ) {
        self.skillRepository = skillRepository
        self.candidateProfileRepository = candidateProfileRepository
        self.candidateId = candidateId
    }

    // MARK: - Display

    var categories: [String] {
        [
            "skill/competence",
            "knowledge"
        ]
    }

    func categoryTitle(_ category: String) -> String {
        switch category {
        case "skill/competence":
            return "Fähigkeiten"

        case "knowledge":
            return "Fach- & Systemkenntnisse"

        case "unspecified":
            return "Sonstige"

        default:
            return category
        }
    }

    var hasSearchQuery: Bool {
        searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .count >= 2
    }

    var filteredSkills: [Skill] {
        let selectedIds = Set(
            candidateSkills.map(\.skillId)
        )

        return skills.filter {
            !selectedIds.contains($0.id)
        }
    }

    var selectedSkills: [Skill] {
        let selectedIds = Set(
            candidateSkills.map(\.skillId)
        )

        return selectedSkillDetails.filter {
            selectedIds.contains($0.id)
        }
    }

    private var selectedSkillDetails: [Skill] = []

    func proficiency(
        for skill: Skill
    ) -> SkillProficiency? {
        candidateSkills.first {
            $0.skillId == skill.id
        }?.proficiency
    }

    func isSelected(
        _ skill: Skill
    ) -> Bool {
        proficiency(for: skill) != nil
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
            async let candidateSkillsRequest =
                skillRepository.fetchCandidateSkills(
                    candidateId: candidateId
                )

            async let customSkillsRequest =
                skillRepository.fetchCandidateCustomSkills(
                    candidateId: candidateId
                )

            async let categoriesRequest =
                skillRepository.fetchSkillCategories()
            
            async let selectedCategoriesRequest =
                skillRepository.fetchCandidateSkillCategoryIDs(
                    candidateId: candidateId
                )

            let (
                loadedCandidateSkills,
                loadedCustomSkills,
                loadedCategories,
                loadedSelectedCategoryIDs
            ) = try await (
                candidateSkillsRequest,
                customSkillsRequest,
                categoriesRequest,
                selectedCategoriesRequest
            )
            
            selectedCategoryIDs = loadedSelectedCategoryIDs

            skillCategories = loadedCategories

            candidateSkills = loadedCandidateSkills
            candidateCustomSkills = loadedCustomSkills

            await reloadSelectedSkillDetails()
            
            hasLoaded = true

            scheduleSearch()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Search

    func scheduleSearch() {
        searchTask?.cancel()
        searchGeneration += 1

        let generation = searchGeneration

        skills = []
        nextSkillOffset = 0
        hasMoreSkills = true
        isSearching = true
        errorMessage = nil

        searchTask = Task {
            do {
                try await Task.sleep(
                    for: .milliseconds(300)
                )

                try Task.checkCancellation()

                guard generation == searchGeneration else {
                    return
                }

                await loadSkillPage(generation: generation)
            } catch {
                // Eine neuere Suche ersetzt diese Anfrage.
            }
        }
    }

    func loadMoreSkills() async {
        guard !isLoading,
              !isSearching,
              hasMoreSkills else {
            return
        }

        isSearching = true
        errorMessage = nil

        await loadSkillPage(
            generation: searchGeneration
        )
    }

    private func loadSkillPage(
        generation: Int
    ) async {
        let offset = nextSkillOffset
        let query = searchText
        let categoryIDs = Array(selectedCategoryIDs)

        defer {
            if generation == searchGeneration {
                isSearching = false
            }
        }

        do {
            let results = try await skillRepository.searchSkills(
                query: query,
                categoryIds: categoryIDs,
                offset: offset,
                pageSize: skillPageSize
            )

            guard !Task.isCancelled,
                  generation == searchGeneration else {
                return
            }

            let existingIDs = Set(skills.map(\.id))

            skills.append(
                contentsOf: results.filter {
                    !existingIDs.contains($0.id)
                }
            )

            nextSkillOffset = offset + results.count
            hasMoreSkills = results.count == skillPageSize

        } catch {
            guard !Task.isCancelled,
                  generation == searchGeneration else {
                return
            }

            errorMessage = error.localizedDescription
        }
    }
    
    
    func saveCategorySelection() async -> Bool {
        guard !isSavingCategories else {
            return false
        }

        isSavingCategories = true
        categorySaveErrorMessage = nil

        let categoryIDs = selectedCategoryIDs

        defer {
            isSavingCategories = false
        }

        do {
            try await skillRepository.saveCandidateSkillCategories(
                categoryIDs: categoryIDs
            )

            return true
        } catch {
            categorySaveErrorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Selection

    func save(
        skill: Skill,
        proficiency: SkillProficiency
    ) async {
        guard !isSaving else {
            return
        }

        isSaving = true
        errorMessage = nil

        defer {
            isSaving = false
        }

        do {
            try await skillRepository.saveCandidateSkill(
                candidateId: candidateId,
                skillId: skill.id,
                proficiency: proficiency
            )

            await reloadCandidateSkills()
            await reloadSelectedSkillDetails()

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func remove(
        skill: Skill
    ) async {
        guard !isSaving else {
            return
        }

        isSaving = true
        errorMessage = nil

        defer {
            isSaving = false
        }

        do {
            try await skillRepository.deleteCandidateSkill(
                candidateId: candidateId,
                skillId: skill.id
            )

            candidateSkills.removeAll {
                $0.skillId == skill.id
            }

            selectedSkillDetails.removeAll {
                $0.id == skill.id
            }

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Custom Skills

    func saveCustomSkill(
        name: String,
        proficiency: SkillProficiency
    ) async -> Bool {

        let trimmedName = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedName.isEmpty else {
            errorMessage =
                "Gib einen Skill oder eine Systemkenntnis ein."
            return false
        }

        guard !isSaving else {
            return false
        }

        isSaving = true
        errorMessage = nil

        defer {
            isSaving = false
        }

        do {
            try await skillRepository.saveCandidateCustomSkill(
                candidateId: candidateId,
                name: trimmedName,
                proficiency: proficiency
            )

            await reloadCandidateCustomSkills()
            return true

        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func removeCustomSkill(
        _ skill: CandidateCustomSkill
    ) async {
        guard !isSaving else {
            return
        }

        isSaving = true
        errorMessage = nil

        defer {
            isSaving = false
        }

        do {
            try await skillRepository.deleteCandidateCustomSkill(
                id: skill.id
            )

            candidateCustomSkills.removeAll {
                $0.id == skill.id
            }

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Onboarding

    func completeStep() async -> Bool {
        guard !candidateSkills.isEmpty ||
              !candidateCustomSkills.isEmpty else {

            errorMessage =
                "Wähle mindestens einen Skill oder eine Systemkenntnis aus."
            return false
        }

        errorMessage = nil

        do {
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

    // MARK: - Private

    private func reloadCandidateSkills() async {
        do {
            candidateSkills =
                try await skillRepository.fetchCandidateSkills(
                    candidateId: candidateId
                )

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func reloadSelectedSkillDetails() async {
        do {
            let ids = candidateSkills.map(\.skillId)

            selectedSkillDetails =
                try await skillRepository.fetchSkillsByIds(ids)

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func reloadCandidateCustomSkills() async {
        do {
            candidateCustomSkills =
                try await skillRepository.fetchCandidateCustomSkills(
                    candidateId: candidateId
                )

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
