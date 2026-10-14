//
//  EmployerMatchingServiceTests.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 11.10.2026.
//



import Foundation
import Testing
@testable import ZAZU

struct EmployerMatchingServiceTests {

    private let matchingService = MatchingService()

    private var service: EmployerMatchingService {
        EmployerMatchingService(
            matchingService: matchingService
        )
    }

    // MARK: - Shared Matching Engine

    @Test
    func employerMatchingProducesSameResultAsMatchingService() {
        let candidate = makeCandidate(
            hasWorkAuthorization: true
        )

        let job = makeJob(
            requiresWorkAuthorization: true
        )

        let employerResults = service.matchCandidates(
            candidates: [candidate],
            candidateSkills: [],
            candidateLanguages: [],
            candidateEducations: [],
            workExperiences: [],
            job: job,
            skillRequirements: [],
            languageRequirements: [],
            educationRequirements: []
        )

        let directResult = matchingService.match(
            candidate: candidate.candidateProfile,
            candidateSkills: [],
            candidateLanguages: [],
            candidateEducations: [],
            workExperiences: [],
            job: job,
            skillRequirements: [],
            languageRequirements: [],
            educationRequirements: []
        )

        #expect(employerResults.count == 1)

        guard let employerResult = employerResults.first else {
            return
        }

        #expect(
            employerResult.matchResult.score
                == directResult.score
        )

        #expect(
            employerResult.matchResult.fulfillsAllMustCriteria
                == directResult.fulfillsAllMustCriteria
        )

        #expect(
            employerResult.matchResult.missingMustCriteria.count
                == directResult.missingMustCriteria.count
        )

        #expect(
            employerResult.matchResult.missingOptionalCriteria.count
                == directResult.missingOptionalCriteria.count
        )
    }

    // MARK: - Candidate Isolation

    @Test
    func candidateSkillsAreAssignedToCorrectCandidate() {
        let skillId = UUID()

        let matchingCandidate = makeCandidate()
        let missingCandidate = makeCandidate()

        let job = makeJob()

        let requirement = JobSkillRequirement(
            jobId: job.id,
            skillId: skillId,
            minimumProficiency: .veryGood,
            requirementType: .must
        )

        let skill = CandidateSkill(
            candidateId: matchingCandidate.userId,
            skillId: skillId,
            proficiency: .expert
        )

        let results = service.matchCandidates(
            candidates: [
                missingCandidate,
                matchingCandidate
            ],
            candidateSkills: [skill],
            candidateLanguages: [],
            candidateEducations: [],
            workExperiences: [],
            job: job,
            skillRequirements: [requirement],
            languageRequirements: [],
            educationRequirements: []
        )

        let matchingResult = results.first {
            $0.candidateId == matchingCandidate.userId
        }

        let missingResult = results.first {
            $0.candidateId == missingCandidate.userId
        }

        #expect(
            matchingResult?.matchResult.fulfillsAllMustCriteria == true
        )

        #expect(
            missingResult?.matchResult.fulfillsAllMustCriteria == false
        )
    }

    // MARK: - Sorting

    @Test
    func candidatesFulfillingMustCriteriaAreSortedFirst() {
        let passingCandidate = makeCandidate(
            hasWorkAuthorization: true
        )

        let failingCandidate = makeCandidate(
            hasWorkAuthorization: false
        )

        let job = makeJob(
            requiresWorkAuthorization: true
        )

        let results = service.matchCandidates(
            candidates: [
                failingCandidate,
                passingCandidate
            ],
            candidateSkills: [],
            candidateLanguages: [],
            candidateEducations: [],
            workExperiences: [],
            job: job,
            skillRequirements: [],
            languageRequirements: [],
            educationRequirements: []
        )

        #expect(results.count == 2)
        #expect(results.first?.candidateId == passingCandidate.userId)
        #expect(
            results.first?.matchResult.fulfillsAllMustCriteria == true
        )
    }

    @Test
    func higherScoreIsSortedFirstWhenMustStatusIsEqual() {
        let matchingCandidate = makeCandidate(
            salaryMin: 100_000,
            salaryMax: 130_000
        )

        let salaryMismatchCandidate = makeCandidate(
            salaryMin: 160_000,
            salaryMax: 180_000
        )

        let job = makeJob(
            salaryMin: 100_000,
            salaryMax: 130_000
        )

        let results = service.matchCandidates(
            candidates: [
                salaryMismatchCandidate,
                matchingCandidate
            ],
            candidateSkills: [],
            candidateLanguages: [],
            candidateEducations: [],
            workExperiences: [],
            job: job,
            skillRequirements: [],
            languageRequirements: [],
            educationRequirements: []
        )

        #expect(results.count == 2)

        #expect(
            results.allSatisfy {
                $0.matchResult.fulfillsAllMustCriteria
            }
        )

        #expect(
            results.first?.candidateId
                == matchingCandidate.userId
        )

        if results.count == 2 {
            #expect(
                results[0].matchResult.score
                    > results[1].matchResult.score
            )
        }
    }

    // MARK: - Helpers

    private func makeCandidate(
        hasWorkAuthorization: Bool = true,
        salaryMin: Int? = 100_000,
        salaryMax: Int? = 130_000
    ) -> EmployerCandidateMatchingInput {
        EmployerCandidateMatchingInput(
            userId: UUID(),
            hasWorkAuthorization: hasWorkAuthorization,
            desiredWorkloadMin: 80,
            desiredWorkloadMax: 100,
            desiredWorkLatitude: 47.3769,
            desiredWorkLongitude: 8.5417,
            workRadiusKm: 30,
            willingToCommute: true,
            willingToRelocate: false,
            preferredWorkModel: .hybrid,
            homeofficePreference: .yes,
            desiredHomeofficeDays: 2,
            preferredHomeofficeSchedule: .flexible,
            acceptsFullyRemote: true,
            salaryMin: salaryMin,
            salaryMax: salaryMax
        )
    }

    private func makeJob(
        requiresWorkAuthorization: Bool = false,
        salaryMin: Int? = 100_000,
        salaryMax: Int? = 130_000
    ) -> Job {
        Job(
            id: UUID(),
            companyId: UUID(),
            title: "Test Job",
            description: "Test",
            activityArea: nil,
            isActive: true,
            location: "Zürich",
            latitude: 47.3769,
            longitude: 8.5417,
            workModel: .hybrid,
            workloadMin: 80,
            workloadMax: 100,
            earliestStartDate: nil,
            salaryMin: salaryMin,
            salaryMax: salaryMax,
            requiredWorkExperienceYears: nil,
            workExperienceRequirementType: .optional,
            requiresWorkAuthorization: requiresWorkAuthorization,
            workAuthorizationRequirementType: .must,
            homeofficeAvailable: true,
            homeofficeDays: 2,
            homeofficeSchedule: .flexible,
            fullyRemoteAvailable: false,
            homeofficeRequirementType: .optional,
            workModelRequirementType: .optional
        )
    }
}
