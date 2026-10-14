//
//  CandidateProfileRepository.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import Foundation
import Supabase

final class CandidateProfileRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }
    
    func resetForPoC(
        userId: UUID
    ) async throws {
        struct Update: Encodable {
            let region: String?
            let regionLatitude: Double?
            let regionLongitude: Double?
            let nationality: String?
            let hasWorkAuthorization: Bool?
            let workAuthorizationDetails: String?

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

            let onboardingStep: Int
            let onboardingCompleted: Bool

            enum CodingKeys: String, CodingKey {
                case region
                case regionLatitude = "region_latitude"
                case regionLongitude = "region_longitude"
                case nationality
                case hasWorkAuthorization = "has_work_authorization"
                case workAuthorizationDetails = "work_authorization_details"

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

                case onboardingStep = "onboarding_step"
                case onboardingCompleted = "onboarding_completed"
            }
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)

                try container.encode(region, forKey: .region)
                try container.encode(regionLatitude, forKey: .regionLatitude)
                try container.encode(regionLongitude, forKey: .regionLongitude)
                try container.encode(nationality, forKey: .nationality)
                try container.encode(hasWorkAuthorization, forKey: .hasWorkAuthorization)
                try container.encode(workAuthorizationDetails, forKey: .workAuthorizationDetails)

                try container.encode(desiredWorkloadMin, forKey: .desiredWorkloadMin)
                try container.encode(desiredWorkloadMax, forKey: .desiredWorkloadMax)
                try container.encode(desiredWorkLocation, forKey: .desiredWorkLocation)
                try container.encode(desiredWorkLatitude, forKey: .desiredWorkLatitude)
                try container.encode(desiredWorkLongitude, forKey: .desiredWorkLongitude)
                try container.encode(workRadiusKm, forKey: .workRadiusKm)
                try container.encode(willingToCommute, forKey: .willingToCommute)
                try container.encode(willingToRelocate, forKey: .willingToRelocate)
                try container.encode(earliestStartDate, forKey: .earliestStartDate)

                try container.encode(preferredWorkModel, forKey: .preferredWorkModel)
                try container.encode(homeofficePreference, forKey: .homeofficePreference)
                try container.encode(desiredHomeofficeDays, forKey: .desiredHomeofficeDays)
                try container.encode(
                    preferredHomeofficeSchedule,
                    forKey: .preferredHomeofficeSchedule
                )
                try container.encode(acceptsFullyRemote, forKey: .acceptsFullyRemote)
                try container.encode(salaryMin, forKey: .salaryMin)
                try container.encode(salaryMax, forKey: .salaryMax)

                try container.encode(onboardingStep, forKey: .onboardingStep)
                try container.encode(onboardingCompleted, forKey: .onboardingCompleted)
            }
        }

        let update = Update(
            region: nil,
            regionLatitude: nil,
            regionLongitude: nil,
            nationality: nil,
            hasWorkAuthorization: nil,
            workAuthorizationDetails: nil,
            desiredWorkloadMin: nil,
            desiredWorkloadMax: nil,
            desiredWorkLocation: nil,
            desiredWorkLatitude: nil,
            desiredWorkLongitude: nil,
            workRadiusKm: nil,
            willingToCommute: nil,
            willingToRelocate: nil,
            earliestStartDate: nil,
            preferredWorkModel: nil,
            homeofficePreference: nil,
            desiredHomeofficeDays: nil,
            preferredHomeofficeSchedule: nil,
            acceptsFullyRemote: nil,
            salaryMin: nil,
            salaryMax: nil,
            onboardingStep: 0,
            onboardingCompleted: false
        )

        try await client
            .from("candidate_profiles")
            .update(update)
            .eq("user_id", value: userId)
            .execute()
    }

    func fetchProfile(userId: UUID) async throws -> CandidateProfile {
        try await client
            .from("candidate_profiles")
            .select("""
                user_id,
                region,
                region_latitude,
                region_longitude,
                nationality,
                has_work_authorization,
                work_authorization_details,
                desired_workload_min,
                desired_workload_max,
                desired_work_location,
                desired_work_latitude,
                desired_work_longitude,
                work_radius_km,
                willing_to_commute,
                willing_to_relocate,
                earliest_start_date,
                onboarding_step,
                onboarding_completed,
                preferred_work_model,
                homeoffice_preference,
                desired_homeoffice_days,    
                preferred_homeoffice_schedule,
                accepts_fully_remote,
                salary_min,
                salary_max
            """)
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value
    }
    
    
    
    func updateBasicInformation(
        userId: UUID,
        region: String,
        regionLatitude: Double,
        regionLongitude: Double,
        nationality: String,
        hasWorkAuthorization: Bool,
        workAuthorizationDetails: String?
    ) async throws {
        struct Update: Encodable {
            let region: String
            let regionLatitude: Double
            let regionLongitude: Double
            let nationality: String
            let hasWorkAuthorization: Bool
            let workAuthorizationDetails: String?
            let onboardingStep: Int

            enum CodingKeys: String, CodingKey {
                case region
                case regionLatitude = "region_latitude"
                case regionLongitude = "region_longitude"
                case nationality
                case hasWorkAuthorization = "has_work_authorization"
                case workAuthorizationDetails = "work_authorization_details"
                case onboardingStep = "onboarding_step"
            }
        }

        let update = Update(
            region: region,
            regionLatitude: regionLatitude,
            regionLongitude: regionLongitude,
            nationality: nationality,
            hasWorkAuthorization: hasWorkAuthorization,
            workAuthorizationDetails: workAuthorizationDetails,
            onboardingStep: 1
        )

        try await client
            .from("candidate_profiles")
            .update(update)
            .eq("user_id", value: userId)
            .execute()
    }
    
    func updateOnboardingStep(
        userId: UUID,
        step: Int
    ) async throws {
        struct Update: Encodable {
            let onboardingStep: Int

            enum CodingKeys: String, CodingKey {
                case onboardingStep = "onboarding_step"
            }
        }

        try await client
            .from("candidate_profiles")
            .update(
                Update(onboardingStep: step)
            )
            .eq("user_id", value: userId)
            .execute()
    }
    
    
    func updateJobPreferences(
        userId: UUID,
        desiredWorkloadMin: Int,
        desiredWorkloadMax: Int,
        desiredWorkLocation: String,
        desiredWorkLatitude: Double?,
        desiredWorkLongitude: Double?,
        workRadiusKm: Int,
        willingToCommute: Bool,
        willingToRelocate: Bool,
        earliestStartDate: Date
    ) async throws {
        struct Update: Encodable {
            let desiredWorkloadMin: Int
            let desiredWorkloadMax: Int
            let desiredWorkLocation: String
            let desiredWorkLatitude: Double?
            let desiredWorkLongitude: Double?
            let workRadiusKm: Int
            let willingToCommute: Bool
            let willingToRelocate: Bool
            let earliestStartDate: String
            let onboardingStep: Int

            enum CodingKeys: String, CodingKey {
                case desiredWorkloadMin = "desired_workload_min"
                case desiredWorkloadMax = "desired_workload_max"
                case desiredWorkLocation = "desired_work_location"
                case desiredWorkLatitude = "desired_work_latitude"
                case desiredWorkLongitude = "desired_work_longitude"
                case workRadiusKm = "work_radius_km"
                case willingToCommute = "willing_to_commute"
                case willingToRelocate = "willing_to_relocate"
                case earliestStartDate = "earliest_start_date"
                case onboardingStep = "onboarding_step"
            }
        }

        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"

        let update = Update(
            desiredWorkloadMin: desiredWorkloadMin,
            desiredWorkloadMax: desiredWorkloadMax,
            desiredWorkLocation: desiredWorkLocation,
            desiredWorkLatitude: desiredWorkLatitude,
            desiredWorkLongitude: desiredWorkLongitude,
            workRadiusKm: workRadiusKm,
            willingToCommute: willingToCommute,
            willingToRelocate: willingToRelocate,
            earliestStartDate: formatter.string(from: earliestStartDate),
            onboardingStep: 6
        )

        try await client
            .from("candidate_profiles")
            .update(update)
            .eq("user_id", value: userId)
            .execute()
    }
    
    
    func updateWorkAndSalaryPreferences(
        userId: UUID,
        preferredWorkModel: PreferredWorkModel,
        homeofficePreference: HomeofficePreference,
        desiredHomeofficeDays: Int,
        preferredHomeofficeSchedule: HomeofficeSchedulePreference,
        acceptsFullyRemote: Bool,
        salaryMin: Int,
        salaryMax: Int
    ) async throws {
        struct Update: Encodable {
            let preferredWorkModel: PreferredWorkModel
            let homeofficePreference: HomeofficePreference
            let desiredHomeofficeDays: Int
            let preferredHomeofficeSchedule: HomeofficeSchedulePreference
            let acceptsFullyRemote: Bool
            let salaryMin: Int
            let salaryMax: Int
            let onboardingStep: Int

            enum CodingKeys: String, CodingKey {
                case preferredWorkModel = "preferred_work_model"
                case homeofficePreference = "homeoffice_preference"
                case desiredHomeofficeDays = "desired_homeoffice_days"
                case preferredHomeofficeSchedule = "preferred_homeoffice_schedule"
                case acceptsFullyRemote = "accepts_fully_remote"
                case salaryMin = "salary_min"
                case salaryMax = "salary_max"
                case onboardingStep = "onboarding_step"
            }
        }

        let update = Update(
            preferredWorkModel: preferredWorkModel,
            homeofficePreference: homeofficePreference,
            desiredHomeofficeDays: desiredHomeofficeDays,
            preferredHomeofficeSchedule: preferredHomeofficeSchedule,
            acceptsFullyRemote: acceptsFullyRemote,
            salaryMin: salaryMin,
            salaryMax: salaryMax,
            onboardingStep: 7
        )

        try await client
            .from("candidate_profiles")
            .update(update)
            .eq("user_id", value: userId)
            .execute()
    }
    
    
    func fetchEmployerMatchingCandidates(
        jobId: UUID
    ) async throws -> [EmployerCandidateMatchingInput] {
        struct Params: Encodable {
            let pJobId: UUID

            enum CodingKeys: String, CodingKey {
                case pJobId = "p_job_id"
            }
        }

        return try await client
            .rpc(
                "get_employer_matching_candidates",
                params: Params(pJobId: jobId)
            )
            .execute()
            .value
    }
    
    
    func completeOnboarding(
        userId: UUID
    ) async throws {
        struct Update: Encodable {
            let onboardingStep: Int
            let onboardingCompleted: Bool

            enum CodingKeys: String, CodingKey {
                case onboardingStep = "onboarding_step"
                case onboardingCompleted = "onboarding_completed"
            }
        }

        let update = Update(
            onboardingStep: 8,
            onboardingCompleted: true
        )

        try await client
            .from("candidate_profiles")
            .update(update)
            .eq("user_id", value: userId)
            .execute()
    }
}



