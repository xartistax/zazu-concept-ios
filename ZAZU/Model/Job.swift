//
//  Job.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 29.09.2026.
//

import Foundation

struct Job: Identifiable, Decodable, Sendable, Hashable {
    let id: UUID
    let companyId: UUID
    let title: String
    let description: String
    let activityArea: String?
    let isActive: Bool
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
        case id
        case companyId = "company_id"
        case title
        case description
        case activityArea = "activity_area"
        case isActive = "is_active"
        case latitude
        case longitude
        case location
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

enum RequirementType: String, Codable, Sendable {
    case must
    case optional

    var title: String {
        switch self {
        case .must:
            return "MUSS"
        case .optional:
            return "OPTIONAL"
        }
    }
}

enum JobHomeofficeSchedule: String, Codable, Sendable {
    case fixed
    case flexible

    var title: String {
        switch self {
        case .fixed:
            return "Fixe Tage"
        case .flexible:
            return "Flexible Tage"
        }
    }
}
