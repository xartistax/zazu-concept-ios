//
//  EmployerCandidateMatchingInput.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 08.10.2026.
//

import Foundation

struct EmployerCandidateMatchingInput: Identifiable, Decodable, Sendable {
    let userId: UUID

    let hasWorkAuthorization: Bool?

    let desiredWorkloadMin: Int?
    let desiredWorkloadMax: Int?

    let desiredWorkLatitude: Double?
    let desiredWorkLongitude: Double?
    let workRadiusKm: Int?
    let willingToCommute: Bool?
    let willingToRelocate: Bool?

    let preferredWorkModel: PreferredWorkModel?
    let homeofficePreference: HomeofficePreference?
    let desiredHomeofficeDays: Int?
    let preferredHomeofficeSchedule: HomeofficeSchedulePreference?
    let acceptsFullyRemote: Bool?

    let salaryMin: Int?
    let salaryMax: Int?

    var id: UUID {
        userId
    }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case hasWorkAuthorization = "has_work_authorization"
        case desiredWorkloadMin = "desired_workload_min"
        case desiredWorkloadMax = "desired_workload_max"
        case desiredWorkLatitude = "desired_work_latitude"
        case desiredWorkLongitude = "desired_work_longitude"
        case workRadiusKm = "work_radius_km"
        case willingToCommute = "willing_to_commute"
        case willingToRelocate = "willing_to_relocate"
        case preferredWorkModel = "preferred_work_model"
        case homeofficePreference = "homeoffice_preference"
        case desiredHomeofficeDays = "desired_homeoffice_days"
        case preferredHomeofficeSchedule = "preferred_homeoffice_schedule"
        case acceptsFullyRemote = "accepts_fully_remote"
        case salaryMin = "salary_min"
        case salaryMax = "salary_max"
    }
}


extension EmployerCandidateMatchingInput {
    var candidateProfile: CandidateProfile {
        CandidateProfile(
            userId: userId,
            region: nil,
            regionLatitude: nil,
            regionLongitude: nil,
            nationality: nil,
            
            hasWorkAuthorization: hasWorkAuthorization,
            workAuthorizationDetails: nil,
            onboardingStep: 8,
            onboardingCompleted: true,
            desiredWorkloadMin: desiredWorkloadMin,
            desiredWorkloadMax: desiredWorkloadMax,
            desiredWorkLocation: nil,
            desiredWorkLatitude: desiredWorkLatitude,
            desiredWorkLongitude: desiredWorkLongitude,
            workRadiusKm: workRadiusKm,
            willingToCommute: willingToCommute,
            willingToRelocate: willingToRelocate,
            earliestStartDate: nil,
            preferredWorkModel: preferredWorkModel,
            homeofficePreference: homeofficePreference,
            desiredHomeofficeDays: desiredHomeofficeDays,
            preferredHomeofficeSchedule: preferredHomeofficeSchedule,
            acceptsFullyRemote: acceptsFullyRemote,
            salaryMin: salaryMin,
            salaryMax: salaryMax
        )
    }
}
