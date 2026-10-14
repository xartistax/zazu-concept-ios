//
//  JobRepository.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 29.09.2026.
//

import Foundation
import Supabase

final class JobRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }
    
    func createJob(
        companyId: UUID,
        title: String,
        description: String,
        activityArea: String?,
        location: String,
        latitude: Double?,
        longitude: Double?,
        workModel: PreferredWorkModel,
        workloadMin: Int,
        workloadMax: Int,
        earliestStartDate: String?,
        salaryMin: Int?,
        salaryMax: Int?,
        requiredWorkExperienceYears: Int?,
        workExperienceRequirementType: RequirementType,
        requiresWorkAuthorization: Bool,
        workAuthorizationRequirementType: RequirementType,
        homeofficeAvailable: Bool,
        homeofficeDays: Int?,
        homeofficeSchedule: JobHomeofficeSchedule?,
        fullyRemoteAvailable: Bool,
        homeofficeRequirementType: RequirementType,
        workModelRequirementType: RequirementType,
        responsibleContactId: UUID? = nil
    ) async throws -> Job {
        struct Insert: Encodable {
            let companyId: UUID
            let title: String
            let description: String
            let activityArea: String?
            let location: String
            let latitude: Double?
            let longitude: Double?
            let workModel: PreferredWorkModel
            let workloadMin: Int
            let workloadMax: Int
            let earliestStartDate: String?
            let salaryMin: Int?
            let salaryMax: Int?
            let requiredWorkExperienceYears: Int?
            let workExperienceRequirementType: RequirementType
            let requiresWorkAuthorization: Bool
            let workAuthorizationRequirementType: RequirementType
            let homeofficeAvailable: Bool
            let homeofficeDays: Int?
            let homeofficeSchedule: JobHomeofficeSchedule?
            let fullyRemoteAvailable: Bool
            let homeofficeRequirementType: RequirementType
            let workModelRequirementType: RequirementType
            let responsibleContactId: UUID?
            

            enum CodingKeys: String, CodingKey {
                case companyId = "company_id"
                case title
                case description
                case activityArea = "activity_area"
                case location
                case latitude
                case longitude
                case workModel = "work_model"
                case workloadMin = "workload_min"
                case workloadMax = "workload_max"
                case earliestStartDate = "earliest_start_date"
                case salaryMin = "salary_min"
                case salaryMax = "salary_max"
                case requiredWorkExperienceYears = "required_work_experience_years"
                case workExperienceRequirementType = "work_experience_requirement_type"
                case requiresWorkAuthorization = "requires_work_authorization"
                case workAuthorizationRequirementType = "work_authorization_requirement_type"
                case homeofficeAvailable = "homeoffice_available"
                case homeofficeDays = "homeoffice_days"
                case homeofficeSchedule = "homeoffice_schedule"
                case fullyRemoteAvailable = "fully_remote_available"
                case homeofficeRequirementType = "homeoffice_requirement_type"
                case workModelRequirementType = "work_model_requirement_type"
                case responsibleContactId = "responsible_contact_id"
            }
        }

        let insert = Insert(
            companyId: companyId,
            title: title,
            description: description,
            activityArea: activityArea,
            location: location,
            latitude: latitude,
            longitude: longitude,
            workModel: workModel,
            workloadMin: workloadMin,
            workloadMax: workloadMax,
            earliestStartDate: earliestStartDate,
            salaryMin: salaryMin,
            salaryMax: salaryMax,
            requiredWorkExperienceYears: requiredWorkExperienceYears,
            workExperienceRequirementType: workExperienceRequirementType,
            requiresWorkAuthorization: requiresWorkAuthorization,
            workAuthorizationRequirementType: workAuthorizationRequirementType,
            homeofficeAvailable: homeofficeAvailable,
            homeofficeDays: homeofficeDays,
            homeofficeSchedule: homeofficeSchedule,
            fullyRemoteAvailable: fullyRemoteAvailable,
            homeofficeRequirementType: homeofficeRequirementType,
            workModelRequirementType: workModelRequirementType,
            responsibleContactId: responsibleContactId
            
        )

        return try await client
            .from("jobs")
            .insert(insert)
            .select()
            .single()
            .execute()
            .value
    }

    func fetchJobs() async throws -> [Job] {
        try await client
            .from("jobs")
            .select()
            .eq("is_active", value: true)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    
    func fetchJobs(
        companyId: UUID
    ) async throws -> [Job] {
        try await client
            .from("jobs")
            .select()
            .eq("company_id", value: companyId)
            .order("created_at", ascending: false)
            .execute()
            .value
    }
    
    func fetchCompanies() async throws -> [Company] {
        try await client
            .from("companies")
            .select()
            .execute()
            .value
    }

    func fetchSkillRequirements() async throws -> [JobSkillRequirement] {
        try await client
            .from("job_skills")
            .select(
                """
                job_id,
                skill_id,
                minimum_proficiency,
                requirement_type
                """
            )
            .execute()
            .value
    }
    
    func saveSkillRequirement(
        jobId: UUID,
        skillId: UUID,
        minimumProficiency: SkillProficiency,
        requirementType: RequirementType
    ) async throws {
        struct Payload: Encodable {
            let jobId: UUID
            let skillId: UUID
            let minimumProficiency: SkillProficiency
            let requirementType: RequirementType

            enum CodingKeys: String, CodingKey {
                case jobId = "job_id"
                case skillId = "skill_id"
                case minimumProficiency = "minimum_proficiency"
                case requirementType = "requirement_type"
            }
        }

        let payload = Payload(
            jobId: jobId,
            skillId: skillId,
            minimumProficiency: minimumProficiency,
            requirementType: requirementType
        )

        try await client
            .from("job_skills")
            .insert(payload)
            .execute()
    }
    
    func deleteSkillRequirement(
        jobId: UUID,
        skillId: UUID
    ) async throws {
        try await client
            .from("job_skills")
            .delete()
            .eq("job_id", value: jobId)
            .eq("skill_id", value: skillId)
            .execute()
    }

    func fetchLanguageRequirements() async throws -> [JobLanguageRequirement] {
        try await client
            .from("job_languages")
            .select(
                """
                job_id,
                language_id,
                minimum_proficiency,
                requirement_type
                """
            )
            .execute()
            .value
    }
    
    
    func saveLanguageRequirement(
        jobId: UUID,
        languageId: UUID,
        minimumProficiency: LanguageProficiency,
        requirementType: RequirementType
    ) async throws {
        struct Payload: Encodable {
            let jobId: UUID
            let languageId: UUID
            let minimumProficiency: LanguageProficiency
            let requirementType: RequirementType

            enum CodingKeys: String, CodingKey {
                case jobId = "job_id"
                case languageId = "language_id"
                case minimumProficiency = "minimum_proficiency"
                case requirementType = "requirement_type"
            }
        }

        let payload = Payload(
            jobId: jobId,
            languageId: languageId,
            minimumProficiency: minimumProficiency,
            requirementType: requirementType
        )

        try await client
            .from("job_languages")
            .upsert(
                payload,
                onConflict: "job_id,language_id"
            )
            .execute()
    }
    
    func updateSkillRequirement(
        jobId: UUID,
        skillId: UUID,
        minimumProficiency: SkillProficiency,
        requirementType: RequirementType
    ) async throws {
        struct Payload: Encodable {
            let minimumProficiency: SkillProficiency
            let requirementType: RequirementType

            enum CodingKeys: String, CodingKey {
                case minimumProficiency = "minimum_proficiency"
                case requirementType = "requirement_type"
            }
        }

        let payload = Payload(
            minimumProficiency: minimumProficiency,
            requirementType: requirementType
        )

        try await client
            .from("job_skills")
            .update(payload)
            .eq("job_id", value: jobId)
            .eq("skill_id", value: skillId)
            .execute()
    }
    
    func updateEducationRequirement(
        id: UUID,
        degree: String,
        fieldOfStudy: String?,
        requirementType: RequirementType
    ) async throws {
        struct Payload: Encodable {
            let degree: String
            let fieldOfStudy: String?
            let requirementType: RequirementType

            enum CodingKeys: String, CodingKey {
                case degree
                case fieldOfStudy = "field_of_study"
                case requirementType = "requirement_type"
            }
        }

        let payload = Payload(
            degree: degree,
            fieldOfStudy: fieldOfStudy,
            requirementType: requirementType
        )

        try await client
            .from("job_education_requirements")
            .update(payload)
            .eq("id", value: id)
            .execute()
    }
    
    func fetchSkillRequirements(
        jobId: UUID
    ) async throws -> [JobSkillRequirement] {
        try await client
            .from("job_skills")
            .select(
                """
                job_id,
                skill_id,
                minimum_proficiency,
                requirement_type
                """
            )
            .eq("job_id", value: jobId)
            .execute()
            .value
    }
    
    func fetchEducationRequirements(
        jobId: UUID
    ) async throws -> [JobEducationRequirement] {
        try await client
            .from("job_education_requirements")
            .select(
                """
                id,
                job_id,
                degree,
                field_of_study,
                requirement_type
                """
            )
            .eq("job_id", value: jobId)
            .execute()
            .value
    }
    
    func fetchLanguageRequirements(
        jobId: UUID
    ) async throws -> [JobLanguageRequirement] {
        try await client
            .from("job_languages")
            .select(
                """
                job_id,
                language_id,
                minimum_proficiency,
                requirement_type
                """
            )
            .eq("job_id", value: jobId)
            .execute()
            .value
    }
    
    func updateJob(
        jobId: UUID,
        title: String,
        description: String,
        activityArea: String?,
        location: String,
        workModel: PreferredWorkModel,
        workloadMin: Int,
        workloadMax: Int,
        salaryMin: Int?,
        salaryMax: Int?,
        requiredWorkExperienceYears: Int?,
        workExperienceRequirementType: RequirementType,
        requiresWorkAuthorization: Bool,
        workAuthorizationRequirementType: RequirementType,
        homeofficeAvailable: Bool,
        homeofficeDays: Int?,
        homeofficeSchedule: JobHomeofficeSchedule?,
        fullyRemoteAvailable: Bool,
        homeofficeRequirementType: RequirementType,
        workModelRequirementType: RequirementType,
        responsibleContactId: UUID? = nil
    ) async throws {
        struct Payload: Encodable {
            let title: String
            let description: String
            let activityArea: String?
            let location: String
            let workModel: PreferredWorkModel
            let workloadMin: Int
            let workloadMax: Int
            let salaryMin: Int?
            let salaryMax: Int?
            let requiredWorkExperienceYears: Int?
            let workExperienceRequirementType: RequirementType
            let requiresWorkAuthorization: Bool
            let workAuthorizationRequirementType: RequirementType
            let homeofficeAvailable: Bool
            let homeofficeDays: Int?
            let homeofficeSchedule: JobHomeofficeSchedule?
            let fullyRemoteAvailable: Bool
            let homeofficeRequirementType: RequirementType
            let workModelRequirementType: RequirementType
            let responsibleContactId: UUID?

            enum CodingKeys: String, CodingKey {
                case title
                case description
                case activityArea = "activity_area"
                case location
                case workModel = "work_model"
                case workloadMin = "workload_min"
                case workloadMax = "workload_max"
                case salaryMin = "salary_min"
                case salaryMax = "salary_max"
                case requiredWorkExperienceYears =
                    "required_work_experience_years"
                case workExperienceRequirementType =
                    "work_experience_requirement_type"
                case requiresWorkAuthorization =
                    "requires_work_authorization"
                case workAuthorizationRequirementType =
                    "work_authorization_requirement_type"
                case homeofficeAvailable =
                    "homeoffice_available"
                case homeofficeDays =
                    "homeoffice_days"
                case homeofficeSchedule =
                    "homeoffice_schedule"
                case fullyRemoteAvailable =
                    "fully_remote_available"
                case homeofficeRequirementType =
                    "homeoffice_requirement_type"
                case workModelRequirementType =
                    "work_model_requirement_type"
                case responsibleContactId = "responsible_contact_id"
            }
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)

                try container.encode(title, forKey: .title)
                try container.encode(description, forKey: .description)
                try container.encodeIfPresent(activityArea, forKey: .activityArea)
                try container.encode(location, forKey: .location)
                try container.encode(workModel, forKey: .workModel)
                try container.encode(workloadMin, forKey: .workloadMin)
                try container.encode(workloadMax, forKey: .workloadMax)
                try container.encodeIfPresent(salaryMin, forKey: .salaryMin)
                try container.encodeIfPresent(salaryMax, forKey: .salaryMax)
                try container.encodeIfPresent(
                    requiredWorkExperienceYears,
                    forKey: .requiredWorkExperienceYears
                )
                try container.encode(
                    workExperienceRequirementType,
                    forKey: .workExperienceRequirementType
                )
                try container.encode(
                    requiresWorkAuthorization,
                    forKey: .requiresWorkAuthorization
                )
                try container.encode(
                    workAuthorizationRequirementType,
                    forKey: .workAuthorizationRequirementType
                )
                try container.encode(homeofficeAvailable, forKey: .homeofficeAvailable)
                try container.encodeIfPresent(homeofficeDays, forKey: .homeofficeDays)
                try container.encodeIfPresent(homeofficeSchedule, forKey: .homeofficeSchedule)
                try container.encode(
                    fullyRemoteAvailable,
                    forKey: .fullyRemoteAvailable
                )
                try container.encode(
                    homeofficeRequirementType,
                    forKey: .homeofficeRequirementType
                )
                try container.encode(
                    workModelRequirementType,
                    forKey: .workModelRequirementType
                )

                if let responsibleContactId {
                    try container.encode(
                        responsibleContactId,
                        forKey: .responsibleContactId
                    )
                } else {
                    try container.encodeNil(forKey: .responsibleContactId)
                }
            }
        }

        let payload = Payload(
            title: title,
            description: description,
            activityArea: activityArea,
            location: location,
            workModel: workModel,
            workloadMin: workloadMin,
            workloadMax: workloadMax,
            salaryMin: salaryMin,
            salaryMax: salaryMax,
            requiredWorkExperienceYears: requiredWorkExperienceYears,
            workExperienceRequirementType: workExperienceRequirementType,
            requiresWorkAuthorization: requiresWorkAuthorization,
            workAuthorizationRequirementType: workAuthorizationRequirementType,
            homeofficeAvailable: homeofficeAvailable,
            homeofficeDays: homeofficeDays,
            homeofficeSchedule: homeofficeSchedule,
            fullyRemoteAvailable: fullyRemoteAvailable,
            homeofficeRequirementType: homeofficeRequirementType,
            workModelRequirementType: workModelRequirementType,
            responsibleContactId: responsibleContactId
            
        )

        try await client
            .from("jobs")
            .update(payload)
            .eq("id", value: jobId)
            .execute()
    }
    
    func deleteEducationRequirement(
        id: UUID
    ) async throws {
        try await client
            .from("job_education_requirements")
            .delete()
            .eq("id", value: id)
            .execute()
    }
    
    func updateActiveStatus(
        jobId: UUID,
        isActive: Bool
    ) async throws {
        struct Payload: Encodable {
            let isActive: Bool

            enum CodingKeys: String, CodingKey {
                case isActive = "is_active"
            }
        }

        try await client
            .from("jobs")
            .update(Payload(isActive: isActive))
            .eq("id", value: jobId)
            .execute()
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
            degree: degree,
            fieldOfStudy: fieldOfStudy,
            requirementType: requirementType
        )

        try await client
            .from("job_education_requirements")
            .insert(payload)
            .execute()
    }

    func deleteLanguageRequirement(
        jobId: UUID,
        languageId: UUID
    ) async throws {
        try await client
            .from("job_languages")
            .delete()
            .eq("job_id", value: jobId)
            .eq("language_id", value: languageId)
            .execute()
    }
    
    func fetchEducationRequirements() async throws -> [JobEducationRequirement] {
        try await client
            .from("job_education_requirements")
            .select(
                """
                id,
                job_id,
                degree,
                field_of_study,
                requirement_type
                """
            )
            .execute()
            .value
    }
}
