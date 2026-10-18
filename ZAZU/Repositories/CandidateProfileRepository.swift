

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

    // MARK: - Reset

    /// Setzt das Onboarding des angemeldeten Testkontos vollständig zurück.
    /// Die PostgreSQL-Funktion verwendet auth.uid().
    /// Der Parameter userId bleibt für bestehende Aufrufstellen erhalten.
    func resetForPoC(
        userId: UUID
    ) async throws {
        try await client
            .rpc("reset_my_candidate_onboarding")
            .execute()
    }

    // MARK: - Education Status

    func fetchEducationStatus(
        userId: UUID
    ) async throws -> String? {

        struct Result: Decodable {
            let educationStatus: String?

            enum CodingKeys: String, CodingKey {
                case educationStatus = "education_status"
            }
        }

        let result: Result = try await client
            .from("candidate_profiles")
            .select("education_status")
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value

        return result.educationStatus
    }

    func updateEducationStatus(
        userId: UUID,
        status: String
    ) async throws {

        struct Update: Encodable {
            let educationStatus: String

            enum CodingKeys: String, CodingKey {
                case educationStatus = "education_status"
            }
        }

        try await client
            .from("candidate_profiles")
            .update(Update(educationStatus: status))
            .eq("user_id", value: userId)
            .execute()
    }

    // MARK: - Work Experience Status

    func updateWorkExperienceStatus(
        userId: UUID,
        status: String
    ) async throws {

        struct Update: Encodable {
            let workExperienceStatus: String

            enum CodingKeys: String, CodingKey {
                case workExperienceStatus = "work_experience_status"
            }
        }

        try await client
            .from("candidate_profiles")
            .update(Update(workExperienceStatus: status))
            .eq("user_id", value: userId)
            .execute()
    }

    func fetchWorkExperienceStatus(
        userId: UUID
    ) async throws -> String? {

        struct Result: Decodable {
            let workExperienceStatus: String?

            enum CodingKeys: String, CodingKey {
                case workExperienceStatus = "work_experience_status"
            }
        }

        let result: Result = try await client
            .from("candidate_profiles")
            .select("work_experience_status")
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value

        return result.workExperienceStatus
    }

    // MARK: - Profile

    func fetchProfile(
        userId: UUID
    ) async throws -> CandidateProfile {

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

    // MARK: - Basic Information

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

            enum CodingKeys: String, CodingKey {
                case region
                case regionLatitude = "region_latitude"
                case regionLongitude = "region_longitude"
                case nationality
                case hasWorkAuthorization = "has_work_authorization"
                case workAuthorizationDetails = "work_authorization_details"
            }
        }

        let update = Update(
            region: region,
            regionLatitude: regionLatitude,
            regionLongitude: regionLongitude,
            nationality: nationality,
            hasWorkAuthorization: hasWorkAuthorization,
            workAuthorizationDetails: workAuthorizationDetails
        )

        try await client
            .from("candidate_profiles")
            .update(update)
            .eq("user_id", value: userId)
            .execute()
    }

    // MARK: - Onboarding Progress

    func updateOnboardingStep(
        userId: UUID,
        step: Int
    ) async throws {

        guard (0...9).contains(step) else {
            throw OnboardingProgressError.invalidStep
        }

        struct Progress: Decodable {
            let onboardingStep: Int
            let onboardingCompleted: Bool

            enum CodingKeys: String, CodingKey {
                case onboardingStep = "onboarding_step"
                case onboardingCompleted = "onboarding_completed"
            }
        }

        struct Update: Encodable {
            let onboardingStep: Int

            enum CodingKeys: String, CodingKey {
                case onboardingStep = "onboarding_step"
            }
        }

        let progress: Progress = try await client
            .from("candidate_profiles")
            .select("onboarding_step, onboarding_completed")
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value

        guard !progress.onboardingCompleted else {
            return
        }

        let nextStep = max(
            progress.onboardingStep,
            step
        )

        guard nextStep > progress.onboardingStep else {
            return
        }

        try await client
            .from("candidate_profiles")
            .update(Update(onboardingStep: nextStep))
            .eq("user_id", value: userId)
            .eq("onboarding_completed", value: false)
            .lt("onboarding_step", value: nextStep)
            .execute()
    }

    // MARK: - Job Preferences

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
            earliestStartDate: formatter.string(
                from: earliestStartDate
            )
        )

        try await client
            .from("candidate_profiles")
            .update(update)
            .eq("user_id", value: userId)
            .execute()

        try await updateOnboardingStep(
            userId: userId,
            step: 6
        )
    }

    // MARK: - Work and Salary

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

            enum CodingKeys: String, CodingKey {
                case preferredWorkModel = "preferred_work_model"
                case homeofficePreference = "homeoffice_preference"
                case desiredHomeofficeDays = "desired_homeoffice_days"
                case preferredHomeofficeSchedule = "preferred_homeoffice_schedule"
                case acceptsFullyRemote = "accepts_fully_remote"
                case salaryMin = "salary_min"
                case salaryMax = "salary_max"
            }
        }

        let update = Update(
            preferredWorkModel: preferredWorkModel,
            homeofficePreference: homeofficePreference,
            desiredHomeofficeDays: desiredHomeofficeDays,
            preferredHomeofficeSchedule: preferredHomeofficeSchedule,
            acceptsFullyRemote: acceptsFullyRemote,
            salaryMin: salaryMin,
            salaryMax: salaryMax
        )

        try await client
            .from("candidate_profiles")
            .update(update)
            .eq("user_id", value: userId)
            .execute()

        try await updateOnboardingStep(
            userId: userId,
            step: 7
        )
    }

    // MARK: - Employer Matching

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

    // MARK: - Complete Onboarding

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
            onboardingStep: 9,
            onboardingCompleted: true
        )

        try await client
            .from("candidate_profiles")
            .update(update)
            .eq("user_id", value: userId)
            .eq("onboarding_completed", value: false)
            .execute()
    }

    // MARK: - Errors

    private enum OnboardingProgressError: LocalizedError {
        case invalidStep

        var errorDescription: String? {
            switch self {
            case .invalidStep:
                return "Ungültiger Onboarding-Schritt."
            }
        }
    }
}
