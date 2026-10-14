//
//  DiscoverViewModel.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 29.09.2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class DiscoverViewModel {

    // MARK: - State

    var jobs: [Job] = []
    var companies: [Company] = []

    var skillRequirements: [JobSkillRequirement] = []
    var languageRequirements: [JobLanguageRequirement] = []
    var educationRequirements: [JobEducationRequirement] = []

    var skills: [Skill] = []
    var languages: [Language] = []

    var matchResults: [UUID: MatchResult] = [:]
    var mutualMatchId: UUID?
    var mutualMatchJob: Job?
    var isLoading = false
    var errorMessage: String?
    var isDeciding = false



    // MARK: - Dependencies

    private let jobRepository: JobRepository
    private let candidateProfileRepository: CandidateProfileRepository
    private let workExperienceRepository: WorkExperienceRepository
    private let skillRepository: SkillRepository
    private let languageRepository: LanguageRepository
    private let educationRepository: EducationRepository
    private let candidateJobInteractionRepository: CandidateJobInteractionRepository
    private let matchRepository: MatchRepository
    private let matchingService: MatchingService
    private let userId: UUID

    // MARK: - Init

    init(
        jobRepository: JobRepository,
        candidateProfileRepository: CandidateProfileRepository,
        workExperienceRepository: WorkExperienceRepository,
        skillRepository: SkillRepository,
        languageRepository: LanguageRepository,
        educationRepository: EducationRepository,
        candidateJobInteractionRepository: CandidateJobInteractionRepository,
        matchRepository: MatchRepository,
        userId: UUID
    ) {
        self.jobRepository = jobRepository
        self.candidateProfileRepository = candidateProfileRepository
        self.workExperienceRepository = workExperienceRepository
        self.skillRepository = skillRepository
        self.languageRepository = languageRepository
        self.educationRepository = educationRepository
        self.candidateJobInteractionRepository = candidateJobInteractionRepository
        self.matchRepository = matchRepository
        self.matchingService = MatchingService()
        self.userId = userId
    }
    // MARK: - State Helpers

    var isEmpty: Bool {
        !isLoading
            && errorMessage == nil
            && jobs.isEmpty
    }

    // MARK: - Loading

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            async let jobsRequest =
                jobRepository.fetchJobs()

            async let companiesRequest =
                jobRepository.fetchCompanies()

            async let skillRequirementsRequest =
                jobRepository.fetchSkillRequirements()

            async let languageRequirementsRequest =
                jobRepository.fetchLanguageRequirements()
            
            async let educationRequirementsRequest =
                jobRepository.fetchEducationRequirements()

            async let candidateRequest =
                candidateProfileRepository.fetchProfile(
                    userId: userId
                )

            async let candidateSkillsRequest =
                skillRepository.fetchCandidateSkills(
                    candidateId: userId
                )

            async let candidateLanguagesRequest =
                languageRepository.fetchCandidateLanguages(
                    candidateId: userId
                )
            async let candidateEducationsRequest =
                educationRepository.fetchAll(
                    candidateId: userId
                )

            async let workExperiencesRequest =
                workExperienceRepository.fetchAll(
                    candidateId: userId
                )

            async let skillsRequest =
                skillRepository.fetchSkills()

            async let languagesRequest =
                languageRepository.fetchLanguages()

            async let interactionsRequest =
                candidateJobInteractionRepository.fetchInteractions(
                    candidateId: userId
                )

            let (
                jobs,
                companies,
                skillRequirements,
                languageRequirements,
                educationRequirements,
                candidate,
                candidateSkills,
                candidateLanguages,
                candidateEducations,
                workExperiences,
                skills,
                languages,
                interactions
            ) = try await (
                jobsRequest,
                companiesRequest,
                skillRequirementsRequest,
                languageRequirementsRequest,
                educationRequirementsRequest,
                candidateRequest,
                candidateSkillsRequest,
                candidateLanguagesRequest,
                candidateEducationsRequest,
                workExperiencesRequest,
                skillsRequest,
                languagesRequest,
                interactionsRequest
            )

            let interactedJobIds = Set(
                interactions.map(\.jobId)
            )

            let availableJobs = jobs.filter {
                !interactedJobIds.contains($0.id)
            }
            
            self.jobs = availableJobs
            self.companies = companies
            self.skillRequirements = skillRequirements
            self.languageRequirements = languageRequirements
            self.skills = skills
            self.languages = languages
            self.educationRequirements = educationRequirements

            // MARK: Calculate Matches

            var results: [UUID: MatchResult] = [:]

            for job in availableJobs {
                let jobSkills = skillRequirements.filter {
                    $0.jobId == job.id
                }

                let jobLanguages = languageRequirements.filter {
                    $0.jobId == job.id
                }
                
                let jobEducations = educationRequirements.filter {
                    $0.jobId == job.id
                }

                let result = matchingService.match(
                    candidate: candidate,
                    candidateSkills: candidateSkills,
                    candidateLanguages: candidateLanguages,
                    candidateEducations: candidateEducations,
                    workExperiences: workExperiences,
                    job: job,
                    skillRequirements: jobSkills,
                    languageRequirements: jobLanguages,
                    educationRequirements: jobEducations
                )

                results[job.id] = result
            }

            matchResults = results

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
    
    
    
    func educationRequirements(
        for job: Job
    ) -> [JobEducationRequirement] {
        educationRequirements.filter {
            $0.jobId == job.id
        }
    }
    
    
    
    
    // MARK: - Swipe Decisions

    func decide(
        on job: Job,
        decision: CandidateJobDecision
    ) async -> Bool {
        guard !isDeciding else {
            return false
        }

        isDeciding = true
        errorMessage = nil

        defer {
            isDeciding = false
        }

        do {
            try await candidateJobInteractionRepository.saveDecision(
                candidateId: userId,
                jobId: job.id,
                decision: decision
            )

            if decision == .match {
                let matchId = try await matchRepository
                    .createMutualMatchIfEligible(
                        jobId: job.id
                    )

                if let matchId {
                    mutualMatchId = matchId
                    mutualMatchJob = job
                }
            }

            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Job Helpers

    func company(
        for job: Job
    ) -> Company? {
        companies.first {
            $0.id == job.companyId
        }
    }

    func matchResult(
        for job: Job
    ) -> MatchResult? {
        matchResults[job.id]
    }

    func skillRequirements(
        for job: Job
    ) -> [JobSkillRequirement] {
        skillRequirements.filter {
            $0.jobId == job.id
        }
    }

    func languageRequirements(
        for job: Job
    ) -> [JobLanguageRequirement] {
        languageRequirements.filter {
            $0.jobId == job.id
        }
    }

    // MARK: - Taxonomy Helpers

    func skillName(
        for skillId: UUID
    ) -> String {
        skills.first {
            $0.id == skillId
        }?.name ?? "Unbekannter Skill"
    }

    func languageName(
        for languageId: UUID
    ) -> String {
        languages.first {
            $0.id == languageId
        }?.name ?? "Unbekannte Sprache"
    }
}
