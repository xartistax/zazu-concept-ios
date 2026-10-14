//
//  MatchResult.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 29.09.2026.
//

import Foundation

struct MatchResult: Sendable {
    let jobId: UUID

    let mustCriteria: [MatchCriterion]
    let optionalCriteria: [MatchCriterion]

    let salaryCompatibility: MatchCriterion
    let workModelCompatibility: MatchCriterion
    
    let homeofficeCompatibility: MatchCriterion

    var fulfillsAllMustCriteria: Bool {
        mustCriteria.allSatisfy(\.isFulfilled)
    }

    var fulfilledMustCriteria: [MatchCriterion] {
        mustCriteria.filter(\.isFulfilled)
    }

    var missingMustCriteria: [MatchCriterion] {
        mustCriteria.filter { !$0.isFulfilled }
    }

    var fulfilledOptionalCriteria: [MatchCriterion] {
        optionalCriteria.filter(\.isFulfilled)
    }

    var missingOptionalCriteria: [MatchCriterion] {
        optionalCriteria.filter { !$0.isFulfilled }
    }
    
    var scoredCriteria: [MatchCriterion] {
        mustCriteria
            + optionalCriteria
            + [
                salaryCompatibility
            ]
    }

    var fulfilledScoredCriteria: [MatchCriterion] {
        scoredCriteria.filter(\.isFulfilled)
    }

    var score: Int {
        guard !scoredCriteria.isEmpty else {
            return 0
        }

        let ratio =
            Double(fulfilledScoredCriteria.count)
            / Double(scoredCriteria.count)

        return Int((ratio * 100).rounded())
    }
}

struct MatchCriterion: Identifiable, Sendable {
    let id: String
    let type: MatchCriterionType
    let title: String
    let detail: String
    let requirementDetail: String?
    let isFulfilled: Bool

    init(
        id: String,
        type: MatchCriterionType,
        title: String,
        detail: String,
        requirementDetail: String? = nil,
        isFulfilled: Bool
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.detail = detail
        self.requirementDetail = requirementDetail
        self.isFulfilled = isFulfilled
    }
}



enum MatchCriterionType: String, Sendable {
    case skill
    case language
    case education
    case workExperience
    case workAuthorization
    case workload
    case salary
    case workModel
    case homeoffice
    case location
}
