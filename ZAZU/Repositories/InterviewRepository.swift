//
//  InterviewRepository.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 03.10.2026.
//

import Foundation
import Supabase

final class InterviewRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    // MARK: - Interview Slots

    func fetchSlots(
        matchId: UUID
    ) async throws -> [InterviewSlot] {
        try await client
            .from("interview_slots")
            .select("""
                id,
                match_id,
                starts_at,
                ends_at
            """)
            .eq("match_id", value: matchId)
            .order("starts_at", ascending: true)
            .execute()
            .value
    }
    
    
    func fetchEmployerSlots(
        matchId: UUID
    ) async throws -> [InterviewSlot] {
        struct Parameters: Encodable {
            let matchId: UUID

            enum CodingKeys: String, CodingKey {
                case matchId = "p_match_id"
            }
        }

        return try await client
            .rpc(
                "get_employer_interview_slots",
                params: Parameters(
                    matchId: matchId
                )
            )
            .execute()
            .value
    }
    
    
    func fetchEmployerInterview(
        matchId: UUID
    ) async throws -> Interview? {
        struct Parameters: Encodable {
            let matchId: UUID

            enum CodingKeys: String, CodingKey {
                case matchId = "p_match_id"
            }
        }

        let interviews: [Interview] = try await client
            .rpc(
                "get_employer_interview",
                params: Parameters(
                    matchId: matchId
                )
            )
            .execute()
            .value

        return interviews.first
    }
    
    // MARK: - Employer Create Slot

    func createEmployerSlot(
        matchId: UUID,
        startsAt: Date,
        endsAt: Date
    ) async throws -> UUID {
        struct Parameters: Encodable {
            let matchId: UUID
            let startsAt: Date
            let endsAt: Date

            enum CodingKeys: String, CodingKey {
                case matchId = "p_match_id"
                case startsAt = "p_starts_at"
                case endsAt = "p_ends_at"
            }
        }

        let slotId: UUID = try await client
            .rpc(
                "create_employer_interview_slot",
                params: Parameters(
                    matchId: matchId,
                    startsAt: startsAt,
                    endsAt: endsAt
                )
            )
            .execute()
            .value

        return slotId
    }

    // MARK: - Confirmed Interview

    func fetchInterview(
        matchId: UUID
    ) async throws -> Interview? {
        let interviews: [Interview] = try await client
            .from("interviews")
            .select("""
                id,
                match_id,
                interview_slot_id,
                confirmed_at
            """)
            .eq("match_id", value: matchId)
            .limit(1)
            .execute()
            .value

        return interviews.first
    }

    // MARK: - Select Slot

    func selectSlot(
        matchId: UUID,
        slotId: UUID
    ) async throws -> UUID {
        struct Parameters: Encodable {
            let matchId: UUID
            let slotId: UUID

            enum CodingKeys: String, CodingKey {
                case matchId = "p_match_id"
                case slotId = "p_interview_slot_id"
            }
        }

        let interviewId: UUID = try await client
            .rpc(
                "select_interview_slot",
                params: Parameters(
                    matchId: matchId,
                    slotId: slotId
                )
            )
            .execute()
            .value

        return interviewId
    }
    
    
    func fetchConfirmedCandidateContact(
        matchId: UUID
    ) async throws -> CandidateContact? {
        struct Parameters: Encodable {
            let matchId: UUID

            enum CodingKeys: String, CodingKey {
                case matchId = "p_match_id"
            }
        }

        let contacts: [CandidateContact] = try await client
            .rpc(
                "get_confirmed_candidate_contact",
                params: Parameters(
                    matchId: matchId
                )
            )
            .execute()
            .value

        return contacts.first
    }
}
