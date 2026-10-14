//
//  EmployerDiscoverViewModel.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 08.10.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class EmployerDiscoverViewModel {
    private let userId: UUID
    private let companyRepository: CompanyRepository
    private let jobRepository: JobRepository
    private let employerMatchingRepository: EmployerMatchingRepository
    private let employerMatchingService: EmployerMatchingService
    private let skillRepository: SkillRepository
    private let languageRepository: LanguageRepository

    var jobs: [Job] = []
    var skills: [Skill] = []
    var languages: [Language] = []
    var selectedJob: Job?
    var matches: [EmployerCandidateMatch] = []

    var isLoading = false
    var isDeciding = false
    var errorMessage: String?
    var mutualMatchId: UUID?

    init(
        userId: UUID,
        companyRepository: CompanyRepository,
        jobRepository: JobRepository,
        skillRepository: SkillRepository,
        languageRepository: LanguageRepository,
        employerMatchingRepository: EmployerMatchingRepository,
        employerMatchingService: EmployerMatchingService
    ) {
        self.userId = userId
        self.companyRepository = companyRepository
        self.jobRepository = jobRepository
        self.skillRepository = skillRepository
        self.languageRepository = languageRepository
        self.employerMatchingRepository = employerMatchingRepository
        self.employerMatchingService = employerMatchingService
    }

    func load() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            async let skillsTask = skillRepository.fetchSkills()
            async let languagesTask = languageRepository.fetchLanguages()

            guard let membership =
                try await companyRepository.fetchOwnMembership(
                    userId: userId
                )
            else {
                jobs = []
                selectedJob = nil
                matches = []

                skills = try await skillsTask
                languages = try await languagesTask
                return
            }

            let companyJobs = try await jobRepository.fetchJobs(
                companyId: membership.companyId
            )

            jobs = companyJobs.filter(\.isActive)

            skills = try await skillsTask
            languages = try await languagesTask

            guard let firstJob = jobs.first else {
                selectedJob = nil
                matches = []
                return
            }

            selectedJob = firstJob

            try await loadMatches(
                for: firstJob
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    
    func decide(
        candidateId: UUID,
        decision: String
    ) async {
        guard !isDeciding else {
            return
        }

        guard let job = selectedJob else {
            return
        }

        isDeciding = true
        errorMessage = nil
        mutualMatchId = nil

        defer {
            isDeciding = false
        }

        do {
            let matchId = try await employerMatchingRepository.saveDecision(
                jobId: job.id,
                candidateId: candidateId,
                decision: decision
            )

            if let matchId {
                mutualMatchId = matchId
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func selectJob(_ job: Job) async {
        guard selectedJob?.id != job.id else {
            return
        }

        selectedJob = job
        await reloadMatches()
    }

    func reloadMatches() async {
        guard let selectedJob else {
            matches = []
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            try await loadMatches(for: selectedJob)
        } catch {
            matches = []
            errorMessage = error.localizedDescription
        }
    }

    private func loadMatches(
        for job: Job
    ) async throws {
        matches = try await employerMatchingRepository.fetchMatches(
            for: job,
            matchingService: employerMatchingService
        )
    }
}
