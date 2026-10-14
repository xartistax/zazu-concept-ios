//
//  WorkExperienceRepository.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import Foundation
import Supabase

final class WorkExperienceRepository {
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
    
    func deleteAll(
        candidateId: UUID
    ) async throws {
        try await client
            .from("work_experiences")
            .delete()
            .eq("candidate_id", value: candidateId)
            .execute()
    }
    
    func fetchEmployerCandidateWorkExperiences(
        jobId: UUID
    ) async throws -> [WorkExperience] {
        struct Params: Encodable {
            let pJobId: UUID

            enum CodingKeys: String, CodingKey {
                case pJobId = "p_job_id"
            }
        }

        return try await client
            .rpc(
                "get_employer_candidate_work_experiences",
                params: Params(pJobId: jobId)
            )
            .execute()
            .value
    }

    func fetchAll(candidateId: UUID) async throws -> [WorkExperience] {
        try await client
            .from("work_experiences")
            .select()
            .eq("candidate_id", value: candidateId)
            .order("start_date", ascending: false)
            .execute()
            .value
    }

    func create(
        candidateId: UUID,
        jobTitle: String,
        employerName: String,
        location: String?,
        startDate: Date,
        endDate: Date?,
        isCurrent: Bool,
        description: String?
    ) async throws {
        let payload = WorkExperienceInsert(
            candidateId: candidateId,
            jobTitle: jobTitle,
            employerName: employerName,
            location: location,
            startDate: Self.dateOnlyFormatter.string(from: startDate),
            endDate: isCurrent
                ? nil
                : endDate.map { Self.dateOnlyFormatter.string(from: $0) },
            isCurrent: isCurrent,
            description: description
        )
        

        try await client
            .from("work_experiences")
            .insert(payload)
            .execute()
    }

    func delete(id: UUID) async throws {
        try await client
            .from("work_experiences")
            .delete()
            .eq("id", value: id)
            .execute()
    }
}

private struct WorkExperienceInsert: Encodable {
    let candidateId: UUID
    let jobTitle: String
    let employerName: String
    let location: String?
    let startDate: String
    let endDate: String?
    let isCurrent: Bool
    let description: String?

    enum CodingKeys: String, CodingKey {
        case candidateId = "candidate_id"
        case jobTitle = "job_title"
        case employerName = "employer_name"
        case location
        case startDate = "start_date"
        case endDate = "end_date"
        case isCurrent = "is_current"
        case description
    }
}
