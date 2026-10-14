//
//  ProfileViewModel.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class ProfileViewModel {
    var firstName = ""
    var lastName = ""
    var phoneNumber = ""
    var region = ""
    var nationality = ""
    var hasWorkAuthorization = false
    var workAuthorizationDetails = ""
    
    var workExperiences: [WorkExperience] = []
    var skills: [Skill] = []
    var candidateSkills: [CandidateSkill] = []
    var educations: [Education] = []
    var languages: [Language] = []
    var candidateLanguages: [CandidateLanguage] = []
    
    var desiredWorkloadMin: Int?
    var desiredWorkloadMax: Int?
    var desiredWorkLocation = ""
    var workRadiusKm: Int?
    var willingToCommute = false
    var willingToRelocate = false
    var earliestStartDate: String?

    var preferredWorkModel: PreferredWorkModel?
    var homeofficePreference: HomeofficePreference?
    var desiredHomeofficeDays: Int?
    var preferredHomeofficeSchedule: HomeofficeSchedulePreference?
    var acceptsFullyRemote = false

    var salaryMin: Int?
    var salaryMax: Int?

    var isLoading = true
    var isSaving = false
    var errorMessage: String?
    var successMessage: String?

    private let profileRepository: ProfileRepository
    private let candidateProfileRepository: CandidateProfileRepository
    private let workExperienceRepository: WorkExperienceRepository
    private let skillRepository: SkillRepository
    private let educationRepository: EducationRepository
    private let languageRepository: LanguageRepository
    private let userId: UUID
    
    

    init(
        profileRepository: ProfileRepository,
        candidateProfileRepository: CandidateProfileRepository,
        workExperienceRepository: WorkExperienceRepository,
        skillRepository: SkillRepository,
        educationRepository: EducationRepository,
        languageRepository: LanguageRepository,
        userId: UUID
    ) {
        self.profileRepository = profileRepository
        self.candidateProfileRepository = candidateProfileRepository
        self.workExperienceRepository = workExperienceRepository
        self.skillRepository = skillRepository
        self.educationRepository = educationRepository
        self.languageRepository = languageRepository
        self.userId = userId
    }

    var canSave: Bool {
        !firstName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
        &&
        !lastName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
        &&
        !phoneNumber

                .trimmingCharacters(in: .whitespacesAndNewlines)

                .isEmpty

            &&
        !isSaving
    }

    func load() async {
        errorMessage = nil

        do {
            async let profileRequest =
                profileRepository.fetchProfile(userId: userId)

            async let candidateProfileRequest =
                candidateProfileRepository.fetchProfile(userId: userId)

            async let workExperiencesRequest =
                workExperienceRepository.fetchAll(candidateId: userId)
            
            async let skillsRequest =
                skillRepository.fetchSkills()

            async let candidateSkillsRequest =
                skillRepository.fetchCandidateSkills(candidateId: userId)
            
            async let educationsRequest =
                educationRepository.fetchAll(candidateId: userId)
            
            async let languagesRequest =
                languageRepository.fetchLanguages()

            async let candidateLanguagesRequest =
                languageRepository.fetchCandidateLanguages(candidateId: userId)

            let (
                profile,
                candidateProfile,
                loadedWorkExperiences,
                loadedSkills,
                loadedCandidateSkills,
                loadedEducations,
                loadedLanguages,
                loadedCandidateLanguages
            ) = try await (
                profileRequest,
                candidateProfileRequest,
                workExperiencesRequest,
                skillsRequest,
                candidateSkillsRequest,
                educationsRequest,
                languagesRequest,
                candidateLanguagesRequest
            )

            firstName = profile.firstName ?? ""
            lastName = profile.lastName ?? ""
            phoneNumber = profile.phoneNumber ?? ""

            region = candidateProfile.region ?? ""
            nationality = candidateProfile.nationality ?? ""
            hasWorkAuthorization =
                candidateProfile.hasWorkAuthorization ?? false
            workAuthorizationDetails =
                candidateProfile.workAuthorizationDetails ?? ""
            
            
            desiredWorkloadMin = candidateProfile.desiredWorkloadMin
            desiredWorkloadMax = candidateProfile.desiredWorkloadMax
            desiredWorkLocation = candidateProfile.desiredWorkLocation ?? ""
            workRadiusKm = candidateProfile.workRadiusKm
            willingToCommute = candidateProfile.willingToCommute ?? false
            willingToRelocate = candidateProfile.willingToRelocate ?? false
            earliestStartDate = candidateProfile.earliestStartDate

            preferredWorkModel = candidateProfile.preferredWorkModel
            homeofficePreference = candidateProfile.homeofficePreference
            desiredHomeofficeDays = candidateProfile.desiredHomeofficeDays
            preferredHomeofficeSchedule =
                candidateProfile.preferredHomeofficeSchedule
            acceptsFullyRemote = candidateProfile.acceptsFullyRemote ?? false

            salaryMin = candidateProfile.salaryMin
            salaryMax = candidateProfile.salaryMax

            workExperiences = loadedWorkExperiences
            skills = loadedSkills
            candidateSkills = loadedCandidateSkills
            educations = loadedEducations
            languages = loadedLanguages
            candidateLanguages = loadedCandidateLanguages
            
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func save() async {
        guard canSave else {
            return
        }

        isSaving = true
        errorMessage = nil
        successMessage = nil

        defer {
            isSaving = false
        }

        do {
            let normalizedPhoneNumber = phoneNumber
                .trimmingCharacters(in: .whitespacesAndNewlines)

            try await profileRepository.updateBasicInformation(
                userId: userId,
                firstName: firstName.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
                lastName: lastName.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
                phoneNumber: normalizedPhoneNumber.isEmpty
                    ? nil
                    : normalizedPhoneNumber
            )

            successMessage = "Profildaten gespeichert."
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
