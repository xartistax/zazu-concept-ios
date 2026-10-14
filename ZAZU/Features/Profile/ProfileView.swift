//
//  ProfileView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import SwiftUI
import Supabase

struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    @State private var isSigningOut = false
    @State private var signOutError: String?
    @State private var accountEmail = ""
    
    private let appState: AppState
    private let authenticationService: AuthenticationService
    private let profileRepository: ProfileRepository
    private let candidateProfileRepository: CandidateProfileRepository
    private let workExperienceRepository: WorkExperienceRepository
    private let skillRepository: SkillRepository
    private let educationRepository: EducationRepository
    private let languageRepository: LanguageRepository
    private let candidateJobInteractionRepository: CandidateJobInteractionRepository
    private let matchRepository: MatchRepository
    private let supabaseClient: SupabaseClient
    private let accountSwitcher: PoCAccountSwitcher
    private let userId: UUID

    init(
        viewModel: ProfileViewModel,
        appState: AppState,
        authenticationService: AuthenticationService,
        profileRepository: ProfileRepository,
        candidateProfileRepository: CandidateProfileRepository,
        workExperienceRepository: WorkExperienceRepository,
        skillRepository: SkillRepository,
        educationRepository: EducationRepository,
        languageRepository: LanguageRepository,
        candidateJobInteractionRepository: CandidateJobInteractionRepository,
        matchRepository: MatchRepository,
        supabaseClient: SupabaseClient,
        accountSwitcher: PoCAccountSwitcher,
        userId: UUID
    ) {
        _viewModel = State(initialValue: viewModel)

        self.appState = appState
        self.authenticationService = authenticationService
        self.profileRepository = profileRepository
        self.candidateProfileRepository = candidateProfileRepository
        self.workExperienceRepository = workExperienceRepository
        self.skillRepository = skillRepository
        self.educationRepository = educationRepository
        self.languageRepository = languageRepository
        self.candidateJobInteractionRepository = candidateJobInteractionRepository
        self.matchRepository = matchRepository
        self.supabaseClient = supabaseClient
        self.accountSwitcher = accountSwitcher
        self.userId = userId
    }
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                ZAZUColors.veryLightPurple
                    .ignoresSafeArea()

                if viewModel.isLoading {
                    loadingView
                } else {
                    profileContent
                }
            }
            .navigationTitle("Profil")
            .onAppear {
                        Task {
                            await viewModel.load()
                            await loadAccountEmail()
                        }
                    }
        }
    }

    // MARK: - Content

    private var profileContent: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.large
            ) {
                header
                basicInformationCard
                workExperienceCard
                skillsCard
                educationCard
                languagesCard
                jobPreferencesCard
                workAndSalaryCard
                pocToolsCard
                logoutSection
                feedback
            }
            .padding(ZAZUSpacing.large)
        }
    }
    
    // MARK: - Logout

    private var logoutSection: some View {
        VStack(spacing: ZAZUSpacing.small) {
            Button(role: .destructive) {
                Task {
                    await signOut()
                }
            } label: {
                HStack {
                    if isSigningOut {
                        ProgressView()
                            .tint(ZAZUColors.danger)
                    } else {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }

                    Text(
                        isSigningOut
                            ? "Wird abgemeldet …"
                            : "Abmelden"
                    )
                    .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, ZAZUSpacing.medium)
            }
            .disabled(isSigningOut)

            if let signOutError {
                Text(signOutError)
                    .font(.caption)
                    .foregroundStyle(ZAZUColors.danger)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            ZStack {
                Circle()
                    .fill(ZAZUColors.lightPurple)
                    .frame(width: 72, height: 72)

                Image(systemName: "person.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(ZAZUColors.primary)
            }

            Text(displayName)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(ZAZUColors.textPrimary)

            if !accountEmail.isEmpty {
                Label(accountEmail, systemImage: "envelope.fill")
                    .font(.subheadline)
                    .foregroundStyle(ZAZUColors.textSecondary)
            }

            Text("Kandidatenprofil")
                .font(.subheadline)
                .foregroundStyle(ZAZUColors.textSecondary)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }


    
    // MARK: - Basic Info View
    private var basicInformationCard: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            HStack {
                Label(
                    "Basisinformationen",
                    systemImage: "person.text.rectangle"
                )
                .font(.headline)
                .foregroundStyle(ZAZUColors.textPrimary)

                Spacer()

                NavigationLink {
                    EditBasicInformationView(
                        viewModel: OnboardingViewModel(
                            repository: candidateProfileRepository,
                            profileRepository: profileRepository,
                            userId: userId
                        ),
                        onSaved: {
                            Task {
                                await viewModel.load()
                            }
                        }
                    )
                } label: {
                    Text("Bearbeiten")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(ZAZUColors.primary)
                }
            }

            Divider()
            
            profileRow(
                title: "Telefonnummer",
                value: viewModel.phoneNumber
            )
            
            profileRow(
                title: "Region",
                value: viewModel.region
            )

            profileRow(
                title: "Staatsangehörigkeit",
                value: viewModel.nationality
            )

            profileRow(
                title: "Arbeitsberechtigung",
                value: viewModel.hasWorkAuthorization
                    ? "Vorhanden"
                    : "Nicht vorhanden"
            )

            if !viewModel.workAuthorizationDetails.isEmpty {
                profileRow(
                    title: "Bewilligung",
                    value: viewModel.workAuthorizationDetails
                )
            }


        }
        .padding(ZAZUSpacing.medium)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: ZAZURadius.large
            )
        )
    }
    
    
    // MARK: - Experience View
    private var workExperienceCard: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            HStack {
                Label(
                    "Berufserfahrung",
                    systemImage: "briefcase.fill"
                )
                .font(.headline)
                .foregroundStyle(ZAZUColors.textPrimary)

                Spacer()

                NavigationLink {
                    WorkExperienceView(
                        viewModel: WorkExperienceViewModel(
                            workExperienceRepository: workExperienceRepository,
                            candidateProfileRepository: candidateProfileRepository,
                            candidateId: userId
                        ),
                        mode: .editing
                    )
                } label: {
                    Text("Bearbeiten")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(ZAZUColors.primary)
                }
            }

            Divider()

            if viewModel.workExperiences.isEmpty {
                Text("Noch keine Berufserfahrung angegeben.")
                    .foregroundStyle(ZAZUColors.textSecondary)
            } else {
                ForEach(
                    Array(viewModel.workExperiences.enumerated()),
                    id: \.element.id
                ) { index, experience in
                    VStack(
                        alignment: .leading,
                        spacing: ZAZUSpacing.small
                    ) {
                        Text(experience.jobTitle)
                            .fontWeight(.semibold)
                            .foregroundStyle(ZAZUColors.textPrimary)

                        Text(experience.employerName)
                            .foregroundStyle(ZAZUColors.textSecondary)

                        if let location = experience.location,
                           !location.isEmpty {
                            Label(
                                location,
                                systemImage: "mappin.and.ellipse"
                            )
                            .font(.subheadline)
                            .foregroundStyle(ZAZUColors.textSecondary)
                        }

                        if experience.isCurrent {
                            Text("Aktuelle Position")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(ZAZUColors.primary)
                        }
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )

                    if index < viewModel.workExperiences.count - 1 {
                        Divider()
                    }
                }
            }
        }
        .padding(ZAZUSpacing.medium)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: ZAZURadius.large
            )
        )
    }
    
    // MARK: - SkillView
    private var skillsCard: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            HStack {
                Label(
                    "Skills & Systemkenntnisse",
                    systemImage: "bolt.fill"
                )
                .font(.headline)
                .foregroundStyle(ZAZUColors.textPrimary)

                Spacer()

                NavigationLink {
                    SkillsView(
                        viewModel: SkillsViewModel(
                            skillRepository: skillRepository,
                            candidateProfileRepository: candidateProfileRepository,
                            candidateId: userId
                        ),
                        mode: .editing
                    )
                } label: {
                    Text("Bearbeiten")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(ZAZUColors.primary)
                }
            }

            Divider()

            if viewModel.candidateSkills.isEmpty {
                Text("Noch keine Skills angegeben.")
                    .foregroundStyle(ZAZUColors.textSecondary)
            } else {
                ForEach(
                    Array(viewModel.candidateSkills.enumerated()),
                    id: \.element.skillId
                ) { index, candidateSkill in

                    if let skill = viewModel.skills.first(
                        where: { $0.id == candidateSkill.skillId }
                    ) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(skill.name)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(ZAZUColors.textPrimary)

                                Text(skill.category)
                                    .font(.caption)
                                    .foregroundStyle(ZAZUColors.textSecondary)
                            }

                            Spacer()

                            Text(skillLevelText(candidateSkill.proficiency))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(ZAZUColors.primary)
                                .padding(.horizontal, ZAZUSpacing.small)
                                .padding(.vertical, 6)
                                .background(ZAZUColors.lightPurple)
                                .clipShape(Capsule())
                        }

                        if index < viewModel.candidateSkills.count - 1 {
                            Divider()
                        }
                    }
                }
            }
        }
        .padding(ZAZUSpacing.medium)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: ZAZURadius.large
            )
        )
    }
    
    
    // MARK: - EduView
    private var educationCard: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            HStack {
                Label(
                    "Ausbildung & Qualifikationen",
                    systemImage: "graduationcap.fill"
                )
                .font(.headline)
                .foregroundStyle(ZAZUColors.textPrimary)

                Spacer()

                NavigationLink {
                    EducationView(
                        viewModel: EducationViewModel(
                            educationRepository: educationRepository,
                            candidateProfileRepository: candidateProfileRepository,
                            candidateId: userId
                        ),
                        mode: .editing
                    )
                } label: {
                    Text("Bearbeiten")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(ZAZUColors.primary)
                }
            }

            Divider()

            if viewModel.educations.isEmpty {
                Text("Noch keine Ausbildung angegeben.")
                    .foregroundStyle(ZAZUColors.textSecondary)
            } else {
                ForEach(
                    Array(viewModel.educations.enumerated()),
                    id: \.element.id
                ) { index, education in
                    VStack(
                        alignment: .leading,
                        spacing: ZAZUSpacing.small
                    ) {
                        Text(education.degree)
                            .fontWeight(.semibold)
                            .foregroundStyle(ZAZUColors.textPrimary)

                        Text(education.institutionName)
                            .foregroundStyle(ZAZUColors.textSecondary)

                        if let fieldOfStudy = education.fieldOfStudy,
                           !fieldOfStudy.isEmpty {
                            Text(fieldOfStudy)
                                .font(.subheadline)
                                .foregroundStyle(ZAZUColors.textSecondary)
                        }

                        if education.isCurrent {
                            Text("Aktuelle Ausbildung")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(ZAZUColors.primary)
                        }
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )

                    if index < viewModel.educations.count - 1 {
                        Divider()
                    }
                }
            }
        }
        .padding(ZAZUSpacing.medium)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: ZAZURadius.large
            )
        )
    }
    
    // MARK: - LanguageView
    private var languagesCard: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            HStack {
                Label(
                    "Sprachen",
                    systemImage: "globe"
                )
                .font(.headline)
                .foregroundStyle(ZAZUColors.textPrimary)

                Spacer()

                NavigationLink {
                    LanguagesView(
                        viewModel: LanguagesViewModel(
                            languageRepository: languageRepository,
                            candidateProfileRepository: candidateProfileRepository,
                            candidateId: userId
                        ),
                        mode: .editing
                    )
                } label: {
                    Text("Bearbeiten")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(ZAZUColors.primary)
                }
            }

            Divider()

            if viewModel.candidateLanguages.isEmpty {
                Text("Noch keine Sprachen angegeben.")
                    .foregroundStyle(ZAZUColors.textSecondary)
            } else {
                ForEach(
                    Array(viewModel.candidateLanguages.enumerated()),
                    id: \.element.languageId
                ) { index, candidateLanguage in

                    if let language = viewModel.languages.first(
                        where: { $0.id == candidateLanguage.languageId }
                    ) {
                        HStack {
                            Text(language.name)
                                .fontWeight(.semibold)
                                .foregroundStyle(ZAZUColors.textPrimary)

                            Spacer()

                            Text(
                                languageLevelText(
                                    candidateLanguage.proficiency
                                )
                            )
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(ZAZUColors.primary)
                            .padding(.horizontal, ZAZUSpacing.small)
                            .padding(.vertical, 6)
                            .background(ZAZUColors.lightPurple)
                            .clipShape(Capsule())
                        }

                        if index < viewModel.candidateLanguages.count - 1 {
                            Divider()
                        }
                    }
                }
            }
        }
        .padding(ZAZUSpacing.medium)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: ZAZURadius.large
            )
        )
    }
    
    
    // MARK: - JobView
    private var jobPreferencesCard: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            HStack {
                Label(
                    "Jobpräferenzen",
                    systemImage: "target"
                )
                .font(.headline)
                .foregroundStyle(ZAZUColors.textPrimary)

                Spacer()

                NavigationLink {
                    JobPreferencesView(
                        viewModel: JobPreferencesViewModel(
                            repository: candidateProfileRepository,
                            userId: userId
                        ),
                        mode: .editing
                    )
                } label: {
                    Text("Bearbeiten")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(ZAZUColors.primary)
                }
            }

            Divider()

            profileRow(
                title: "Pensum",
                value: workloadText
            )

            profileRow(
                title: "Arbeitsort",
                value: viewModel.desiredWorkLocation
            )

            profileRow(
                title: "Umkreis",
                value: viewModel.workRadiusKm.map { "\($0) km" }
                    ?? "Nicht angegeben"
            )

            profileRow(
                title: "Pendeln",
                value: viewModel.willingToCommute ? "Ja" : "Nein"
            )

            profileRow(
                title: "Umzug möglich",
                value: viewModel.willingToRelocate ? "Ja" : "Nein"
            )

            profileRow(
                title: "Frühester Start",
                value: viewModel.earliestStartDate ?? "Nicht angegeben"
            )
        }
        .padding(ZAZUSpacing.medium)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(cornerRadius: ZAZURadius.large)
        )
    }
    // MARK: - SalaryView
    private var workAndSalaryCard: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            HStack {
                Label(
                    "Arbeitsmodell & Lohn",
                    systemImage: "building.2.fill"
                )
                .font(.headline)
                .foregroundStyle(ZAZUColors.textPrimary)

                Spacer()

                NavigationLink {
                    WorkAndSalaryView(
                        viewModel: WorkAndSalaryViewModel(
                            repository: candidateProfileRepository,
                            userId: userId
                        ),
                        mode: .editing
                    )
                } label: {
                    Text("Bearbeiten")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(ZAZUColors.primary)
                }
            }
            Divider()

            profileRow(
                title: "Arbeitsmodell",
                value: workModelText
            )

            profileRow(
                title: "Homeoffice",
                value: homeofficeText
            )

            if let days = viewModel.desiredHomeofficeDays {
                profileRow(
                    title: "Homeoffice-Tage",
                    value: "\(days) Tage / Woche"
                )
            }
            
            if let schedule = viewModel.preferredHomeofficeSchedule {
                profileRow(
                    title: "Homeoffice-Modell",
                    value: schedule.title
                )
            }

            profileRow(
                title: "Fully Remote",
                value: viewModel.acceptsFullyRemote ? "Ja" : "Nein"
            )

            profileRow(
                title: "Lohnvorstellung",
                value: salaryText
            )
        }
        .padding(ZAZUSpacing.medium)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(cornerRadius: ZAZURadius.large)
        )
    }
    
    
    // MARK: - PoC Tools

    private var pocToolsCard: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            Label(
                "PoC Tools",
                systemImage: "hammer.fill"
            )
            .font(.headline)
            .foregroundStyle(ZAZUColors.textPrimary)

            Divider()

            NavigationLink {
                PoCToolsView(

                    resetService: PoCResetService(
                        profileRepository: profileRepository,
                        candidateProfileRepository: candidateProfileRepository,
                        workExperienceRepository: workExperienceRepository,
                        skillRepository: skillRepository,
                        educationRepository: educationRepository,
                        languageRepository: languageRepository,
                        candidateJobInteractionRepository: candidateJobInteractionRepository,
                        matchRepository: matchRepository
                    ),
                    appState: appState,
                    userId: userId,
                    supabaseClient: supabaseClient,
                    accountSwitcher: accountSwitcher
                )
            } label: {
                HStack {
                    VStack(
                        alignment: .leading,
                        spacing: ZAZUSpacing.xSmall
                    ) {
                        Text("Testdaten & Reset")
                            .fontWeight(.semibold)
                            .foregroundStyle(ZAZUColors.textPrimary)

                        Text("Nur für die PoC-Entwicklung")
                            .font(.caption)
                            .foregroundStyle(ZAZUColors.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(ZAZUColors.textSecondary)
                }
            }
        }
        .padding(ZAZUSpacing.medium)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: ZAZURadius.large
            )
        )
    }

    // MARK: - Feedback

    @ViewBuilder
    private var feedback: some View {
        if let successMessage = viewModel.successMessage {
            Label(
                successMessage,
                systemImage: "checkmark.circle.fill"
            )
            .font(.subheadline)
            .foregroundStyle(.green)
        }

        if let errorMessage = viewModel.errorMessage {
            Label(
                errorMessage,
                systemImage: "exclamationmark.triangle.fill"
            )
            .font(.subheadline)
            .foregroundStyle(.red)
        }
    }
    
    // MARK: SignOut
    @MainActor
    private func signOut() async {
        guard !isSigningOut else {
            return
        }

        isSigningOut = true
        signOutError = nil

        defer {
            isSigningOut = false
        }

        do {
            try await authenticationService.signOut()
            appState.rootState = .authentication
        } catch {
            signOutError = error.localizedDescription
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        ProgressView()
            .tint(ZAZUColors.primary)
    }

    // MARK: - Helpers

    private var displayName: String {
        let name = [
            viewModel.firstName,
            viewModel.lastName
        ]
        .filter { !$0.isEmpty }
        .joined(separator: " ")

        return name.isEmpty
            ? "Dein Profil"
            : name
    }
    
    
    private func profileRow(
        title: String,
        value: String
    ) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .foregroundStyle(ZAZUColors.textSecondary)

            Spacer()

            Text(value.isEmpty ? "Nicht angegeben" : value)
                .fontWeight(.medium)
                .foregroundStyle(ZAZUColors.textPrimary)
                .multilineTextAlignment(.trailing)
        }
    }
    
    
    private func skillLevelText(
        _ proficiency: SkillProficiency
    ) -> String {
        switch proficiency {
        case .basic:
            return "Grundkenntnisse"
        case .good:
            return "Gut"
        case .veryGood:
            return "Sehr gut"
        case .expert:
            return "Experte"
        }
    }
    
    @MainActor
    private func loadAccountEmail() async {
        do {
            accountEmail = try await authenticationService.currentUserEmail() ?? ""
        } catch {
            accountEmail = ""
        }
    }
    
    private func languageLevelText(
        _ proficiency: LanguageProficiency
    ) -> String {
        switch proficiency {
        case .a1:
            return "A1"
        case .a2:
            return "A2"
        case .b1:
            return "B1"
        case .b2:
            return "B2"
        case .c1:
            return "C1"
        case .c2:
            return "C2"
        case .native:
            return "Muttersprache"
        }
    }
    
    
    private var workloadText: String {
        guard
            let min = viewModel.desiredWorkloadMin,
            let max = viewModel.desiredWorkloadMax
        else {
            return "Nicht angegeben"
        }

        return min == max
            ? "\(min) %"
            : "\(min)–\(max) %"
    }

    private var salaryText: String {
        guard
            let min = viewModel.salaryMin,
            let max = viewModel.salaryMax
        else {
            return "Nicht angegeben"
        }

        return "CHF \(min.formatted()) – \(max.formatted()) / Jahr"
    }

    private var workModelText: String {

        viewModel.preferredWorkModel?.title ?? "Nicht angegeben"

    }

    private var homeofficeText: String {
        viewModel.homeofficePreference?.title ?? "Nicht angegeben"
    }
}
