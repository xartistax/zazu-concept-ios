//
//  SkillRepository.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import Foundation
import Supabase

final class SkillRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }
    
    
    
    
    
    func deleteAllCandidateSkills(
        candidateId: UUID
    ) async throws {
        try await client
            .from("candidate_skills")
            .delete()
            .eq("candidate_id", value: candidateId)
            .execute()
    }

    
    // MARK: - Candidate Custom Skills

    func fetchCandidateCustomSkills(
        candidateId: UUID
    ) async throws -> [CandidateCustomSkill] {
        try await client
            .from("candidate_custom_skills")
            .select(
                """
                id,
                candidate_id,
                name,
                proficiency
                """
            )
            .eq("candidate_id", value: candidateId)
            .order("name", ascending: true)
            .execute()
            .value
    }

    func saveCandidateCustomSkill(
        candidateId: UUID,
        name: String,
        proficiency: SkillProficiency
    ) async throws {
        let payload = CandidateCustomSkillPayload(
            candidateId: candidateId,
            name: name.trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
            proficiency: proficiency
        )

        try await client
            .from("candidate_custom_skills")
            .upsert(
                payload,
                onConflict: "candidate_id,name"
            )
            .execute()
    }

    func deleteCandidateCustomSkill(
        id: UUID
    ) async throws {
        try await client
            .from("candidate_custom_skills")
            .delete()
            .eq("id", value: id)
            .execute()
    }

    func deleteAllCandidateCustomSkills(
        candidateId: UUID
    ) async throws {
        try await client
            .from("candidate_custom_skills")
            .delete()
            .eq("candidate_id", value: candidateId)
            .execute()
    }
    
    
    // MARK: - Taxonomy

    func fetchSkills() async throws -> [Skill] {
        try await client
            .from("skills")
            .select("id, name, category")
            .order("category", ascending: true)
            .order("name", ascending: true)
            .execute()
            .value
    }

    // MARK: - Candidate Skills

    func fetchCandidateSkills(
        candidateId: UUID
    ) async throws -> [CandidateSkill] {
        try await client
            .from("candidate_skills")
            .select("candidate_id, skill_id, proficiency")
            .eq("candidate_id", value: candidateId)
            .execute()
            .value
    }

    func saveCandidateSkill(
        candidateId: UUID,
        skillId: UUID,
        proficiency: SkillProficiency
    ) async throws {
        let payload = CandidateSkillPayload(
            candidateId: candidateId,
            skillId: skillId,
            proficiency: proficiency
        )

        try await client
            .from("candidate_skills")
            .upsert(
                payload,
                onConflict: "candidate_id,skill_id"
            )
            .execute()
    }

    func deleteCandidateSkill(
        candidateId: UUID,
        skillId: UUID
    ) async throws {
        try await client
            .from("candidate_skills")
            .delete()
            .eq("candidate_id", value: candidateId)
            .eq("skill_id", value: skillId)
            .execute()
    }
    
    
    func fetchEmployerCandidateSkills(
        jobId: UUID
    ) async throws -> [CandidateSkill] {
        struct Params: Encodable {
            let pJobId: UUID

            enum CodingKeys: String, CodingKey {
                case pJobId = "p_job_id"
            }
        }

        return try await client
            .rpc(
                "get_employer_candidate_skills",
                params: Params(pJobId: jobId)
            )
            .execute()
            .value
    }
    
    
    
}

private struct CandidateSkillPayload: Encodable {
    let candidateId: UUID
    let skillId: UUID
    let proficiency: SkillProficiency

    enum CodingKeys: String, CodingKey {
        case candidateId = "candidate_id"
        case skillId = "skill_id"
        case proficiency
    }
    
    
    
}

private struct CandidateCustomSkillPayload: Encodable {
    let candidateId: UUID
    let name: String
    let proficiency: SkillProficiency

    enum CodingKeys: String, CodingKey {
        case candidateId = "candidate_id"
        case name
        case proficiency
    }
}
