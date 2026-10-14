//
//  EmployerSkillRequirementsViewModel.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 07.10.2026.
//

import Foundation
import Observation



struct EmployerSkillRequirementDraft: Identifiable {
    let skill: Skill
    var minimumProficiency: SkillProficiency
    var requirementType: RequirementType

    var id: UUID {
        skill.id
    }
}



@Observable
@MainActor
final class EmployerSkillRequirementsViewModel {
    
    var selectedRequirements: [EmployerSkillRequirementDraft] = []
    var skills: [Skill] = []
    var searchText = ""

    var isLoading = false
    var errorMessage: String?

    private let skillRepository: SkillRepository

    init(skillRepository: SkillRepository) {
        self.skillRepository = skillRepository
    }
    
    

    var filteredSkills: [Skill] {
        let query = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !query.isEmpty else {
            return skills
        }

        return skills.filter { skill in
            skill.name.localizedCaseInsensitiveContains(query)
        }
    }
    
    

    func loadSkills() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            skills = try await skillRepository.fetchSkills()
        } catch {
            skills = []
            errorMessage = error.localizedDescription
        }
    }
    
    
    
    
    func isSelected(_ skill: Skill) -> Bool {
        selectedRequirements.contains {
            $0.skill.id == skill.id
        }
    }

    func toggleSkill(_ skill: Skill) {
        if let index = selectedRequirements.firstIndex(
            where: { $0.skill.id == skill.id }
        ) {
            selectedRequirements.remove(at: index)
        } else {
            selectedRequirements.append(
                EmployerSkillRequirementDraft(
                    skill: skill,
                    minimumProficiency: .good,
                    requirementType: .optional
                )
            )
        }
    }

    func updateProficiency(
        skillId: UUID,
        proficiency: SkillProficiency
    ) {
        guard let index = selectedRequirements.firstIndex(
            where: { $0.skill.id == skillId }
        ) else {
            return
        }

        selectedRequirements[index].minimumProficiency = proficiency
    }

    func updateRequirementType(
        skillId: UUID,
        requirementType: RequirementType
    ) {
        guard let index = selectedRequirements.firstIndex(
            where: { $0.skill.id == skillId }
        ) else {
            return
        }

        selectedRequirements[index].requirementType = requirementType
    }
}
