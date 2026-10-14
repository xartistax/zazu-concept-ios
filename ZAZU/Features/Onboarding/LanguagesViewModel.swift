//
//  LanguagesViewModel.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class LanguagesViewModel {

    var languages: [Language] = []
    var candidateLanguages: [CandidateLanguage] = []

    var searchText = ""

    var isLoading = false
    var isSaving = false
    var errorMessage: String?

    private let languageRepository: LanguageRepository
    private let candidateProfileRepository: CandidateProfileRepository
    private let candidateId: UUID

    init(
        languageRepository: LanguageRepository,
        candidateProfileRepository: CandidateProfileRepository,
        candidateId: UUID
    ) {
        self.languageRepository = languageRepository
        self.candidateProfileRepository = candidateProfileRepository
        self.candidateId = candidateId
    }

    // MARK: - Derived Data

    var filteredLanguages: [Language] {
        let query = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !query.isEmpty else {
            return languages
        }

        return languages.filter {
            $0.name.localizedCaseInsensitiveContains(query)
        }
    }

    var selectedLanguages: [Language] {
        languages.filter { language in
            candidateLanguages.contains {
                $0.languageId == language.id
            }
        }
    }

    func proficiency(
        for language: Language
    ) -> LanguageProficiency? {
        candidateLanguages.first {
            $0.languageId == language.id
        }?.proficiency
    }

    func isSelected(
        _ language: Language
    ) -> Bool {
        proficiency(for: language) != nil
    }

    // MARK: - Loading

    func load() async {
        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            async let languagesRequest =
                languageRepository.fetchLanguages()

            async let candidateLanguagesRequest =
                languageRepository.fetchCandidateLanguages(
                    candidateId: candidateId
                )

            let (
                loadedLanguages,
                loadedCandidateLanguages
            ) = try await (
                languagesRequest,
                candidateLanguagesRequest
            )

            languages = loadedLanguages
            candidateLanguages = loadedCandidateLanguages

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Save

    func save(
        language: Language,
        proficiency: LanguageProficiency
    ) async {
        guard !isSaving else {
            return
        }

        isSaving = true
        errorMessage = nil

        defer {
            isSaving = false
        }

        do {
            try await languageRepository.saveCandidateLanguage(
                candidateId: candidateId,
                languageId: language.id,
                proficiency: proficiency
            )

            await reloadCandidateLanguages()

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Remove

    func remove(
        language: Language
    ) async {
        guard !isSaving else {
            return
        }

        isSaving = true
        errorMessage = nil

        defer {
            isSaving = false
        }

        do {
            try await languageRepository.deleteCandidateLanguage(
                candidateId: candidateId,
                languageId: language.id
            )

            candidateLanguages.removeAll {
                $0.languageId == language.id
            }

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Onboarding

    func completeStep() async -> Bool {
        guard !candidateLanguages.isEmpty else {
            errorMessage =
                "Wähle mindestens eine Sprache und dein Sprachniveau aus."
            return false
        }

        errorMessage = nil

        do {
            try await candidateProfileRepository.updateOnboardingStep(
                userId: candidateId,
                step: 5
            )

            return true

        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Reload

    private func reloadCandidateLanguages() async {
        do {
            candidateLanguages =
                try await languageRepository.fetchCandidateLanguages(
                    candidateId: candidateId
                )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
