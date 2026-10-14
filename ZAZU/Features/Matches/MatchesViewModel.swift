//
//  MatchesViewModel.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 03.10.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class MatchesViewModel {
    private let matchRepository: MatchRepository
    private let jobRepository: JobRepository
    private let interviewRepository: InterviewRepository
    
    private let candidateProfileRepository: CandidateProfileRepository
    private let workExperienceRepository: WorkExperienceRepository
    private let skillRepository: SkillRepository
    private let languageRepository: LanguageRepository
    private let educationRepository: EducationRepository
    private let matchingService: MatchingService
    
    private let userId: UUID

    var matches: [Match] = []
    var jobs: [Job] = []
    var companies: [Company] = []
    var interviews: [Interview] = []
    
    var skillRequirements: [JobSkillRequirement] = []
    var languageRequirements: [JobLanguageRequirement] = []
    var educationRequirements: [JobEducationRequirement] = []

    var skills: [Skill] = []
    var languages: [Language] = []

    var matchResults: [UUID: MatchResult] = [:]

    var isLoading = false
    var errorMessage: String?

    init(
        matchRepository: MatchRepository,
        jobRepository: JobRepository,
        interviewRepository: InterviewRepository,
        candidateProfileRepository: CandidateProfileRepository,
        workExperienceRepository: WorkExperienceRepository,
        skillRepository: SkillRepository,
        languageRepository: LanguageRepository,
        educationRepository: EducationRepository,
        userId: UUID
    ) {
        self.matchRepository = matchRepository
        self.jobRepository = jobRepository
        self.interviewRepository = interviewRepository
        self.candidateProfileRepository = candidateProfileRepository
        self.workExperienceRepository = workExperienceRepository
        self.skillRepository = skillRepository
        self.languageRepository = languageRepository
        self.educationRepository = educationRepository
        self.matchingService = MatchingService()
        self.userId = userId
    }

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            async let matchesTask =
                matchRepository.fetchMatches(
                    candidateId: userId
                )

            async let jobsTask =
                jobRepository.fetchJobs()

            async let companiesTask =
                jobRepository.fetchCompanies()

            async let skillRequirementsTask =
                jobRepository.fetchSkillRequirements()

            async let languageRequirementsTask =
                jobRepository.fetchLanguageRequirements()

            async let educationRequirementsTask =
                jobRepository.fetchEducationRequirements()

            async let candidateTask =
                candidateProfileRepository.fetchProfile(
                    userId: userId
                )

            async let candidateSkillsTask =
                skillRepository.fetchCandidateSkills(
                    candidateId: userId
                )

            async let candidateLanguagesTask =
                languageRepository.fetchCandidateLanguages(
                    candidateId: userId
                )

            async let candidateEducationsTask =
                educationRepository.fetchAll(
                    candidateId: userId
                )

            async let workExperiencesTask =
                workExperienceRepository.fetchAll(
                    candidateId: userId
                )

            async let skillsTask =
                skillRepository.fetchSkills()

            async let languagesTask =
                languageRepository.fetchLanguages()

            let (
                loadedMatches,
                loadedJobs,
                loadedCompanies,
                loadedSkillRequirements,
                loadedLanguageRequirements,
                loadedEducationRequirements,
                candidate,
                candidateSkills,
                candidateLanguages,
                candidateEducations,
                workExperiences,
                loadedSkills,
                loadedLanguages
            ) = try await (
                matchesTask,
                jobsTask,
                companiesTask,
                skillRequirementsTask,
                languageRequirementsTask,
                educationRequirementsTask,
                candidateTask,
                candidateSkillsTask,
                candidateLanguagesTask,
                candidateEducationsTask,
                workExperiencesTask,
                skillsTask,
                languagesTask
            )

            var loadedInterviews: [Interview] = []

            for match in loadedMatches {
                if let interview =
                    try await interviewRepository.fetchInterview(
                        matchId: match.id
                    ) {
                    loadedInterviews.append(interview)
                }
            }

            var loadedMatchResults: [UUID: MatchResult] = [:]

            for match in loadedMatches {
                guard let job = loadedJobs.first(
                    where: { $0.id == match.jobId }
                ) else {
                    continue
                }

                let jobSkills = loadedSkillRequirements.filter {
                    $0.jobId == job.id
                }

                let jobLanguages = loadedLanguageRequirements.filter {
                    $0.jobId == job.id
                }

                let jobEducations = loadedEducationRequirements.filter {
                    $0.jobId == job.id
                }

                loadedMatchResults[job.id] =
                    matchingService.match(
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
            }

            matches = loadedMatches
            jobs = loadedJobs
            companies = loadedCompanies
            interviews = loadedInterviews

            skillRequirements = loadedSkillRequirements
            languageRequirements = loadedLanguageRequirements
            educationRequirements = loadedEducationRequirements

            skills = loadedSkills
            languages = loadedLanguages
            matchResults = loadedMatchResults

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func job(
        for match: Match
    ) -> Job? {
        jobs.first {
            $0.id == match.jobId
        }
    }

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

    func educationRequirements(
        for job: Job
    ) -> [JobEducationRequirement] {
        educationRequirements.filter {
            $0.jobId == job.id
        }
    }

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
    
    func interview(
        for match: Match
    ) -> Interview? {
        interviews.first {
            $0.matchId == match.id
        }
    }

    func hasConfirmedInterview(
        for match: Match
    ) -> Bool {
        interview(for: match) != nil
    }
}
