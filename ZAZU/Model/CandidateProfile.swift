//
//  CandidateProfile.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import Foundation

struct CandidateProfile: Decodable, Sendable {
    let userId: UUID
    let region: String?
    let regionLatitude: Double?
    let regionLongitude: Double?
    let nationality: String?
    let hasWorkAuthorization: Bool?
    let workAuthorizationDetails: String?
    let onboardingStep: Int
    let onboardingCompleted: Bool
    let desiredWorkloadMin: Int?
    let desiredWorkloadMax: Int?
    let desiredWorkLocation: String?
    let desiredWorkLatitude: Double?
    let desiredWorkLongitude: Double?
    let workRadiusKm: Int?
    let willingToCommute: Bool?
    let willingToRelocate: Bool?
    let earliestStartDate: String?
    
    let preferredWorkModel: PreferredWorkModel?
    let homeofficePreference: HomeofficePreference?
    let desiredHomeofficeDays: Int?
    let preferredHomeofficeSchedule: HomeofficeSchedulePreference?
    let acceptsFullyRemote: Bool?

    let salaryMin: Int?
    let salaryMax: Int?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case region
        case regionLatitude = "region_latitude"
        case regionLongitude = "region_longitude"
        case nationality
        case hasWorkAuthorization = "has_work_authorization"
        case workAuthorizationDetails = "work_authorization_details"
        case onboardingStep = "onboarding_step"
        case onboardingCompleted = "onboarding_completed"
        case desiredWorkloadMin = "desired_workload_min"
        case desiredWorkloadMax = "desired_workload_max"
        case desiredWorkLocation = "desired_work_location"
        case desiredWorkLatitude = "desired_work_latitude"
        case desiredWorkLongitude = "desired_work_longitude"
        case workRadiusKm = "work_radius_km"
        case willingToCommute = "willing_to_commute"
        case willingToRelocate = "willing_to_relocate"
        case earliestStartDate = "earliest_start_date"
        case preferredWorkModel = "preferred_work_model"
        case homeofficePreference = "homeoffice_preference"
        case desiredHomeofficeDays = "desired_homeoffice_days"
        case preferredHomeofficeSchedule = "preferred_homeoffice_schedule"
        case acceptsFullyRemote = "accepts_fully_remote"

        case salaryMin = "salary_min"
        case salaryMax = "salary_max"
    }
}
