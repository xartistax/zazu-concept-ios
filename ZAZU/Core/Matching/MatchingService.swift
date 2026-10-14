//
//  MatchingService.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 29.09.2026.
//

import Foundation

struct MatchingService {

    // MARK: - Skills

    func fulfillsSkill(
        candidateSkill: CandidateSkill?,
        requirement: JobSkillRequirement
    ) -> Bool {
        guard let candidateSkill else {
            return false
        }

        return skillRank(candidateSkill.proficiency)
            >= skillRank(requirement.minimumProficiency)
    }

    // MARK: - Languages

    func fulfillsLanguage(
        candidateLanguage: CandidateLanguage?,
        requirement: JobLanguageRequirement
    ) -> Bool {
        guard let candidateLanguage else {
            return false
        }

        return languageRank(candidateLanguage.proficiency)
            >= languageRank(requirement.minimumProficiency)
    }
    
    




    // MARK: - Salary

    func salaryRangesOverlap(
        candidateMin: Int?,
        candidateMax: Int?,
        jobMin: Int?,
        jobMax: Int?
    ) -> Bool {
        guard
            let candidateMin,
            let candidateMax,
            let jobMin,
            let jobMax
        else {
            return false
        }

        return candidateMin <= jobMax
            && jobMin <= candidateMax
    }

    // MARK: - Workload

    func workloadRangesOverlap(
        candidateMin: Int?,
        candidateMax: Int?,
        jobMin: Int,
        jobMax: Int
    ) -> Bool {
        guard
            let candidateMin,
            let candidateMax
        else {
            return false
        }

        return candidateMin <= jobMax
            && jobMin <= candidateMax
    }

    
    
    //MARK: - Append
    
    private func append(
        _ criterion: MatchCriterion,
        requirementType: RequirementType,
        mustCriteria: inout [MatchCriterion],
        optionalCriteria: inout [MatchCriterion]
    ) {
        switch requirementType {
        case .must:
            mustCriteria.append(criterion)

        case .optional:
            optionalCriteria.append(criterion)
        }
    }
    
    
    // MARK: - Location

    func distanceInKilometers(
        fromLatitude: Double,
        fromLongitude: Double,
        toLatitude: Double,
        toLongitude: Double
    ) -> Double {
        let earthRadiusKm = 6_371.0

        let latitudeDelta =
            degreesToRadians(toLatitude - fromLatitude)

        let longitudeDelta =
            degreesToRadians(toLongitude - fromLongitude)

        let fromLatitudeRadians =
            degreesToRadians(fromLatitude)

        let toLatitudeRadians =
            degreesToRadians(toLatitude)

        let a =
            sin(latitudeDelta / 2) * sin(latitudeDelta / 2)
            +
            cos(fromLatitudeRadians)
            * cos(toLatitudeRadians)
            * sin(longitudeDelta / 2)
            * sin(longitudeDelta / 2)

        let c = 2 * atan2(
            sqrt(a),
            sqrt(1 - a)
        )

        return earthRadiusKm * c
    }

    private func degreesToRadians(
        _ degrees: Double
    ) -> Double {
        degrees * .pi / 180
    }
    
    
    // MARK: - Ranking

    private func skillRank(
        _ proficiency: SkillProficiency
    ) -> Int {
        switch proficiency {
        case .basic:
            return 1
        case .good:
            return 2
        case .veryGood:
            return 3
        case .expert:
            return 4
        }
    }

    private func languageRank(
        _ proficiency: LanguageProficiency
    ) -> Int {
        switch proficiency {
        case .a1:
            return 1
        case .a2:
            return 2
        case .b1:
            return 3
        case .b2:
            return 4
        case .c1:
            return 5
        case .c2:
            return 6
        case .native:
            return 7
        }
    }
    
    
    
