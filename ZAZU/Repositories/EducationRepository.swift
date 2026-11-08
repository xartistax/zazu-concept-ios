
import Foundation
import Supabase

final class EducationRepository {

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

    // MARK: - Employer Education

    func fetchEmployerCandidateEducations(
        jobId: UUID
    ) async throws -> [Education] {
        struct Params: Encodable {
            let pJobId: UUID

            enum CodingKeys: String, CodingKey {
                case pJobId = "p_job_id"
            }
        }

        return try await client
            .rpc(
                "get_employer_candidate_educations",
                params: Params(pJobId: jobId)
            )
            .execute()
            .value
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
            degree: degree.trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
            fieldOfStudy: fieldOfStudy?
                .trimmingCharacters(in: .whitespacesAndNewlines),
            requirementType: requirementType
        )

        try await client
            .from("job_education_requirements")
            .insert(payload)
            .execute()
    }

    // MARK: - Candidate Educations

    func deleteAll(
        candidateId: UUID
    ) async throws {
        try await client
            .from("educations")
            .delete()
            .eq("candidate_id", value: candidateId)
            .execute()
    }

    func fetchAll(
        candidateId: UUID
    ) async throws -> [Education] {
        try await client
            .from("educations")
            .select(
                """
                *,
                qualification:education_qualifications(
                    id,
                    education_level,
                    name
                )
                """
            )
            .eq("candidate_id", value: candidateId)
            .order("start_date", ascending: false)
            .execute()
            .value
    }

    func create(
        candidateId: UUID,
        institutionName: String,
        degree: String,
        fieldOfStudy: String?,
        startDate: Date?,
        endDate: Date?,
        isCurrent: Bool,
        description: String?,
        educationLevel: String? = nil,
        completionStatus: String? = nil,
        qualificationId: UUID? = nil,
        educationTypeId: UUID? = nil,
        educationTypeDegreeId: UUID? = nil,
        educationFieldId: UUID? = nil,
        institutionTypeId: UUID? = nil,
        institutionId: UUID? = nil
        
    ) async throws {
        let payload = EducationInsert(
            candidateId: candidateId,
            institutionName: institutionName,
            degree: degree,
            fieldOfStudy: fieldOfStudy,
            startDate: startDate.map {
                Self.dateOnlyFormatter.string(from: $0)
            },
            endDate: isCurrent
                ? nil
                : endDate.map {
                    Self.dateOnlyFormatter.string(from: $0)
                },
            isCurrent: isCurrent,
            description: description,
            educationLevel: educationLevel,
            completionStatus: completionStatus,
            qualificationId: qualificationId,
            educationTypeId: educationTypeId,
            educationTypeDegreeId: educationTypeDegreeId,
            educationFieldId: educationFieldId,
            institutionTypeId: institutionTypeId,
            institutionId: institutionId
        )

        try await client
            .from("educations")
            .insert(payload)
            .execute()
    }

    func delete(
        id: UUID
    ) async throws {
        try await client
            .from("educations")
            .delete()
            .eq("id", value: id)
            .execute()
    }
    
    // MARK: - Official Titles

    func fetchQualificationOptions(
        degreeId: UUID,
        fieldId: UUID?,
        institutionId: UUID?
    ) async throws -> [EducationQualification] {
        struct TitleOption: Decodable {
            let qualification: EducationQualification
        }

        let fieldFilter: String

        if let fieldId {
            fieldFilter =
                "or(education_field_id.is.null,education_field_id.eq.\(fieldId.uuidString))"
        } else {
            fieldFilter = "education_field_id.is.null"
        }

        let institutionFilter: String

        if let institutionId {
            institutionFilter =
                "or(institution_id.is.null,institution_id.eq.\(institutionId.uuidString))"
        } else {
            institutionFilter = "institution_id.is.null"
        }

        let options: [TitleOption] = try await client
            .from("education_qualification_options")
            .select(
                """
                qualification:education_qualifications!inner(
                    id,
                    education_level,
                    name
                )
                """
            )
            .eq("education_type_degree_id", value: degreeId)
            .eq("qualification.is_active", value: true)
            .or("and(\(fieldFilter),\(institutionFilter))")
            .execute()
            .value

        var seenIDs = Set<UUID>()

        return options
            .map(\.qualification)
            .filter {
                seenIDs.insert($0.id).inserted
            }
            .sorted {
                $0.name.localizedStandardCompare($1.name)
                    == .orderedAscending
            }
    }

    // MARK: - Legacy Qualifications

    func searchQualifications(
        educationLevel: String,
        searchText: String
    ) async throws -> [EducationQualification] {
        var query = client
            .from("education_qualifications")
            .select("id, education_level, name")
            .eq("education_level", value: educationLevel)
            .eq("is_active", value: true)

        let trimmedSearch = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        if !trimmedSearch.isEmpty {
            query = query.ilike(
                "name",
                pattern: "%\(trimmedSearch)%"
            )
        }

        return try await query
            .order("name", ascending: true)
            .limit(50)
            .execute()
            .value
    }

    // MARK: - Education Types

    func fetchEducationTypes() async throws -> [EducationType] {
        try await client
            .from("education_types")
            .select("id, code, name_de, sort_order")
            .order("sort_order", ascending: true)
            .execute()
            .value
    }

    // MARK: - Education Degrees

    func fetchEducationTypeDegrees(
        educationTypeId: UUID
    ) async throws -> [EducationTypeDegree] {
        try await client
            .from("education_type_degrees")
            .select(
                "id, education_type_id, name_de, note, sort_order"
            )
            .eq("education_type_id", value: educationTypeId)
            .order("sort_order", ascending: true)
            .execute()
            .value
    }

    // MARK: - Education Fields

    func fetchEducationFields(
        kind: String,
        parentId: UUID? = nil,
        searchText: String = ""
    ) async throws -> [EducationField] {
        var query = client
            .from("education_fields")
            .select(
                """
                id, code, name_de, parent_id,
                field_kind, country_code
                """
            )
            .eq("field_kind", value: kind)

        if let parentId {
            query = query.eq("parent_id", value: parentId)
        }

        let trimmedSearch = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        if !trimmedSearch.isEmpty {
            query = query.ilike(
                "name_de",
                pattern: "%\(trimmedSearch)%"
            )
        }

        return try await query
            .order("name_de", ascending: true)
            .limit(100)
            .execute()
            .value
    }

    func fetchFieldsForDegree(
        degreeId: UUID
    ) async throws -> [EducationField] {
        struct DegreeFieldRelation: Decodable {
            let educationField: EducationField

            enum CodingKeys: String, CodingKey {
                case educationField = "education_field"
            }
        }

        let relations: [DegreeFieldRelation] = try await client
            .from("education_degree_fields")
            .select(
                """
                education_field:education_fields(
                    id, code, name_de, parent_id,
                    field_kind, country_code
                )
                """
            )
            .eq("education_type_degree_id", value: degreeId)
            .execute()
            .value

        return relations.map(\.educationField)
    }

    // MARK: - Institution Types

    func fetchEducationInstitutionTypes()
        async throws -> [EducationInstitutionType] {
        try await client
            .from("education_institution_types")
            .select(
                """
                id, name_de, typical_education_type,
                countries, note, sort_order
                """
            )
            .order("sort_order", ascending: true)
            .execute()
            .value
    }

    // MARK: - Institutions

    func searchEducationInstitutions(
        searchText: String
    ) async throws -> [EducationInstitution] {
        var query = client
            .from("education_institutions")
            .select(
                """
                id, institution_type_id,
                name, country_code
                """
            )

        let trimmedSearch = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        if !trimmedSearch.isEmpty {
            query = query.ilike(
                "name",
                pattern: "%\(trimmedSearch)%"
            )
        }

        return try await query
            .order("name", ascending: true)
            .limit(50)
            .execute()
            .value
    }
}

// MARK: - Database Insert Payload

private struct EducationInsert: Encodable {

    let candidateId: UUID
    let institutionName: String
    let degree: String
    let fieldOfStudy: String?

    let startDate: String?
    let endDate: String?
    let isCurrent: Bool

    let description: String?

    let educationLevel: String?
    let completionStatus: String?
    let qualificationId: UUID?
    
    let educationTypeId: UUID?
    let educationTypeDegreeId: UUID?
    let educationFieldId: UUID?
    let institutionTypeId: UUID?
    let institutionId: UUID?

    enum CodingKeys: String, CodingKey {
        case candidateId = "candidate_id"
        case institutionName = "institution_name"
        case degree
        case fieldOfStudy = "field_of_study"
        case startDate = "start_date"
        case endDate = "end_date"
        case isCurrent = "is_current"
        case description
        case educationLevel = "education_level"
        case completionStatus = "completion_status"
        case qualificationId = "qualification_id"
        case educationTypeId = "education_type_id"
        case educationTypeDegreeId = "education_type_degree_id"
        case educationFieldId = "education_field_id"
        case institutionTypeId = "institution_type_id"
        case institutionId = "institution_id"
    }
}
