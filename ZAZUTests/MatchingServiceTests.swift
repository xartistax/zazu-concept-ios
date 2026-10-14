//
//  MatchingServiceTests.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 29.09.2026.
//

import Foundation
import Testing
@testable import ZAZU

struct MatchingServiceTests {

    private let service = MatchingService()

    // MARK: - Skills

    @Test
    func skillAboveMinimumIsFulfilled() {
        let skillId = UUID()

        let candidateSkill = CandidateSkill(
            candidateId: UUID(),
            skillId: skillId,
            proficiency: .expert
        )

        let requirement = JobSkillRequirement(
            jobId: UUID(),
            skillId: skillId,
            minimumProficiency: .veryGood,
            requirementType: .must
        )

        #expect(
            service.fulfillsSkill(
                candidateSkill: candidateSkill,
                requirement: requirement
            )
        )
    }

    @Test
    func skillBelowMinimumIsNotFulfilled() {
        let skillId = UUID()

        let candidateSkill = CandidateSkill(
            candidateId: UUID(),
            skillId: skillId,
            proficiency: .good
        )

        let requirement = JobSkillRequirement(
            jobId: UUID(),
            skillId: skillId,
            minimumProficiency: .veryGood,
            requirementType: .must
        )

        #expect(
            !service.fulfillsSkill(
                candidateSkill: candidateSkill,
                requirement: requirement
            )
        )
    }

    @Test
    func missingSkillIsNotFulfilled() {
        let requirement = JobSkillRequirement(
            jobId: UUID(),
            skillId: UUID(),
            minimumProficiency: .basic,
            requirementType: .must
        )

        #expect(
            !service.fulfillsSkill(
                candidateSkill: nil,
                requirement: requirement
            )
        )
    }

    // MARK: - Languages

    @Test
    func languageAboveMinimumIsFulfilled() {
        let languageId = UUID()

        let candidateLanguage = CandidateLanguage(
            candidateId: UUID(),
            languageId: languageId,
            proficiency: .c1
        )

        let requirement = JobLanguageRequirement(
            jobId: UUID(),
            languageId: languageId,
            minimumProficiency: .b2,
            requirementType: .must
        )

        #expect(
            service.fulfillsLanguage(
                candidateLanguage: candidateLanguage,
                requirement: requirement
            )
        )
    }

    @Test
    func languageBelowMinimumIsNotFulfilled() {
        let languageId = UUID()

        let candidateLanguage = CandidateLanguage(
            candidateId: UUID(),
            languageId: languageId,
            proficiency: .b1
        )

        let requirement = JobLanguageRequirement(
            jobId: UUID(),
            languageId: languageId,
            minimumProficiency: .b2,
            requirementType: .must
        )

        #expect(
            !service.fulfillsLanguage(
                candidateLanguage: candidateLanguage,
                requirement: requirement
            )
        )
    }

    // MARK: - Salary

    @Test
    func overlappingSalaryRangesAreCompatible() {
        #expect(
            service.salaryRangesOverlap(
                candidateMin: 120_000,
                candidateMax: 130_000,
                jobMin: 115_000,
                jobMax: 135_000
            )
        )
    }
    
    
    @Test
    func salaryMismatchDoesNotBlockMatch() {
        let result = service.match(
            candidate: makeCandidate(),
            candidateSkills: [],
            candidateLanguages: [],
            candidateEducations: [],
            workExperiences: [],
            job: makeJob(
                salaryMin: 150_000,
                salaryMax: 170_000
            ),
            skillRequirements: [],
            languageRequirements: [],
            educationRequirements: []
        )

        #expect(!result.salaryCompatibility.isFulfilled)
        #expect(result.fulfillsAllMustCriteria)

        #expect(
            !result.missingMustCriteria.contains {
                $0.type == .salary
            }
        )
    }

    @Test
    func nonOverlappingSalaryRangesAreNotCompatible() {
        #expect(
            !service.salaryRangesOverlap(
                candidateMin: 90_000,
                candidateMax: 105_000,
                jobMin: 115_000,
                jobMax: 135_000
            )
        )
    }

    // MARK: - Workload

    @Test
    func workloadTouchingAtBoundaryOverlaps() {
        #expect(
            service.workloadRangesOverlap(
                candidateMin: 60,
                candidateMax: 80,
                jobMin: 80,
                jobMax: 100
            )
        )
    }

    @Test
    func nonOverlappingWorkloadDoesNotOverlap() {
        #expect(
            !service.workloadRangesOverlap(
                candidateMin: 40,
                candidateMax: 60,
                jobMin: 80,
                jobMax: 100
            )
        )
    }
    
    
    
    @Test
    func missingMustSkillBlocksMatch() {
        let skillId = UUID()

        let job = makeJob()

        let requirement = JobSkillRequirement(
            jobId: job.id,
            skillId: skillId,
            minimumProficiency: .veryGood,
            requirementType: .must
        )

        let result = service.match(
            candidate: makeCandidate(),
            candidateSkills: [],
            candidateLanguages: [],
            candidateEducations: [],
            workExperiences: [],
            job: job,
            skillRequirements: [requirement],
            languageRequirements: [],
            educationRequirements: []
        )

        #expect(!result.fulfillsAllMustCriteria)
        #expect(result.missingMustCriteria.count == 1)
        #expect(result.missingMustCriteria.first?.type == .skill)
    }

    @Test
    func missingOptionalSkillDoesNotBlockMatch() {
        let skillId = UUID()

        let job = makeJob()

        let requirement = JobSkillRequirement(
            jobId: job.id,
            skillId: skillId,
            minimumProficiency: .veryGood,
            requirementType: .optional
        )

        let result = service.match(
            candidate: makeCandidate(),
            candidateSkills: [],
            candidateLanguages: [],
            candidateEducations: [],
            workExperiences: [],
            job: job,
            skillRequirements: [requirement],
            languageRequirements: [],
            educationRequirements: []
        )

        #expect(result.fulfillsAllMustCriteria)
        #expect(result.missingMustCriteria.isEmpty)

        #expect(
            result.missingOptionalCriteria.contains {
                $0.type == .skill
            }
        )
    }
    
    
    
    // MARK: - Work Authorization

    @Test
    func workAuthorizationFulfillsRequirement() {
        let job = makeJob(
            requiresWorkAuthorization: true
        )

        let candidate = makeCandidate(
            hasWorkAuthorization: true,

        )

        let result = service.match(
            candidate: candidate,
            candidateSkills: [],
            candidateLanguages: [],
            candidateEducations: [],
            workExperiences: [],
            job: job,
            skillRequirements: [],
            languageRequirements: [],
            educationRequirements: []
        )

        #expect(result.fulfillsAllMustCriteria)

        #expect(
            result.fulfilledMustCriteria.contains {
                $0.type == .workAuthorization
            }
        )
    }



    @Test
    func missingWorkAuthorizationBlocksMatch() {
        let job = makeJob(
            requiresWorkAuthorization: true,
           
        )

        let candidate = makeCandidate(
            hasWorkAuthorization: false,
        
        )

        let result = service.match(
            candidate: candidate,
            candidateSkills: [],
            candidateLanguages: [],
            candidateEducations: [],
            workExperiences: [],
            job: job,
            skillRequirements: [],
            languageRequirements: [],
            educationRequirements: []
        )

        #expect(!result.fulfillsAllMustCriteria)

        #expect(
            result.missingMustCriteria.contains {
                $0.type == .workAuthorization
            }
        )
    }
    
    @Test
    func overlappingWorkExperiencesAreNotDoubleCounted() {
        let candidateId = UUID()

        let first = WorkExperience(
            id: UUID(),
            candidateId: candidateId,
            jobTitle: "Developer",
            employerName: "Company A",
            location: nil,
            startDate: "2020-01-01",
            endDate: "2023-01-01",
            isCurrent: false,
            description: nil
        )

        let second = WorkExperience(
            id: UUID(),
            candidateId: candidateId,
            jobTitle: "Consultant",
            employerName: "Company B",
            location: nil,
            startDate: "2022-01-01",
            endDate: "2024-01-01",
            isCurrent: false,
            description: nil
        )

        let years = service.totalWorkExperienceYears(
            workExperiences: [first, second]
        )

        #expect(years >= 3.99)
        #expect(years <= 4.01)
    }
    
    
    
    @Test
    func missingRequiredWorkExperienceBlocksMatch() {
        let job = makeJob(
            requiredWorkExperienceYears: 3,
            workExperienceRequirementType: .must
        )

        let result = service.match(
            candidate: makeCandidate(),
            candidateSkills: [],
            candidateLanguages: [],
            candidateEducations: [],
            workExperiences: [],
            job: job,
            skillRequirements: [],
            languageRequirements: [],
            educationRequirements: []
        )

        #expect(!result.fulfillsAllMustCriteria)

        #expect(
            result.missingMustCriteria.contains {
                $0.type == .workExperience
            }
        )
    }

    @Test
    func sufficientRequiredWorkExperienceFulfillsMustCriterion() {
        let candidate = makeCandidate()

        let experience = WorkExperience(
            id: UUID(),
            candidateId: candidate.userId,
            jobTitle: "Developer",
            employerName: "Test AG",
            location: nil,
            startDate: "2020-01-01",
            endDate: "2024-01-01",
            isCurrent: false,
            description: nil
        )

        let job = makeJob(
            requiredWorkExperienceYears: 3,
            workExperienceRequirementType: .must
        )

        let result = service.match(
            candidate: candidate,
            candidateSkills: [],
            candidateLanguages: [],
            candidateEducations: [],
            workExperiences: [experience],
            job: job,
            skillRequirements: [],
            languageRequirements: [],
            educationRequirements: []
        )

        #expect(result.fulfillsAllMustCriteria)

        #expect(
            result.fulfilledMustCriteria.contains {
                $0.type == .workExperience
            }
        )
    }
    
    
    @Test
    func calculatesWorkExperienceYears() {
        let experience = WorkExperience(
            id: UUID(),
            candidateId: UUID(),
            jobTitle: "Developer",
            employerName: "Test AG",
            location: "Zürich",
            startDate: "2020-01-01",
            endDate: "2024-01-01",
            isCurrent: false,
            description: nil
        )

        let years = service.totalWorkExperienceYears(
            workExperiences: [experience]
        )

        #expect(years >= 3.99)
        #expect(years <= 4.01)
    }
    
    
    
    // MARK: - Homeoffice

    @Test
    func matchingHomeofficePreferenceIsFulfilled() {
        let candidate = makeCandidate()

        let job = makeJob()

        let result = service.match(
            candidate: candidate,
            candidateSkills: [],
            candidateLanguages: [],
            candidateEducations: [],
            workExperiences: [],
            job: job,
            skillRequirements: [],
            languageRequirements: [],
            educationRequirements: []
        )

        #expect(result.homeofficeCompatibility.isFulfilled)
        #expect(result.homeofficeCompatibility.type == .homeoffice)
    }

    @Test
    func insufficientHomeofficeDaysAreNotFulfilled() {
        let candidate = makeCandidate(
            desiredHomeofficeDays: 3
        )

        let job = makeJob(
            homeofficeDays: 2
        )

        let result = service.match(
            candidate: candidate,
            candidateSkills: [],
            candidateLanguages: [],
            candidateEducations: [],
            workExperiences: [],
            job: job,
            skillRequirements: [],
            languageRequirements: [],
            educationRequirements: []
        )

        #expect(!result.homeofficeCompatibility.isFulfilled)
    }

    @Test
    func differentHomeofficeScheduleIsNotFulfilled() {
        let candidate = makeCandidate(
            preferredHomeofficeSchedule: .flexible
        )

        let job = makeJob(
            homeofficeSchedule: .fixed
        )

        let result = service.match(
            candidate: candidate,
            candidateSkills: [],
            candidateLanguages: [],
            candidateEducations: [],
            workExperiences: [],
            job: job,
            skillRequirements: [],
            languageRequirements: [],
            educationRequirements: []
        )

        #expect(!result.homeofficeCompatibility.isFulfilled)
    }
    
    
    
    // MARK: - Location

    @Test
    func sameLocationHasZeroDistance() {
        let distance = service.distanceInKilometers(
            fromLatitude: 47.3769,
            fromLongitude: 8.5417,
            toLatitude: 47.3769,
            toLongitude: 8.5417
        )

        #expect(distance < 0.01)
    }

    @Test
    func zurichToBadenHasPlausibleDistance() {
        let distance = service.distanceInKilometers(
            fromLatitude: 47.3769,
            fromLongitude: 8.5417,
            toLatitude: 47.4733,
            toLongitude: 8.3059
        )

        #expect(distance > 15)
        #expect(distance < 25)
    }
    
    
    
    @Test
    func jobInsideWorkRadiusFulfillsLocation() {
        let candidate = makeCandidate(
            desiredWorkLatitude: 47.3769,
            desiredWorkLongitude: 8.5417,
            workRadiusKm: 30,
            willingToCommute: false,
            willingToRelocate: false
        )

        let job = makeJob(
            latitude: 47.4733,
            longitude: 8.3059
        )

        let result = service.match(
            candidate: candidate,
            candidateSkills: [],
            candidateLanguages: [],
            candidateEducations: [],
            workExperiences: [],
            job: job,
            skillRequirements: [],
            languageRequirements: [],
            educationRequirements: []
        )

        let location = result.optionalCriteria.first {
            $0.type == .location
        }

        #expect(location?.isFulfilled == true)
    }

    @Test
    func jobOutsideWorkRadiusDoesNotFulfillLocation() {
        let candidate = makeCandidate(
            desiredWorkLatitude: 47.3769,
            desiredWorkLongitude: 8.5417,
            workRadiusKm: 10,
            willingToCommute: false,
            willingToRelocate: false
        )

        let job = makeJob(
            latitude: 46.9480,
            longitude: 7.4474
        )

        let result = service.match(
            candidate: candidate,
            candidateSkills: [],
            candidateLanguages: [],
            candidateEducations: [],
            workExperiences: [],
            job: job,
            skillRequirements: [],
            languageRequirements: [],
            educationRequirements: []
        )

        let location = result.optionalCriteria.first {
            $0.type == .location
        }

        #expect(location?.isFulfilled == false)
    }

    @Test
    func relocationMakesOutsideLocationAcceptable() {
        let candidate = makeCandidate(
            desiredWorkLatitude: 47.3769,
            desiredWorkLongitude: 8.5417,
            workRadiusKm: 10,
            willingToCommute: false,
            willingToRelocate: true
        )

        let job = makeJob(
            latitude: 46.9480,
            longitude: 7.4474
        )

        let result = service.match(
            candidate: candidate,
            candidateSkills: [],
            candidateLanguages: [],
            candidateEducations: [],
            workExperiences: [],
            job: job,
            skillRequirements: [],
            languageRequirements: [],
            educationRequirements: []
        )

        let location = result.optionalCriteria.first {
            $0.type == .location
        }

        #expect(location?.isFulfilled == true)
    }
    
    
    
    @Test
    func scoreIsFullyTransparent() {
        let result = MatchResult(
            jobId: UUID(),
            mustCriteria: [
                MatchCriterion(
                    id: "must-1",
                    type: .skill,
                    title: "MUSS 1",
                    detail: "Erfüllt",
                    isFulfilled: true
                ),
                MatchCriterion(
                    id: "must-2",
                    type: .language,
                    title: "MUSS 2",
                    detail: "Nicht erfüllt",
                    isFulfilled: false
                )
            ],
            optionalCriteria: [
                MatchCriterion(
                    id: "optional-1",
                    type: .skill,
                    title: "Optional",
                    detail: "Erfüllt",
                    isFulfilled: true
                )
            ],
            salaryCompatibility: MatchCriterion(
                id: "salary",
                type: .salary,
                title: "Lohn",
                detail: "Erfüllt",
                isFulfilled: true
            ),
            workModelCompatibility: MatchCriterion(
                id: "work-model",
                type: .workModel,
                title: "Arbeitsmodell",
                detail: "Erfüllt",
                isFulfilled: true
            ),
            homeofficeCompatibility: MatchCriterion(
                id: "homeoffice",
                type: .homeoffice,
                title: "Homeoffice",
                detail: "Nicht erfüllt",
                isFulfilled: false
            )
        )

        #expect(result.scoredCriteria.count == 4)
        #expect(result.fulfilledScoredCriteria.count == 3)
        #expect(result.score == 75)
    }
    
    
    @Test
    func missingMustHomeofficeBlocksMatch() {
        let candidate = makeCandidate(
            desiredHomeofficeDays: 3
        )

        let job = makeJob(
            homeofficeDays: 2,
            homeofficeRequirementType: .must
        )

        let result = service.match(
            candidate: candidate,
            candidateSkills: [],
            candidateLanguages: [],
            candidateEducations: [],
            workExperiences: [],
            job: job,
            skillRequirements: [],
            languageRequirements: [],
            educationRequirements: []
        )

        #expect(!result.fulfillsAllMustCriteria)

        #expect(
            result.missingMustCriteria.contains {
                $0.type == .homeoffice
            }
        )

        #expect(!result.homeofficeCompatibility.isFulfilled)
    }
    
    
    @Test
    func missingMustLanguageBlocksMatch() {
        let languageId = UUID()
        let job = makeJob()

        let requirement = JobLanguageRequirement(
            jobId: job.id,
            languageId: languageId,
            minimumProficiency: .b2,
            requirementType: .must
        )

        let result = service.match(
            candidate: makeCandidate(),
            candidateSkills: [],
            candidateLanguages: [],
            candidateEducations: [],
            workExperiences: [],
            job: job,
            skillRequirements: [],
            languageRequirements: [requirement],
            educationRequirements: []
        )

        #expect(!result.fulfillsAllMustCriteria)

        #expect(
            result.missingMustCriteria.contains {
                $0.type == .language
            }
        )
    }

    @Test
    func missingOptionalLanguageDoesNotBlockMatch() {
        let languageId = UUID()
        let job = makeJob()

        let requirement = JobLanguageRequirement(
            jobId: job.id,
            languageId: languageId,
            minimumProficiency: .b2,
            requirementType: .optional
        )

        let result = service.match(
            candidate: makeCandidate(),
            candidateSkills: [],
            candidateLanguages: [],
            candidateEducations: [],
            workExperiences: [],
            job: job,
            skillRequirements: [],
            languageRequirements: [requirement],
            educationRequirements: []
        )

        #expect(result.fulfillsAllMustCriteria)
        #expect(result.missingMustCriteria.isEmpty)

        #expect(
            result.missingOptionalCriteria.contains {
                $0.type == .language
            }
        )
    }
    
    
    
    // MARK: - Education

    @Test
    func matchingEducationFulfillsRequirement() {
        let job = makeJob()

        let education = Education(
            id: UUID(),
            candidateId: UUID(),
            institutionName: "ZHAW",
            degree: "Bachelor",
            fieldOfStudy: "Informatik",
            startDate: nil,
            endDate: nil,
            isCurrent: false,
            description: nil
        )

        let requirement = JobEducationRequirement(
            id: UUID(),
            jobId: job.id,
            degree: "Bachelor",
            fieldOfStudy: "Informatik",
            requirementType: .must
        )

        let result = service.match(
            candidate: makeCandidate(),
            candidateSkills: [],
            candidateLanguages: [],
            candidateEducations: [education],
            workExperiences: [],
            job: job,
            skillRequirements: [],
            languageRequirements: [],
            educationRequirements: [requirement]
        )

        #expect(result.fulfillsAllMustCriteria)

        #expect(
            result.fulfilledMustCriteria.contains {
                $0.type == .education
            }
        )
    }

    @Test
    func missingMustEducationBlocksMatch() {
        let job = makeJob()

        let requirement = JobEducationRequirement(
            id: UUID(),
            jobId: job.id,
            degree: "Bachelor",
            fieldOfStudy: "Wirtschaftsinformatik",
            requirementType: .must
        )

        let result = service.match(
            candidate: makeCandidate(),
            candidateSkills: [],
            candidateLanguages: [],
            candidateEducations: [],
            workExperiences: [],
            job: job,
            skillRequirements: [],
            languageRequirements: [],
            educationRequirements: [requirement]
        )

        #expect(!result.fulfillsAllMustCriteria)

        #expect(
            result.missingMustCriteria.contains {
                $0.type == .education
            }
        )
    }

    @Test
    func missingOptionalEducationDoesNotBlockMatch() {
        let job = makeJob()

        let requirement = JobEducationRequirement(
            id: UUID(),
            jobId: job.id,
            degree: "Bachelor",
            fieldOfStudy: "Informatik",
            requirementType: .optional
        )

        let result = service.match(
            candidate: makeCandidate(),
            candidateSkills: [],
            candidateLanguages: [],
            candidateEducations: [],
            workExperiences: [],
            job: job,
            skillRequirements: [],
            languageRequirements: [],
            educationRequirements: [requirement]
        )

        #expect(result.fulfillsAllMustCriteria)

        #expect(
            result.missingOptionalCriteria.contains {
                $0.type == .education
            }
        )
    }
    
    
    
    private func makeCandidate(
        hasWorkAuthorization: Bool = true,
        desiredHomeofficeDays: Int = 2,
        preferredHomeofficeSchedule: HomeofficeSchedulePreference = .flexible,
        desiredWorkLatitude: Double = 47.3769,
        desiredWorkLongitude: Double = 8.5417,
        workRadiusKm: Int = 30,
        willingToCommute: Bool = true,
        willingToRelocate: Bool = false
    ) -> CandidateProfile {
        CandidateProfile(
            userId: UUID(),
            region: "Zürich",
            nationality: "Schweiz",
            hasWorkAuthorization: hasWorkAuthorization,
            workAuthorizationDetails: nil,
            onboardingStep: 8,
            onboardingCompleted: true,
            desiredWorkloadMin: 80,
            desiredWorkloadMax: 100,
            desiredWorkLocation: "Zürich",
            desiredWorkLatitude: desiredWorkLatitude,
            desiredWorkLongitude: desiredWorkLongitude,
            workRadiusKm: workRadiusKm,
            willingToCommute: willingToCommute,
            willingToRelocate: willingToRelocate,
            earliestStartDate: nil,
            preferredWorkModel: .hybrid,
            homeofficePreference: .yes,
            desiredHomeofficeDays: desiredHomeofficeDays,
            preferredHomeofficeSchedule: preferredHomeofficeSchedule,
            acceptsFullyRemote: true,
            salaryMin: 100_000,
            salaryMax: 130_000
        )
    }

    private func makeJob(
        requiresWorkAuthorization: Bool = false,
        workAuthorizationRequirementType: RequirementType = .must,
        requiredWorkExperienceYears: Int? = nil,
        workExperienceRequirementType: RequirementType = .optional,
        homeofficeDays: Int = 2,
        homeofficeSchedule: JobHomeofficeSchedule = .flexible,
        homeofficeRequirementType: RequirementType = .optional,
        latitude: Double = 47.3769,
        longitude: Double = 8.5417,
        salaryMin: Int? = 100_000,
        salaryMax: Int? = 130_000,
        
    ) -> Job {
        Job(
            id: UUID(),
            companyId: UUID(),
            title: "Test Job",
            description: "Test",
            activityArea: nil,
            isActive: true,
            location: "Zürich",
            latitude: latitude,
            longitude: longitude,
            workModel: .hybrid,
            workloadMin: 80,
            workloadMax: 100,
            earliestStartDate: nil,
            salaryMin: salaryMin,
            salaryMax: salaryMax,
            requiredWorkExperienceYears: requiredWorkExperienceYears,
            workExperienceRequirementType: workExperienceRequirementType,
            requiresWorkAuthorization: requiresWorkAuthorization,
            workAuthorizationRequirementType:
                workAuthorizationRequirementType,
            homeofficeAvailable: true,
            homeofficeDays: homeofficeDays,
            homeofficeSchedule: homeofficeSchedule,
            fullyRemoteAvailable: false,
            homeofficeRequirementType: homeofficeRequirementType,
            workModelRequirementType: .optional
        )
    }

    
    
    
    
    
    
    
}
