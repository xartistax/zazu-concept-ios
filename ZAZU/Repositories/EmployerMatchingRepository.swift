//
//  EmployerMatchingRepository.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 08.10.2026.
//

import Foundation
import Supabase

final class EmployerMatchingRepository {
    private let candidateProfileRepository: CandidateProfileRepository
    private let skillRepository: SkillRepository
    private let languageRepository: LanguageRepository
    private let educationRepository: EducationRepository
    private let workExperienceRepository: WorkExperienceRepository
    private let jobRepository: JobRepository
    private let client: SupabaseClient

    init(
        client: SupabaseClient,
        candidateProfileRepository: CandidateProfileRepository,
        skillRepository: SkillRepository,
        languageRepository: LanguageRepository,
        educationRepository: EducationRepository,
        workExperienceRepository: WorkExperienceRepository,
        jobRepository: JobRepository
    ) {
        self.client = client
        self.candidateProfileRepository = candidateProfileRepository
        self.skillRepository = skillRepository
        self.languageRepository = languageRepository
        self.educationRepository = educationRepository
        self.workExperienceRepository = workExperienceRepository
        self.jobRepository = jobRepository
    }
    
    func fetchMatchedCandidate(
        matchId: UUID
    ) async throws -> EmployerCandidateMatchingInput? {
        struct Params: Encodable {
            let matchId: UUID

            enum CodingKeys: String, CodingKey {
                case matchId = "p_match_id"
            }
        }

        let response = try await client
            .rpc(
                "get_employer_matched_candidate",
                params: Params(matchId: matchId)
            )
            .execute()

        let candidates = try JSONDecoder().decode(
            [EmployerCandidateMatchingInput].self,
            from: response.data
        )

        return candidates.first
    }
    
    func fetchMatchedCandidateData(
        matchId: UUID,
        job: Job
    ) async throws -> EmployerMatchingData? {
        guard let candidate = try await fetchMatchedCandidate(
            matchId: matchId
        ) else {
            return nil
        }

        let data = try await fetchMatchingData(for: job)
        let candidateId = candidate.userId

        return EmployerMatchingData(
            candidates: [candidate],
            candidateSkills: data.candidateSkills.filter {
                $0.candidateId == candidateId
            },
            candidateLanguages: data.candidateLanguages.filter {
                $0.candidateId == candidateId
            },
            candidateEducations: data.candidateEducations.filter {
                $0.candidateId == candidateId
            },
            workExperiences: data.workExperiences.filter {
                $0.candidateId == candidateId
            },
            skillRequirements: data.skillRequirements,
            languageRequirements: data.languageRequirements,
            educationRequirements: data.educationRequirements
        )
    }
    
    
    func saveDecision(
        jobId: UUID,
        candidateId: UUID,
        decision: String
    ) async throws -> UUID? {
        struct Params: Encodable {
            let jobId: UUID
            let candidateId: UUID
            let decision: String

            enum CodingKeys: String, CodingKey {
                case jobId = "p_job_id"
                case candidateId = "p_candidate_id"
                case decision = "p_decision"
            }
        }

        let response = try await client
            .rpc(
                "save_employer_candidate_decision",
                params: Params(
                    jobId: jobId,
                    candidateId: candidateId,
                    decision: decision
                )
            )
            .execute()

      

        return try JSONDecoder().decode(
            UUID?.self,
            from: response.data
        )
    }
    
    
    func fetchMatches(
        for job: Job,
        matchingService: EmployerMatchingService
    ) async throws -> [EmployerCandidateMatch] {
        let data = try await fetchMatchingData(for: job)

        return matchingService.matchCandidates(
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
    }
    
    

    func fetchMatchingData(
        for job: Job
    ) async throws -> EmployerMatchingData {
        async let candidates = candidateProfileRepository
            .fetchEmployerMatchingCandidates(jobId: job.id)

        async let skills = skillRepository
            .fetchEmployerCandidateSkills(jobId: job.id)

        async let languages = languageRepository
            .fetchEmployerCandidateLanguages(jobId: job.id)

        async let educations = educationRepository
            .fetchEmployerCandidateEducations(jobId: job.id)

        async let workExperiences = workExperienceRepository
            .fetchEmployerCandidateWorkExperiences(jobId: job.id)

        async let skillRequirements = jobRepository
            .fetchSkillRequirements(jobId: job.id)

        async let languageRequirements = jobRepository
            .fetchLanguageRequirements(jobId: job.id)

        async let educationRequirements = jobRepository
            .fetchEducationRequirements(jobId: job.id)

        return try await EmployerMatchingData(
            candidates: candidates,
            candidateSkills: skills,
            candidateLanguages: languages,
            candidateEducations: educations,
            workExperiences: workExperiences,
            skillRequirements: skillRequirements,
            languageRequirements: languageRequirements,
            educationRequirements: educationRequirements
        )
    }
}

struct EmployerMatchingData: Sendable {
    let candidates: [EmployerCandidateMatchingInput]
    let candidateSkills: [CandidateSkill]
    let candidateLanguages: [CandidateLanguage]
    let candidateEducations: [Education]
    let workExperiences: [WorkExperience]

    let skillRequirements: [JobSkillRequirement]
    let languageRequirements: [JobLanguageRequirement]
    let educationRequirements: [JobEducationRequirement]
}
