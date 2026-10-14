//
//  EmployerLanguageRequirementsViewModel.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 08.10.2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class EmployerLanguageRequirementsViewModel {
    var languages: [Language] = []
    var searchText = ""
    var isLoading = false
    var errorMessage: String?

    private let languageRepository: LanguageRepository

    init(languageRepository: LanguageRepository) {
        self.languageRepository = languageRepository
    }

    var filteredLanguages: [Language] {
        guard !searchText.isEmpty else {
            return languages
        }

        return languages.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    func loadLanguages() async {
        guard languages.isEmpty else {
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            languages = try await languageRepository.fetchLanguages()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
