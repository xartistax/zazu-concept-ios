//
//  CandidateJobInteraction.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 30.09.2026.
//

import Foundation

enum CandidateJobDecision: String, Codable, Sendable {
    case match
    case pass
}

struct CandidateJobInteraction: Identifiable, Codable, Sendable {
    let id: UUID
    let candidateId: UUID
    let jobId: UUID
    let decision: CandidateJobDecision
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case candidateId = "candidate_id"
        case jobId = "job_id"
        case decision
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    
    

}
