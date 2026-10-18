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
    var candidateSkills: [CandidateSkill] = []
    var candidateCustomSkills: [CandidateCustomSkill] = []

    var searchText = ""
    var selectedCategory: String?

    var isLoading = false
    var isSearching = false
    var isSaving = false
    var errorMessage: String?

    private let skillRepository: SkillRepository
    private let candidateProfileRepository: CandidateProfileRepository
    private let candidateId: UUID

    private var searchTask: Task<Void, Never>?
    private var searchGeneration = 0

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
        guard !isLoading else {
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

            let (
                loadedCandidateSkills,
                loadedCustomSkills
            ) = try await (
                candidateSkillsRequest,
                customSkillsRequest
            )

            candidateSkills = loadedCandidateSkills
            candidateCustomSkills = loadedCustomSkills

            await reloadSelectedSkillDetails()

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

        guard hasSearchQuery else {
            isSearching = false
            return
        }

        isSearching = true

        let query = searchText
        let category = selectedCategory

        searchTask = Task {
            do {
                try await Task.sleep(
                    for: .milliseconds(300)
                )

                try Task.checkCancellation()

                let results = try await skillRepository.searchSkills(
                    query: query,
                    category: category
                )

                guard !Task.isCancelled,
                      generation == searchGeneration else {
                    return
                }

                skills = results
                isSearching = false

            } catch is CancellationError {
                return

            } catch {
                guard generation == searchGeneration else {
                    return
                }

                skills = []
                isSearching = false
                errorMessage = error.localizedDescription
            }
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
