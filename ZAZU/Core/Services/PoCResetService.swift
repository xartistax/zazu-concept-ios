//
//  PoCResetService.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 02.10.2026.
//

import Foundation

final class PoCResetService {
    private let profileRepository: ProfileRepository
    private let candidateProfileRepository: CandidateProfileRepository
    private let workExperienceRepository: WorkExperienceRepository
    private let skillRepository: SkillRepository
    private let educationRepository: EducationRepository
    private let languageRepository: LanguageRepository
    private let candidateJobInteractionRepository: CandidateJobInteractionRepository
    private let matchRepository: MatchRepository

    init(
        profileRepository: ProfileRepository,
        candidateProfileRepository: CandidateProfileRepository,
        workExperienceRepository: WorkExperienceRepository,
        skillRepository: SkillRepository,
        educationRepository: EducationRepository,
        languageRepository: LanguageRepository,
        candidateJobInteractionRepository: CandidateJobInteractionRepository,
        matchRepository: MatchRepository
    ) {
        self.profileRepository = profileRepository
        self.candidateProfileRepository = candidateProfileRepository
        self.workExperienceRepository = workExperienceRepository
        self.skillRepository = skillRepository
        self.educationRepository = educationRepository
        self.languageRepository = languageRepository
        self.candidateJobInteractionRepository = candidateJobInteractionRepository
        self.matchRepository = matchRepository
    }

    func resetCandidate(
        userId: UUID
    ) async throws {
        // Der vollständige PoC-Reset entfernt weiterhin alle
        // Match- und Swipe-Daten des Kandidaten.
        try await matchRepository.deleteAllMatchesForPoC()

        try await candidateJobInteractionRepository.deleteAllInteractions(
            candidateId: userId
        )

        try await workExperienceRepository.deleteAll(
            candidateId: userId
        )

        try await skillRepository.deleteAllCandidateSkills(
            candidateId: userId
        )

        try await skillRepository.deleteAllCandidateCustomSkills(
            candidateId: userId
        )

        try await educationRepository.deleteAll(
            candidateId: userId
        )

        try await languageRepository.deleteAllCandidateLanguages(
            candidateId: userId
        )

        try await profileRepository.resetForPoC(
            userId: userId
        )

        try await candidateProfileRepository.resetForPoC(
            userId: userId
        )
    }
}
