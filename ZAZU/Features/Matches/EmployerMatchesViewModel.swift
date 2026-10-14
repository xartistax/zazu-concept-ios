//
//  EmployerMatchesViewModel.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 10.10.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class EmployerMatchesViewModel {
    private let matchRepository: MatchRepository
    private let jobRepository: JobRepository
    private let companyRepository: CompanyRepository
    
    private let employerMatchingRepository: EmployerMatchingRepository
    private let employerMatchingService: EmployerMatchingService
    
    private let skillRepository: SkillRepository
    private let languageRepository: LanguageRepository
    
    private let userId: UUID

    var matches: [Match] = []
    var jobs: [Job] = []

    var isLoading = false
    var errorMessage: String?
    
    var skills: [Skill] = []
    var languages: [Language] = []

    init(
        matchRepository: MatchRepository,
        jobRepository: JobRepository,
        companyRepository: CompanyRepository,
        skillRepository: SkillRepository,
        languageRepository: LanguageRepository,
        employerMatchingRepository: EmployerMatchingRepository,
        employerMatchingService: EmployerMatchingService,
        userId: UUID
    ) {
        self.matchRepository = matchRepository
        self.jobRepository = jobRepository
        self.companyRepository = companyRepository
        self.skillRepository = skillRepository
        self.languageRepository = languageRepository
        self.employerMatchingRepository = employerMatchingRepository
        self.employerMatchingService = employerMatchingService
        self.userId = userId
    }

    func load() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            guard let membership =
                try await companyRepository.fetchOwnMembership(
                    userId: userId
                )
            else {
                matches = []
                jobs = []
                return
            }

            async let matchesTask =
                matchRepository.fetchEmployerMatches()

            async let jobsTask =
                jobRepository.fetchJobs(
                    companyId: membership.companyId
                )

            async let skillsTask =
                skillRepository.fetchSkills()

            async let languagesTask =
                languageRepository.fetchLanguages()

            let (
                loadedMatches,
                loadedJobs,
                loadedSkills,
                loadedLanguages
            ) = try await (
                matchesTask,
                jobsTask,
                skillsTask,
                languagesTask
            )

            matches = loadedMatches
            jobs = loadedJobs
            skills = loadedSkills
            languages = loadedLanguages
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func job(
        for match: Match
    ) -> Job? {
        jobs.first {
            $0.id == match.jobId
        }
    }
    
    
    func candidateMatch(
        for match: Match,
        job: Job
    ) async throws -> EmployerCandidateMatch? {
        guard let data =
            try await employerMatchingRepository.fetchMatchedCandidateData(
                matchId: match.id,
                job: job
            )
        else {
            return nil
        }

        return employerMatchingService.matchCandidates(
            candidates: data.candidates,
            candidateSkills: data.candidateSkills,
            candidateLanguages: data.candidateLanguages,
            candidateEducations: data.candidateEducations,
            workExperiences: data.workExperiences,
            job: job,
            skillRequirements: data.skillRequirements,
            languageRequirements: data.languageRequirements,
            educationRequirements: data.educationRequirements
        )
        .first
    }
}