    func match(
        candidate: CandidateProfile,
        candidateSkills: [CandidateSkill],
        candidateLanguages: [CandidateLanguage],
        candidateEducations: [Education],
        workExperiences: [WorkExperience],
        job: Job,
        skillRequirements: [JobSkillRequirement],
        languageRequirements: [JobLanguageRequirement],
        educationRequirements: [JobEducationRequirement]
    ) -> MatchResult {
        var mustCriteria: [MatchCriterion] = []
        var optionalCriteria: [MatchCriterion] = []
        
        // MARK: Work authorization
        
        if job.requiresWorkAuthorization {
            let fulfilled =
            candidate.hasWorkAuthorization == true

            
            let criterion = MatchCriterion(
                id: "work-authorization",
                type: .workAuthorization,
                title: "Arbeitsbewilligung",
                detail: fulfilled
                ? "Anforderung erfüllt"
                : "Erforderliche Arbeitsbewilligung fehlt",
                isFulfilled: fulfilled
            )
            
            append(
                criterion,
                requirementType: job.workAuthorizationRequirementType,
                mustCriteria: &mustCriteria,
                optionalCriteria: &optionalCriteria
            )
        }
        
        // MARK: - Work Experience
        
        if let requiredYears = job.requiredWorkExperienceYears {
            let candidateYears = totalWorkExperienceYears(
                workExperiences: workExperiences
            )
            
            let fulfilled =
            candidateYears >= Double(requiredYears)
            
            let criterion = MatchCriterion(
                id: "work-experience",
                type: .workExperience,
                title: "Berufserfahrung",
                detail: fulfilled
                ? "Mindestberufserfahrung erfüllt"
                : "Mindestberufserfahrung nicht erfüllt",
                requirementDetail: "Mindestens: \(requiredYears) Jahre",
                isFulfilled: fulfilled
            )
            
            append(
                criterion,
                requirementType: job.workExperienceRequirementType,
                mustCriteria: &mustCriteria,
                optionalCriteria: &optionalCriteria
            )
        }
        
        // MARK: Workload
        
        let workloadFulfilled = workloadRangesOverlap(
            candidateMin: candidate.desiredWorkloadMin,
            candidateMax: candidate.desiredWorkloadMax,
            jobMin: job.workloadMin,
            jobMax: job.workloadMax
        )
        
        optionalCriteria.append(
            MatchCriterion(
                id: "workload",
                type: .workload,
                title: "Arbeitspensum",
                detail: workloadFulfilled
                ? "Gewünschtes Pensum überschneidet sich mit dem Job"
                : "Gewünschtes Pensum überschneidet sich nicht mit dem Job",
                isFulfilled: workloadFulfilled
            )
        )
        
        
        // MARK: - Location
        
        let locationCriterion: MatchCriterion
        
        if
            let candidateLatitude = candidate.desiredWorkLatitude,
            let candidateLongitude = candidate.desiredWorkLongitude,
            let jobLatitude = job.latitude,
            let jobLongitude = job.longitude
        {
            let distance = distanceInKilometers(
                fromLatitude: candidateLatitude,
                fromLongitude: candidateLongitude,
                toLatitude: jobLatitude,
                toLongitude: jobLongitude
            )
            
            let radius = Double(candidate.workRadiusKm ?? 0)
            let insideRadius = distance <= radius
            
            let fulfilled =
            insideRadius
            || candidate.willingToCommute == true
            || candidate.willingToRelocate == true
            || (
                candidate.acceptsFullyRemote == true
                && job.fullyRemoteAvailable
            )
            
            let detail: String
            
            if insideRadius {
                detail = "Job liegt im gewünschten Arbeitsradius"
            } else if candidate.acceptsFullyRemote == true
                        && job.fullyRemoteAvailable {
                detail = "Ausserhalb des Radius, aber vollständig Remote möglich"
            } else if candidate.willingToRelocate == true {
                detail = "Ausserhalb des Radius, Umzugsbereitschaft vorhanden"
            } else if candidate.willingToCommute == true {
                detail = "Ausserhalb des Radius, Pendelbereitschaft vorhanden"
            } else {
                detail = "Job liegt ausserhalb des gewünschten Arbeitsradius"
            }
            
            locationCriterion = MatchCriterion(
                id: "location",
                type: .location,
                title: "Standort",
                detail: detail,
                requirementDetail:
                    "\(Int(distance.rounded())) km Luftdistanz · Radius \(Int(radius)) km",
                isFulfilled: fulfilled
            )
        } else {
            locationCriterion = MatchCriterion(
                id: "location",
                type: .location,
                title: "Standort",
                detail: "Standort konnte nicht vollständig verglichen werden",
                requirementDetail: nil,
                isFulfilled: false
            )
        }
        
        optionalCriteria.append(locationCriterion)
        
        // MARK: Skills
        
        for requirement in skillRequirements {
            let candidateSkill = candidateSkills.first {
                $0.skillId == requirement.skillId
            }
            
            let fulfilled = fulfillsSkill(
                candidateSkill: candidateSkill,
                requirement: requirement
            )
            
            let criterion = MatchCriterion(
                id: "skill-\(requirement.skillId)",
                type: .skill,
                title: "Skill",
                detail: fulfilled
                ? "Gefordertes Skill-Level erfüllt"
                : "Gefordertes Skill-Level nicht erfüllt",
                requirementDetail: "Mindestens: \(requirement.minimumProficiency.title)",
                isFulfilled: fulfilled
            )
            
            append(
                criterion,
                requirementType: requirement.requirementType,
                mustCriteria: &mustCriteria,
                optionalCriteria: &optionalCriteria
            )
        }
        
        // MARK: Languages
        
        for requirement in languageRequirements {
            let candidateLanguage = candidateLanguages.first {
                $0.languageId == requirement.languageId
            }
            
            let fulfilled = fulfillsLanguage(
                candidateLanguage: candidateLanguage,
                requirement: requirement
            )
            
            let criterion = MatchCriterion(
                id: "language-\(requirement.languageId)",
                type: .language,
                title: "Sprache",
                detail: fulfilled
                ? "Gefordertes Sprachniveau erfüllt"
                : "Gefordertes Sprachniveau nicht erfüllt",
                requirementDetail: "Mindestens: \(requirement.minimumProficiency.title)",
                isFulfilled: fulfilled
            )
            
            append(
                criterion,
                requirementType: requirement.requirementType,
                mustCriteria: &mustCriteria,
                optionalCriteria: &optionalCriteria
            )
        }
        
        // MARK: Education

        for requirement in educationRequirements {
            let fulfilled = fulfillsEducation(
                candidateEducations: candidateEducations,
                requirement: requirement
            )

            let requirementDescription: String

            if let field = requirement.fieldOfStudy,
               !field.isEmpty {
                requirementDescription =
                    "\(requirement.degree), \(field)"
            } else {
                requirementDescription =
                    requirement.degree
            }

            let criterion = MatchCriterion(
                id: "education-\(requirement.id)",
                type: .education,
                title: "Ausbildung",
                detail: fulfilled
                    ? "Geforderter Abschluss vorhanden"
                    : "Geforderter Abschluss nicht vorhanden",
                requirementDetail: requirementDescription,
                isFulfilled: fulfilled
            )

            append(
                criterion,
                requirementType: requirement.requirementType,
                mustCriteria: &mustCriteria,
                optionalCriteria: &optionalCriteria
            )
        }

    
        
     
        
        

        // MARK: Salary

        let salaryFulfilled = salaryRangesOverlap(
            candidateMin: candidate.salaryMin,
            candidateMax: candidate.salaryMax,
            jobMin: job.salaryMin,
            jobMax: job.salaryMax
        )

        let salaryCriterion = MatchCriterion(
            id: "salary",
            type: .salary,
            title: "Lohn",
            detail: salaryFulfilled
                ? "Lohnvorstellungen überschneiden sich"
                : "Lohnvorstellungen überschneiden sich nicht",
            isFulfilled: salaryFulfilled
        )

        // MARK: Work model

        let workModelFulfilled =
            candidate.preferredWorkModel == job.workModel
            || (
                candidate.acceptsFullyRemote == true
                && job.fullyRemoteAvailable
            )

        let workModelCriterion = MatchCriterion(
            id: "work-model",
            type: .workModel,
            title: "Arbeitsmodell",
            detail: workModelFulfilled
                ? "Gewünschtes Arbeitsmodell passt"
                : "Gewünschtes Arbeitsmodell weicht ab",
            isFulfilled: workModelFulfilled
        )

        append(
            workModelCriterion,
            requirementType: job.workModelRequirementType,
            mustCriteria: &mustCriteria,
            optionalCriteria: &optionalCriteria
        )
        
        
        // MARK: - Homeoffice

        let homeofficeFulfilled: Bool

        switch candidate.homeofficePreference {
        case .yes:
            let enoughDays =
                job.homeofficeAvailable
                && (job.homeofficeDays ?? 0)
                    >= (candidate.desiredHomeofficeDays ?? 0)

            let scheduleFits: Bool

            switch candidate.preferredHomeofficeSchedule {
            case .fixed:
                scheduleFits =
                    job.homeofficeSchedule == .fixed

            case .flexible:
                scheduleFits =
                    job.homeofficeSchedule == .flexible

            case .either:
                scheduleFits = true

            case nil:
                scheduleFits = true
            }

            homeofficeFulfilled =
                enoughDays && scheduleFits

        case .no:
            homeofficeFulfilled =
                job.workModel != .remote

        case .either:
            homeofficeFulfilled = true

        case nil:
            homeofficeFulfilled = false
        }

        let homeofficeCriterion = MatchCriterion(
            id: "homeoffice",
            type: .homeoffice,
            title: "Homeoffice",
            detail: homeofficeFulfilled
                ? "Homeoffice-Präferenz passt"
                : "Homeoffice-Präferenz weicht vom Angebot ab",
            requirementDetail: homeofficeDetail(for: job),
            isFulfilled: homeofficeFulfilled
        )
        append(
            homeofficeCriterion,
            requirementType: job.homeofficeRequirementType,
            mustCriteria: &mustCriteria,
            optionalCriteria: &optionalCriteria
        )



        return MatchResult(
            jobId: job.id,
            mustCriteria: mustCriteria,
            optionalCriteria: optionalCriteria,
            salaryCompatibility: salaryCriterion,
            workModelCompatibility: workModelCriterion,
            homeofficeCompatibility: homeofficeCriterion
        )
    }
    
    
    // MARK: - Education

