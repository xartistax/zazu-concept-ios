//
//  SkillsViewModel.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class SkillsViewModel {

    var skills: [Skill] = []
    var candidateSkills: [CandidateSkill] = []
    
    var candidateCustomSkills: [CandidateCustomSkill] = []

    var searchText = ""
    var selectedCategory: String?

    var isLoading = false
    var isSaving = false
    var errorMessage: String?

    private let skillRepository: SkillRepository
    private let candidateProfileRepository: CandidateProfileRepository
    private let candidateId: UUID

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
        Array(
            Set(
                skills
                    .map(\.category)
                    .filter { !$0.isEmpty }
            )
        )
        .sorted {
            $0.localizedCaseInsensitiveCompare($1) == .orderedAscending
        }
    }

    var filteredSkills: [Skill] {
        let query = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        return skills.filter { skill in
            let matchesSearch =
                query.isEmpty ||
                skill.name.localizedCaseInsensitiveContains(query) ||
                skill.category.localizedCaseInsensitiveContains(query)

            let matchesCategory =
                selectedCategory == nil ||
                skill.category == selectedCategory

            return matchesSearch && matchesCategory
        }
    }
    var selectedSkills: [Skill] {
        skills.filter { skill in
            candidateSkills.contains {
                $0.skillId == skill.id
            }
        }
    }

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
            async let skillsRequest = skillRepository.fetchSkills()

            async let candidateSkillsRequest =
                skillRepository.fetchCandidateSkills(
                    candidateId: candidateId
                )

            async let customSkillsRequest =
                skillRepository.fetchCandidateCustomSkills(
                    candidateId: candidateId
                )

            let (
                loadedSkills,
                loadedCandidateSkills,
                loadedCustomSkills
            ) = try await (
                skillsRequest,
                candidateSkillsRequest,
                customSkillsRequest
            )

            skills = loadedSkills
            candidateSkills = loadedCandidateSkills
            candidateCustomSkills = loadedCustomSkills
        } catch {
            errorMessage = error.localizedDescription
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
            errorMessage = "Gib einen Skill oder eine Systemkenntnis ein."
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
        guard !candidateSkills.isEmpty || !candidateCustomSkills.isEmpty else {
            errorMessage = "Wähle mindestens einen Skill oder eine Systemkenntnis aus."
            return false
        }

        errorMessage = nil

        do {
            try await candidateProfileRepository.updateOnboardingStep(
                userId: candidateId,
                step: 3
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
            candidateSkills = try await skillRepository.fetchCandidateSkills(
                candidateId: candidateId
            )
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
