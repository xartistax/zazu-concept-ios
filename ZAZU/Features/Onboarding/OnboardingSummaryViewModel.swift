//
//  OnboardingSummaryViewModel.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class OnboardingSummaryViewModel {

    var profile: CandidateProfile?
    var workExperiences: [WorkExperience] = []
    var skills: [Skill] = []
    var candidateSkills: [CandidateSkill] = []
    var educations: [Education] = []
    var languages: [Language] = []
    var candidateLanguages: [CandidateLanguage] = []
    var accountProfile: Profile?

    var isLoading = true
    var isCompleting = false
    var errorMessage: String?

    private let candidateProfileRepository: CandidateProfileRepository
    private let workExperienceRepository: WorkExperienceRepository
    private let skillRepository: SkillRepository
    private let educationRepository: EducationRepository
    private let languageRepository: LanguageRepository
    private let profileRepository: ProfileRepository
    private let userId: UUID

    init(
        profileRepository: ProfileRepository,
        candidateProfileRepository: CandidateProfileRepository,
        workExperienceRepository: WorkExperienceRepository,
        skillRepository: SkillRepository,
        educationRepository: EducationRepository,
        languageRepository: LanguageRepository,
        userId: UUID
    ) {
        self.profileRepository = profileRepository
        self.candidateProfileRepository = candidateProfileRepository
        self.workExperienceRepository = workExperienceRepository
        self.skillRepository = skillRepository
        self.educationRepository = educationRepository
        self.languageRepository = languageRepository
        self.userId = userId
    }

    // MARK: - Load

    func load() async {
        guard isLoading else {
            return
        }

        errorMessage = nil

        do {
            async let accountProfileRequest =
                profileRepository.fetchProfile(
                    userId: userId
                )

            async let candidateProfileRequest =
                candidateProfileRepository.fetchProfile(
                    userId: userId
                )

            async let workRequest =
                workExperienceRepository.fetchAll(
                    candidateId: userId
                )

            async let skillsRequest =
                skillRepository.fetchSkills()

            async let candidateSkillsRequest =
                skillRepository.fetchCandidateSkills(
                    candidateId: userId
                )

            async let educationRequest =
                educationRepository.fetchAll(
                    candidateId: userId
                )

            async let languagesRequest =
                languageRepository.fetchLanguages()

            async let candidateLanguagesRequest =
                languageRepository.fetchCandidateLanguages(
                    candidateId: userId
                )

            let (
                loadedAccountProfile,
                loadedCandidateProfile,
                loadedWork,
                loadedSkills,
                loadedCandidateSkills,
                loadedEducations,
                loadedLanguages,
                loadedCandidateLanguages
            ) = try await (
                accountProfileRequest,
                candidateProfileRequest,
                workRequest,
                skillsRequest,
                candidateSkillsRequest,
                educationRequest,
                languagesRequest,
                candidateLanguagesRequest
            )

            accountProfile = loadedAccountProfile
            profile = loadedCandidateProfile
            workExperiences = loadedWork
            skills = loadedSkills
            candidateSkills = loadedCandidateSkills
            educations = loadedEducations
            languages = loadedLanguages
            candidateLanguages = loadedCandidateLanguages

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Summary Data

    var selectedSkills: [(skill: Skill, proficiency: SkillProficiency)] {
        candidateSkills.compactMap { candidateSkill in
            guard let skill = skills.first(
                where: { $0.id == candidateSkill.skillId }
            ) else {
                return nil
            }

            return (
                skill: skill,
                proficiency: candidateSkill.proficiency
            )
        }
    }

    var selectedLanguages: [
        (language: Language, proficiency: LanguageProficiency)
    ] {
        candidateLanguages.compactMap { candidateLanguage in
            guard let language = languages.first(
                where: {
                    $0.id == candidateLanguage.languageId
                }
            ) else {
                return nil
            }

            return (
                language: language,
                proficiency: candidateLanguage.proficiency
            )
        }
    }
    
    
    
    func completeOnboarding() async -> Bool {
        guard !isCompleting else {
            return false
        }

        isCompleting = true
        errorMessage = nil

        defer {
            isCompleting = false
        }

        do {
            try await candidateProfileRepository.completeOnboarding(
                userId: userId
            )

            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
