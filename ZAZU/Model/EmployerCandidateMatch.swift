//
//  EmployerCandidateMatch.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 08.10.2026.
//

import Foundation


struct EmployerCandidateMatch: Identifiable, Hashable, Sendable {
    let candidate: EmployerCandidateMatchingInput
    let matchResult: MatchResult

    var id: UUID {
        candidate.userId
    }

    var candidateId: UUID {
        candidate.userId
    }

    static func == (
        lhs: EmployerCandidateMatch,
        rhs: EmployerCandidateMatch
    ) -> Bool {
        lhs.candidateId == rhs.candidateId
    }

    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(candidateId)
    }
}
