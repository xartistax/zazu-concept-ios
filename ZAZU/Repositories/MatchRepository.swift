//
//  MatchRepository.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 03.10.2026.
//

import Foundation
import Supabase

final class MatchRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }
    
    func deleteAllMatchesForPoC() async throws {
        try await client
            .rpc("delete_own_matches_for_poc")
            .execute()
    }
    


    func createMutualMatchIfEligible(
        jobId: UUID
    ) async throws -> UUID? {
        struct Parameters: Encodable {
            let jobId: UUID

            enum CodingKeys: String, CodingKey {
                case jobId = "p_job_id"
            }
        }

        let matchId: UUID? = try await client
            .rpc(
                "create_mutual_match_if_eligible",
                params: Parameters(jobId: jobId)
            )
            .execute()
            .value

        return matchId
    }

    func fetchMatches(
        candidateId: UUID
    ) async throws -> [Match] {
        try await client
            .from("matches")
            .select("""
                id,
                candidate_id,
                job_id,
                matched_at
            """)
            .eq("candidate_id", value: candidateId)
            .order("matched_at", ascending: false)
            .execute()
            .value
    }
    
    
    func fetchEmployerMatches() async throws -> [Match] {
        try await client
            .rpc("get_employer_matches")
            .execute()
            .value
    }
}