    func fulfillsEducation(
        candidateEducations: [Education],
        requirement: JobEducationRequirement
    ) -> Bool {
        candidateEducations.contains { education in
            let degreeMatches =
                normalized(education.degree)
                == normalized(requirement.degree)

            let fieldMatches: Bool

            if let requiredField = requirement.fieldOfStudy,
               !requiredField.trimmingCharacters(
                    in: .whitespacesAndNewlines
               ).isEmpty {
                fieldMatches =
                    normalized(education.fieldOfStudy ?? "")
                    == normalized(requiredField)
            } else {
                fieldMatches = true
            }

            return degreeMatches && fieldMatches
        }
    }

    private func normalized(
        _ value: String
    ) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(
                options: [
                    .caseInsensitive,
                    .diacriticInsensitive
                ],
                locale: Locale(identifier: "de_CH")
            )
    }
    
    
    private func homeofficeDetail(
        for job: Job
    ) -> String {
        if job.fullyRemoteAvailable {
            return "Vollständig Remote möglich"
        }

        guard job.homeofficeAvailable else {
            return "Kein Homeoffice"
        }

        let days = job.homeofficeDays ?? 0

        switch job.homeofficeSchedule {
        case .fixed:
            return "\(days) Tage Homeoffice / Woche, fix"

        case .flexible:
            return "\(days) Tage Homeoffice / Woche, flexibel"

        case nil:
            return "\(days) Tage Homeoffice / Woche"
        }
    }
    
    
    func totalWorkExperienceYears(
        workExperiences: [WorkExperience],
        referenceDate: Date = Date()
    ) -> Double {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"

        let intervals: [(start: Date, end: Date)] = workExperiences.compactMap { experience in
            guard let startDate = formatter.date(from: experience.startDate) else {
                return nil
            }

            let endDate: Date

            if experience.isCurrent {
                endDate = referenceDate
            } else {
                guard
                    let value = experience.endDate,
                    let parsedEndDate = formatter.date(from: value)
                else {
                    return nil
                }

                endDate = parsedEndDate
            }

            guard endDate >= startDate else {
                return nil
            }

            return (startDate, endDate)
        }
        .sorted {
            $0.start < $1.start
        }

        guard var current = intervals.first else {
            return 0
        }

        var merged: [(start: Date, end: Date)] = []

        for interval in intervals.dropFirst() {
            if interval.start <= current.end {
                current.end = max(current.end, interval.end)
            } else {
                merged.append(current)
                current = interval
            }
        }

        merged.append(current)

        let totalDays = merged.reduce(0.0) { result, interval in
            result + interval.end.timeIntervalSince(interval.start) / 86_400
        }

        return totalDays / 365.2425
    }
}
