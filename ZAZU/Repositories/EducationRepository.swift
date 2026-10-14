//
//  EducationRepository.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import Foundation
import Supabase

final class EducationRepository {
    private let client: SupabaseClient

    private static let dateOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    init(client: SupabaseClient) {
        self.client = client
    }
    
    
    func fetchEmployerCandidateEducations(
        jobId: UUID
    ) async throws -> [Education] {
        struct Params: Encodable {
            let pJobId: UUID

            enum CodingKeys: String, CodingKey {
                case pJobId = "p_job_id"
            }
        }

        return try await client
            .rpc(
                "get_employer_candidate_educations",
                params: Params(pJobId: jobId)
            )
            .execute()
            .value
    }
    
    func saveEducationRequirement(
        jobId: UUID,
        degree: String,
        fieldOfStudy: String?,
        requirementType: RequirementType
    ) async throws {
        struct Payload: Encodable {
            let jobId: UUID
            let degree: String
            let fieldOfStudy: String?
            let requirementType: RequirementType

            enum CodingKeys: String, CodingKey {
                case jobId = "job_id"
                case degree
                case fieldOfStudy = "field_of_study"
                case requirementType = "requirement_type"
            }
        }

        let payload = Payload(
            jobId: jobId,
            degree: degree.trimmingCharacters(in: .whitespacesAndNewlines),
            fieldOfStudy: fieldOfStudy?
                .trimmingCharacters(in: .whitespacesAndNewlines),
            requirementType: requirementType
        )

        try await client
            .from("job_education_requirements")
            .insert(payload)
            .execute()
    }
    
    func deleteAll(
        candidateId: UUID
    ) async throws {
        try await client
            .from("educations")
            .delete()
            .eq("candidate_id", value: candidateId)
            .execute()
    }

    func fetchAll(
        candidateId: UUID
    ) async throws -> [Education] {
        try await client
            .from("educations")
            .select()
            .eq("candidate_id", value: candidateId)
            .order("start_date", ascending: false)
            .execute()
            .value
    }

    func create(
        candidateId: UUID,
        institutionName: String,
        degree: String,
        fieldOfStudy: String?,
        startDate: Date?,
        endDate: Date?,
        isCurrent: Bool,
        description: String?
    ) async throws {
        let payload = EducationInsert(
            candidateId: candidateId,
            institutionName: institutionName,
            degree: degree,
            fieldOfStudy: fieldOfStudy,
            startDate: startDate.map {
                Self.dateOnlyFormatter.string(from: $0)
            },
            endDate: isCurrent
                ? nil
                : endDate.map {
                    Self.dateOnlyFormatter.string(from: $0)
                },
            isCurrent: isCurrent,
            description: description
        )

        try await client
            .from("educations")
            .insert(payload)
            .execute()
    }

    func delete(
        id: UUID
    ) async throws {
        try await client
            .from("educations")
            .delete()
            .eq("id", value: id)
            .execute()
    }
}

private struct EducationInsert: Encodable {
    let candidateId: UUID
    let institutionName: String
    let degree: String
    let fieldOfStudy: String?

    let startDate: String?
    let endDate: String?
    let isCurrent: Bool

    let description: String?

    enum CodingKeys: String, CodingKey {
        case candidateId = "candidate_id"
        case institutionName = "institution_name"
        case degree
        case fieldOfStudy = "field_of_study"
        case startDate = "start_date"
        case endDate = "end_date"
        case isCurrent = "is_current"
        case description
    }
}
