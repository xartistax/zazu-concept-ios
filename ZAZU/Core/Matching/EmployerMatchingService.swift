
//
//  EmployerMatchingService.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 08.10.2026.
//

import Foundation

struct EmployerMatchingService {
    private let matchingService: MatchingService

    init(matchingService: MatchingService) {
        self.matchingService = matchingService
    }

    func matchCandidates(
        candidates: [EmployerCandidateMatchingInput],
        candidateSkills: [CandidateSkill],
        candidateLanguages: [CandidateLanguage],
        candidateEducations: [Education],
        workExperiences: [WorkExperience],
        job: Job,
        skillRequirements: [JobSkillRequirement],
        languageRequirements: [JobLanguageRequirement],
        educationRequirements: [JobEducationRequirement]
    ) -> [EmployerCandidateMatch] {
        candidates.map { candidate in
            let candidateId = candidate.userId

            let skills = candidateSkills.filter {
                $0.candidateId == candidateId
            }

            let languages = candidateLanguages.filter {
                $0.candidateId == candidateId
            }

            let educations = candidateEducations.filter {
                $0.candidateId == candidateId
            }

            let experiences = workExperiences.filter {
                $0.candidateId == candidateId
            }

            let result = matchingService.match(
                candidate: candidate.candidateProfile,
                candidateSkills: skills,
                candidateLanguages: languages,
                candidateEducations: educations,
                workExperiences: experiences,
                job: job,
                skillRequirements: skillRequirements,
                languageRequirements: languageRequirements,
                educationRequirements: educationRequirements
            )

            return EmployerCandidateMatch(
                candidate: candidate,
                matchResult: result
            )
        }
        .sorted {
            if $0.matchResult.fulfillsAllMustCriteria
                != $1.matchResult.fulfillsAllMustCriteria {
                return $0.matchResult.fulfillsAllMustCriteria
            }

            return $0.matchResult.score > $1.matchResult.score
        }
    }
}
