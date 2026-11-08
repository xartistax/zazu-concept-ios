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
    
    func fetchSkillCategories() async throws -> [SkillCategory] {
        try await client
            .from("skill_categories")
            .select("id, name, sort_order")
            .order("sort_order", ascending: true)
            .order("name", ascending: true)
            .execute()
            .value
    }

    func fetchSkills() async throws -> [Skill] {
        var allSkills: [Skill] = []
        let pageSize = 1_000
        var offset = 0

        while true {
            let page: [Skill] = try await client
                .from("skills")
                .select("id, name, category, category_id")
                .order("id", ascending: true)
                .range(
                    from: offset,
                    to: offset + pageSize - 1
                )
                .execute()
                .value

            allSkills.append(contentsOf: page)

            if page.count < pageSize {
                break
            }

            offset += pageSize
        }

        return allSkills
    }


    func searchSkills(
        query: String,
        category: String? = nil,
        categoryIds: [UUID] = [],
        offset: Int = 0,
        pageSize: Int = 30
    ) async throws -> [Skill] {
        let trimmedQuery = query.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        var request = client
            .from("skills")
            .select("id, name, category, category_id")

        if !trimmedQuery.isEmpty {
            let escapedQuery = trimmedQuery
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "%", with: "\\%")
                .replacingOccurrences(of: "_", with: "\\_")

            let pattern = "%\(escapedQuery)%"
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\"", with: "\\\"")

            request = request.or(
                "name.ilike.\"\(pattern)\",search_alias.ilike.\"\(pattern)\""
            )
        }

        if let category {
            request = request.eq(
                "category",
                value: category
            )
        }

        if !categoryIds.isEmpty {
            request = request.in(
                "category_id",
                values: categoryIds
            )
        }

        return try await request
            .order("name", ascending: true)
            .order("id", ascending: true)
            .range(
                from: offset,
                to: offset + pageSize - 1
            )
            .execute()
            .value
    }

    func fetchSkillsByIds(
        _ ids: [UUID]
    ) async throws -> [Skill] {

        guard !ids.isEmpty else {
            return []
        }

        return try await client
            .from("skills")
            .select("id, name, category, category_id")
            .in("id", values: ids)
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
    
    
    // MARK: - Candidate Skill Categories

    func fetchCandidateSkillCategoryIDs(
        candidateId: UUID
    ) async throws -> Set<UUID> {
        struct CategorySelection: Decodable {
            let categoryId: UUID

            enum CodingKeys: String, CodingKey {
                case categoryId = "category_id"
            }
        }

        let selections: [CategorySelection] = try await client
            .from("candidate_skill_categories")
            .select("category_id")
            .eq("candidate_id", value: candidateId)
            .execute()
            .value

        return Set(selections.map(\.categoryId))
    }

    func saveCandidateSkillCategories(
        categoryIDs: Set<UUID>
    ) async throws {
        struct Parameters: Encodable {
            let categoryIDs: [UUID]

            enum CodingKeys: String, CodingKey {
                case categoryIDs = "p_category_ids"
            }
        }

        try await client
            .rpc(
                "save_candidate_skill_categories",
                params: Parameters(
                    categoryIDs: categoryIDs.sorted {
                        $0.uuidString < $1.uuidString
                    }
                )
            )
            .execute()
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
