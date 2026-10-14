//
//  LanguageRepository.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import Foundation
import Supabase

final class LanguageRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    // MARK: - Language Taxonomy

    func fetchLanguages() async throws -> [Language] {
        try await client
            .from("languages")
            .select("id, name, sort_order")
            .order("sort_order", ascending: true)
            .order("name", ascending: true)
            .execute()
            .value
    }
    
    func deleteAllCandidateLanguages(
        candidateId: UUID
    ) async throws {
        try await client
            .from("candidate_languages")
            .delete()
            .eq("candidate_id", value: candidateId)
            .execute()
    }

    // MARK: - Candidate Languages

    func fetchCandidateLanguages(
        candidateId: UUID
    ) async throws -> [CandidateLanguage] {
        try await client
            .from("candidate_languages")
            .select("candidate_id, language_id, proficiency")
            .eq("candidate_id", value: candidateId)
            .execute()
            .value
    }
    
    func fetchEmployerCandidateLanguages(
        jobId: UUID
    ) async throws -> [CandidateLanguage] {
        struct Params: Encodable {
            let pJobId: UUID

            enum CodingKeys: String, CodingKey {
                case pJobId = "p_job_id"
            }
        }

        return try await client
            .rpc(
                "get_employer_candidate_languages",
                params: Params(pJobId: jobId)
            )
            .execute()
            .value
    }

    func saveCandidateLanguage(
        candidateId: UUID,
        languageId: UUID,
        proficiency: LanguageProficiency
    ) async throws {
        let payload = CandidateLanguagePayload(
            candidateId: candidateId,
            languageId: languageId,
            proficiency: proficiency
        )

        try await client
            .from("candidate_languages")
            .upsert(
                payload,
                onConflict: "candidate_id,language_id"
            )
            .execute()
    }

    func deleteCandidateLanguage(
        candidateId: UUID,
        languageId: UUID
    ) async throws {
        try await client
            .from("candidate_languages")
            .delete()
            .eq("candidate_id", value: candidateId)
            .eq("language_id", value: languageId)
            .execute()
    }
}

// MARK: - Database Payload

private struct CandidateLanguagePayload: Encodable {
    let candidateId: UUID
    let languageId: UUID
    let proficiency: LanguageProficiency

    enum CodingKeys: String, CodingKey {
        case candidateId = "candidate_id"
        case languageId = "language_id"
        case proficiency
    }
}
