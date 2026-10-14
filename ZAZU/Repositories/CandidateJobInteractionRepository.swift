//
//  CandidateJobInteractionRepository.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 30.09.2026.
//

import Foundation
import Supabase

final class CandidateJobInteractionRepository: Sendable {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func fetchInteractions(
        candidateId: UUID
    ) async throws -> [CandidateJobInteraction] {
        try await client
            .from("candidate_job_interactions")
            .select()
            .eq("candidate_id", value: candidateId.uuidString)
            .execute()
            .value
    }

    func saveDecision(
        candidateId: UUID,
        jobId: UUID,
        decision: CandidateJobDecision
    ) async throws {
        let payload = CandidateJobInteractionPayload(
            candidateId: candidateId,
            jobId: jobId,
            decision: decision
        )

        try await client
            .from("candidate_job_interactions")
            .upsert(
                payload,
                onConflict: "candidate_id,job_id"
            )
            .execute()
    }

    func deleteAllInteractions(
        candidateId: UUID
    ) async throws {
        try await client
            .from("candidate_job_interactions")
            .delete()
            .eq("candidate_id", value: candidateId.uuidString)
            .execute()
    }
}

private struct CandidateJobInteractionPayload: Encodable {
    let candidateId: UUID
    let jobId: UUID
    let decision: CandidateJobDecision

    enum CodingKeys: String, CodingKey {
        case candidateId = "candidate_id"
        case jobId = "job_id"
        case decision
    }
}
