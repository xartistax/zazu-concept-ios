//
//  LanguagesView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import SwiftUI

struct LanguagesView: View {
    @State private var viewModel: LanguagesViewModel
    @State private var languageToConfigure: Language?
    
    enum Mode {
        case onboarding
        case editing
    }

    private let mode: Mode

    let onContinue: () -> Void

    init(
        viewModel: LanguagesViewModel,
        mode: Mode = .onboarding,
        onContinue: @escaping () -> Void = {}
    ) {
        _viewModel = State(initialValue: viewModel)
        self.mode = mode
        self.onContinue = onContinue
    }

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.large
            ) {
                if mode == .onboarding {
                    progressHeader
                }

                title

                if viewModel.isLoading {
                    loadingView
                } else {
                    searchField
                    selectedLanguages
                    languageList
                    errorMessage

                    if mode == .onboarding {
                        continueButton
                    }
                }
            }
            .padding(ZAZUSpacing.large)
        }
        .background(ZAZUColors.veryLightPurple)
        .task {
            await viewModel.load()
        }
        .sheet(item: $languageToConfigure) { language in
            proficiencySheet(for: language)
        }
    }

    // MARK: - Header

    private var progressHeader: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            HStack {
                Text(
                    mode == .onboarding
                        ? "Wähle deine Sprachen und das jeweilige Sprachniveau aus."
                        : "Verwalte deine Sprachen und passe deine Sprachniveaus an."
                )
                .foregroundStyle(ZAZUColors.textSecondary)

                Spacer()

                Text("5 von 8")
                    .font(.subheadline)
                    .foregroundStyle(ZAZUColors.textSecondary)
            }

            ProgressView(value: 5, total: 8)
                .tint(ZAZUColors.primary)
        }
    }

    private var title: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            Text("Sprachen")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(ZAZUColors.textPrimary)

            Text(
                "Wähle deine Sprachen und das jeweilige Sprachniveau aus."
            )
            .foregroundStyle(ZAZUColors.textSecondary)
        }
    }

    // MARK: - Search

    private var searchField: some View {
        HStack(spacing: ZAZUSpacing.small) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(ZAZUColors.textSecondary)

            TextField(
                "Sprache suchen",
                text: $viewModel.searchText
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        }
        .padding(ZAZUSpacing.medium)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(cornerRadius: ZAZURadius.medium)
        )
    }

    // MARK: - Selected

    @ViewBuilder
    private var selectedLanguages: some View {
        if !viewModel.selectedLanguages.isEmpty {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.medium
            ) {
                Text("Deine Sprachen")
                    .font(.headline)
                    .foregroundStyle(ZAZUColors.textPrimary)

                ForEach(viewModel.selectedLanguages) { language in
                    selectedLanguageCard(language)
                }
            }
        }
    }

    private func selectedLanguageCard(
        _ language: Language
    ) -> some View {
        HStack(spacing: ZAZUSpacing.medium) {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.xSmall
            ) {
                Text(language.name)
                    .font(.headline)
                    .foregroundStyle(ZAZUColors.textPrimary)

                if let proficiency =
                    viewModel.proficiency(for: language) {
                    Text(proficiency.title)
                        .font(.subheadline)
                        .foregroundStyle(ZAZUColors.primary)
                }
            }

            Spacer()

            Button {
                languageToConfigure = language
            } label: {
                Image(systemName: "pencil")
                    .foregroundStyle(ZAZUColors.primary)
            }
            .buttonStyle(.plain)

            Button {
                Task {
                    await viewModel.remove(language: language)
                }
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(ZAZUSpacing.medium)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(cornerRadius: ZAZURadius.medium)
        )
    }

    // MARK: - Languages

    private var languageList: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            Text("Sprachen auswählen")
                .font(.headline)
                .foregroundStyle(ZAZUColors.textPrimary)

            ForEach(viewModel.filteredLanguages) { language in
                languageRow(language)
            }
        }
    }

    private func languageRow(
        _ language: Language
    ) -> some View {
        Button {
            languageToConfigure = language
        } label: {
            HStack(spacing: ZAZUSpacing.medium) {
                VStack(
                    alignment: .leading,
                    spacing: ZAZUSpacing.xSmall
                ) {
                    Text(language.name)
                        .foregroundStyle(ZAZUColors.textPrimary)

                    if let proficiency =
                        viewModel.proficiency(for: language) {
                        Text(proficiency.title)
                            .font(.caption)
                            .foregroundStyle(ZAZUColors.primary)
                    }
                }

                Spacer()

                Image(
                    systemName: viewModel.isSelected(language)
                        ? "checkmark.circle.fill"
                        : "plus.circle"
                )
                .foregroundStyle(ZAZUColors.primary)
            }
            .padding(ZAZUSpacing.medium)
            .background(ZAZUColors.white)
            .clipShape(
                RoundedRectangle(cornerRadius: ZAZURadius.medium)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Proficiency

    private func proficiencySheet(
        for language: Language
    ) -> some View {
        NavigationStack {
            ScrollView {
                VStack(
                    alignment: .leading,
                    spacing: ZAZUSpacing.medium
                ) {
                    Text(language.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(ZAZUColors.textPrimary)

                    Text("Wie gut beherrschst du diese Sprache?")
                        .foregroundStyle(ZAZUColors.textSecondary)

                    ForEach(
                        LanguageProficiency.allCases,
                        id: \.self
                    ) { proficiency in
                        proficiencyButton(
                            proficiency,
                            language: language
                        )
                    }
                }
                .padding(ZAZUSpacing.large)
            }
            .background(ZAZUColors.veryLightPurple)
            .navigationTitle("Sprachniveau")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .topBarTrailing
                ) {
                    Button("Schliessen") {
                        languageToConfigure = nil
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func proficiencyButton(
        _ proficiency: LanguageProficiency,
        language: Language
    ) -> some View {
        let isSelected =
            viewModel.proficiency(for: language) == proficiency

        return Button {
            Task {
                await viewModel.save(
                    language: language,
                    proficiency: proficiency
                )

                if viewModel.errorMessage == nil {
                    languageToConfigure = nil
                }
            }
        } label: {
            HStack {
                Text(proficiency.title)
                    .foregroundStyle(ZAZUColors.textPrimary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(ZAZUColors.primary)
                }
            }
            .padding(ZAZUSpacing.medium)
            .background(
                isSelected
                    ? ZAZUColors.lightPurple
                    : ZAZUColors.white
            )
            .clipShape(
                RoundedRectangle(cornerRadius: ZAZURadius.medium)
            )
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isSaving)
    }

    // MARK: - Continue

    private var continueButton: some View {
        Button {
            Task {
                let didComplete = await viewModel.completeStep()

                if didComplete {
                    onContinue()
                }
            }
        } label: {
            Text("Weiter")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .background(ZAZUColors.primary)
        .clipShape(
            RoundedRectangle(cornerRadius: ZAZURadius.medium)
        )
        .disabled(viewModel.candidateLanguages.isEmpty)
        .opacity(
            viewModel.candidateLanguages.isEmpty
                ? 0.5
                : 1
        )
    }

    // MARK: - States

    private var loadingView: some View {
        ProgressView()
            .tint(ZAZUColors.primary)
            .frame(maxWidth: .infinity)
            .padding(ZAZUSpacing.xLarge)
    }

    @ViewBuilder
    private var errorMessage: some View {
        if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .font(.footnote)
                .foregroundStyle(.red)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
        }
    }
}
