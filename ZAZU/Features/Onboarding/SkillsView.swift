//
//  SkillsView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import SwiftUI

struct SkillsView: View {
    @State private var viewModel: SkillsViewModel
    @State private var skillToConfigure: Skill?
    
    @State private var isCustomSkillSheetPresented = false
    @State private var customSkillName = ""
    @State private var customSkillProficiency: SkillProficiency?
    
    enum Mode {
        case onboarding
        case editing
    }

    private let mode: Mode

    let onContinue: () -> Void

    init(
        viewModel: SkillsViewModel,
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
                searchField
                categoryFilter

                if viewModel.isLoading {
                    loadingView
                } else {
                    selectedSkillsSection
                    availableSkillsSection
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
        .sheet(item: $skillToConfigure) { skill in
            proficiencySheet(for: skill)
        }
        .sheet(isPresented: $isCustomSkillSheetPresented) {
            customSkillSheet
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
                        ? "Wähle deine relevanten Kenntnisse aus und gib dein Niveau an."
                        : "Verwalte deine Skills und passe deine Kenntnisstufen an."
                )
                .foregroundStyle(ZAZUColors.textSecondary)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(ZAZUColors.primary)

                Spacer()

                Text("3 von 8")
                    .font(.subheadline)
                    .foregroundStyle(ZAZUColors.textSecondary)
            }

            ProgressView(value: 3, total: 8)
                .tint(ZAZUColors.primary)
        }
    }

    private var title: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            Text("Skills & Systemkenntnisse")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(ZAZUColors.textPrimary)

            Text(
                "Wähle deine relevanten Kenntnisse aus und gib dein Niveau an."
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
                "Skill oder System suchen",
                text: $viewModel.searchText
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(ZAZUColors.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(ZAZUSpacing.medium)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(cornerRadius: ZAZURadius.medium)
        )
    }
    
    // MARK: - Categories

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: ZAZUSpacing.small) {
                categoryButton(
                    title: "Alle",
                    category: nil
                )

                ForEach(
                    viewModel.categories,
                    id: \.self
                ) { category in
                    categoryButton(
                        title: category,
                        category: category
                    )
                }
            }
        }
    }

    private func categoryButton(
        title: String,
        category: String?
    ) -> some View {
        let isSelected =
            viewModel.selectedCategory == category

        return Button {
            viewModel.selectedCategory = category
        } label: {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(
                    isSelected
                        ? ZAZUColors.white
                        : ZAZUColors.textPrimary
                )
                .padding(.horizontal, ZAZUSpacing.medium)
                .padding(.vertical, ZAZUSpacing.small)
                .background(
                    isSelected
                        ? ZAZUColors.primary
                        : ZAZUColors.white
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Selected Skills

    @ViewBuilder
    private var selectedSkillsSection: some View {
        if !viewModel.selectedSkills.isEmpty ||
            !viewModel.candidateCustomSkills.isEmpty {

            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.medium
            ) {
                Text("Ausgewählt")
                    .font(.headline)
                    .foregroundStyle(ZAZUColors.textPrimary)

                ForEach(viewModel.selectedSkills) { skill in
                    selectedSkillCard(skill)
                }

                ForEach(viewModel.candidateCustomSkills) { skill in
                    customSkillCard(skill)
                }
            }
        }
    }
    
    
    private func customSkillCard(
        _ skill: CandidateCustomSkill
    ) -> some View {
        HStack(spacing: ZAZUSpacing.medium) {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.xSmall
            ) {
                Text(skill.name)
                    .font(.headline)
                    .foregroundStyle(ZAZUColors.textPrimary)

                Text(skill.proficiency.title)
                    .font(.subheadline)
                    .foregroundStyle(ZAZUColors.primary)

                Text("Andere / nicht aufgeführt")
                    .font(.caption)
                    .foregroundStyle(ZAZUColors.textSecondary)
            }

            Spacer()

            Button {
                Task {
                    await viewModel.removeCustomSkill(skill)
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
            RoundedRectangle(
                cornerRadius: ZAZURadius.medium
            )
        )
    }
    
    
    private func selectedSkillCard(
        _ skill: Skill
    ) -> some View {
        HStack(spacing: ZAZUSpacing.medium) {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.xSmall
            ) {
                Text(skill.name)
                    .font(.headline)
                    .foregroundStyle(ZAZUColors.textPrimary)

                if let proficiency = viewModel.proficiency(for: skill) {
                    Text(proficiency.title)
                        .font(.subheadline)
                        .foregroundStyle(ZAZUColors.primary)
                }
            }

            Spacer()

            Button {
                skillToConfigure = skill
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .foregroundStyle(ZAZUColors.primary)
            }
            .buttonStyle(.plain)

            Button {
                Task {
                    await viewModel.remove(skill: skill)
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

    // MARK: - Available Skills

    private var availableSkillsSection: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            Text("Skills & Systeme")
                .font(.headline)
                .foregroundStyle(ZAZUColors.textPrimary)

            if viewModel.filteredSkills.isEmpty {
                Text("Keine passenden Skills gefunden.")
                    .foregroundStyle(ZAZUColors.textSecondary)
                    .padding(.vertical, ZAZUSpacing.medium)
            } else {
                ForEach(viewModel.filteredSkills) { skill in
                    skillRow(skill)
                }
                
                
                
            }
            
            Button {
                customSkillName = viewModel.searchText
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                customSkillProficiency = nil
                isCustomSkillSheetPresented = true
            } label: {
                HStack(spacing: ZAZUSpacing.medium) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(ZAZUColors.primary)
                        .font(.title3)

                    VStack(
                        alignment: .leading,
                        spacing: ZAZUSpacing.xSmall
                    ) {
                        Text("Andere / nicht aufgeführt")
                            .fontWeight(.semibold)
                            .foregroundStyle(ZAZUColors.textPrimary)

                        Text("Eigenen Skill oder Systemkenntnis hinzufügen")
                            .font(.caption)
                            .foregroundStyle(ZAZUColors.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(ZAZUColors.textSecondary)
                }
                .padding(ZAZUSpacing.medium)
                .background(ZAZUColors.white)
                .clipShape(
                    RoundedRectangle(cornerRadius: ZAZURadius.medium)
                )
            }
            .buttonStyle(.plain)
            
            
        }
    }

    private func skillRow(
        _ skill: Skill
    ) -> some View {
        Button {
            skillToConfigure = skill
        } label: {
            HStack(spacing: ZAZUSpacing.medium) {
                VStack(
                    alignment: .leading,
                    spacing: ZAZUSpacing.xSmall
                ) {
                    Text(skill.name)
                        .fontWeight(.semibold)
                        .foregroundStyle(ZAZUColors.textPrimary)

                    Text(skill.category)
                        .font(.caption)
                        .foregroundStyle(ZAZUColors.textSecondary)
                }

                Spacer()

                if let proficiency = viewModel.proficiency(for: skill) {
                    Text(proficiency.title)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(ZAZUColors.primary)
                } else {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(ZAZUColors.primary)
                        .font(.title3)
                }
            }
            .padding(ZAZUSpacing.medium)
            .background(
                viewModel.isSelected(skill)
                    ? ZAZUColors.lightPurple
                    : ZAZUColors.white
            )
            .clipShape(
                RoundedRectangle(cornerRadius: ZAZURadius.medium)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Proficiency

    private func proficiencySheet(
        for skill: Skill
    ) -> some View {
        NavigationStack {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.large
            ) {
                VStack(
                    alignment: .leading,
                    spacing: ZAZUSpacing.small
                ) {
                    Text(skill.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Wie gut kennst du diesen Skill?")
                        .foregroundStyle(ZAZUColors.textSecondary)
                }

                ForEach(
                    SkillProficiency.allCases,
                    id: \.self
                ) { proficiency in
                    proficiencyButton(
                        skill: skill,
                        proficiency: proficiency
                    )
                }

                Spacer()
            }
            .padding(ZAZUSpacing.large)
            .background(ZAZUColors.veryLightPurple)
            .navigationTitle("Kenntnisstufe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .topBarTrailing
                ) {
                    Button("Schliessen") {
                        skillToConfigure = nil
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    
    
    // MARK: - Custom Skill

    private var customSkillSheet: some View {
        NavigationStack {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.large
            ) {
                VStack(
                    alignment: .leading,
                    spacing: ZAZUSpacing.small
                ) {
                    Text("Andere / nicht aufgeführt")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Füge einen Skill oder eine Systemkenntnis hinzu.")
                        .foregroundStyle(ZAZUColors.textSecondary)
                }

                TextField(
                    "z. B. Branchensoftware XYZ",
                    text: $customSkillName
                )
                .padding(ZAZUSpacing.medium)
                .background(ZAZUColors.white)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: ZAZURadius.medium
                    )
                )

                Text("Kenntnisstufe")
                    .font(.headline)
                    .foregroundStyle(ZAZUColors.textPrimary)

                ForEach(
                    SkillProficiency.allCases,
                    id: \.self
                ) { proficiency in
                    customProficiencyButton(proficiency)
                }

                Spacer()

                Button {
                    guard let proficiency = customSkillProficiency else {
                        return
                    }

                    Task {
                        let didSave = await viewModel.saveCustomSkill(
                            name: customSkillName,
                            proficiency: proficiency
                        )

                        if didSave {
                            customSkillName = ""
                            customSkillProficiency = nil
                            isCustomSkillSheetPresented = false
                        }
                    }
                } label: {
                    Text("Hinzufügen")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(
                    canSaveCustomSkill
                        ? ZAZUColors.primary
                        : ZAZUColors.textSecondary.opacity(0.4)
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: ZAZURadius.medium
                    )
                )
                .disabled(!canSaveCustomSkill || viewModel.isSaving)
            }
            .padding(ZAZUSpacing.large)
            .background(ZAZUColors.veryLightPurple)
            .navigationTitle("Eigener Skill")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Schliessen") {
                        isCustomSkillSheetPresented = false
                    }
                }
            }
        }
    }

    private var canSaveCustomSkill: Bool {
        !customSkillName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty &&
        customSkillProficiency != nil
    }

    private func customProficiencyButton(
        _ proficiency: SkillProficiency
    ) -> some View {
        let isSelected =
            customSkillProficiency == proficiency

        return Button {
            customSkillProficiency = proficiency
        } label: {
            HStack {
                Text(proficiency.title)
                    .fontWeight(.semibold)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                }
            }
            .foregroundStyle(
                isSelected
                    ? ZAZUColors.white
                    : ZAZUColors.textPrimary
            )
            .padding(ZAZUSpacing.medium)
            .background(
                isSelected
                    ? ZAZUColors.primary
                    : ZAZUColors.white
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: ZAZURadius.medium
                )
            )
        }
        .buttonStyle(.plain)
    }

    private func proficiencyButton(
        skill: Skill,
        proficiency: SkillProficiency
    ) -> some View {
        let isSelected =
            viewModel.proficiency(for: skill) == proficiency

        return Button {
            Task {
                await viewModel.save(
                    skill: skill,
                    proficiency: proficiency
                )

                if viewModel.errorMessage == nil {
                    skillToConfigure = nil
                }
            }
        } label: {
            HStack {
                Text(proficiency.title)
                    .fontWeight(.semibold)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                }
            }
            .foregroundStyle(
                isSelected
                    ? ZAZUColors.white
                    : ZAZUColors.textPrimary
            )
            .padding(ZAZUSpacing.medium)
            .background(
                isSelected
                    ? ZAZUColors.primary
                    : ZAZUColors.white
            )
            .clipShape(
                RoundedRectangle(cornerRadius: ZAZURadius.medium)
            )
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isSaving)
    }

    // MARK: - State

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
                .frame(maxWidth: .infinity, alignment: .leading)
        }
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
        .background(
            viewModel.candidateSkills.isEmpty &&
            viewModel.candidateCustomSkills.isEmpty
                ? ZAZUColors.textSecondary.opacity(0.4)
                : ZAZUColors.primary
        )
        .clipShape(
            RoundedRectangle(cornerRadius: ZAZURadius.medium)
        )
        .disabled(viewModel.candidateSkills.isEmpty &&
                  viewModel.candidateCustomSkills.isEmpty)
    }
}
