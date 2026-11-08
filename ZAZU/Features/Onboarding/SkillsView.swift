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
    
    @State private var isCategorySheetPresented = false
    @State private var categorySearchText = ""
    
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
                }            }
            .padding(ZAZUSpacing.large)
        }
        .background(ZAZUColors.veryLightPurple)
        .task {
            await viewModel.load()
        }
        .sheet(item: $skillToConfigure) { skill in
            proficiencySheet(for: skill)
        }
        .sheet(
            isPresented: $isCategorySheetPresented,
            onDismiss: {
                viewModel.scheduleSearch()
            }
        ) {
            categorySelectionSheet
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
       

                Spacer()

                Text("4 von 8")
                    .font(.subheadline)
                    .foregroundStyle(ZAZUColors.textSecondary)
            }

            ProgressView(value: 4, total: 8)
                .tint(ZAZUColors.primary)
        }
    }
    
    
    // MARK: - Search Hint

    private var searchHint: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            Label(
                "Fähigkeiten entdecken",
                systemImage: "magnifyingglass"
            )
            .font(.headline)
            .foregroundStyle(ZAZUColors.textPrimary)

            Text(
                "Gib mindestens zwei Buchstaben ein, um nach Fähigkeiten, Fachwissen oder Systemkenntnissen zu suchen."
            )
            .font(.subheadline)
            .foregroundStyle(ZAZUColors.textSecondary)

            Text(
                "Du kannst mehrere Skills auswählen und jeweils dein Kenntnisniveau angeben."
            )
            .font(.caption)
            .foregroundStyle(ZAZUColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(ZAZUSpacing.medium)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: ZAZURadius.medium
            )
        )
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
            .onChange(of: viewModel.searchText) { _, _ in
                viewModel.scheduleSearch()
            }

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
        Button {
            categorySearchText = ""
            isCategorySheetPresented = true
        } label: {
            HStack(spacing: ZAZUSpacing.medium) {
                Image(systemName: "line.3.horizontal.decrease")

                VStack(alignment: .leading, spacing: ZAZUSpacing.xSmall) {
                    Text("Berufsgruppen wählen")
                        .fontWeight(.semibold)

                    Text(
                        viewModel.selectedCategoryIDs.isEmpty
                            ? "Alle Berufsgruppen"
                            : "\(viewModel.selectedCategoryIDs.count) ausgewählt"
                    )
                    .font(.caption)
                    .foregroundStyle(ZAZUColors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
            }
            .foregroundStyle(ZAZUColors.textPrimary)
            .padding(ZAZUSpacing.medium)
            .background(ZAZUColors.white)
            .clipShape(
                RoundedRectangle(cornerRadius: ZAZURadius.medium)
            )
        }
        .buttonStyle(.plain)
    }
    
    
    private var categorySelectionSheet: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        viewModel.selectedCategoryIDs.removeAll()
                    } label: {
                        HStack {
                            Text("Alle Berufsgruppen")

                            Spacer()

                            if viewModel.selectedCategoryIDs.isEmpty {
                                Image(systemName: "checkmark")
                            }
                        }
                        .foregroundStyle(ZAZUColors.primary)
                    }
                } footer: {
                    Text("Mehrere Berufsgruppen sind auswählbar.")
                }
                
                
                if let message = viewModel.categorySaveErrorMessage {
                    Section {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }

                Section("Berufsgruppen") {
                    ForEach(viewModel.skillCategories.filter { category in
                        let query = categorySearchText
                            .trimmingCharacters(in: .whitespacesAndNewlines)

                        return query.isEmpty
                            || category.name.localizedStandardContains(query)
                    }) { category in
                        Button {
                            if viewModel.selectedCategoryIDs.contains(category.id) {
                                viewModel.selectedCategoryIDs.remove(category.id)
                            } else {
                                viewModel.selectedCategoryIDs.insert(category.id)
                            }
                        } label: {
                            HStack {
                                Text(category.name)

                                Spacer()

                                Image(
                                    systemName:
                                        viewModel.selectedCategoryIDs.contains(category.id)
                                        ? "checkmark.circle.fill"
                                        : "circle"
                                )
                                .foregroundStyle(ZAZUColors.primary)
                            }
                            .foregroundStyle(ZAZUColors.textPrimary)
                        }
                    }
                }
            }
            .disabled(viewModel.isSavingCategories)
            .searchable(
                text: $categorySearchText,
                prompt: "Berufsgruppe suchen"
            )
            .navigationTitle("Berufsgruppen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            let didSave =
                                await viewModel.saveCategorySelection()

                            if didSave {
                                isCategorySheetPresented = false
                            }
                        }
                    } label: {
                        if viewModel.isSavingCategories {
                            ProgressView()
                        } else {
                            Text("Fertig")
                        }
                    }
                    .disabled(viewModel.isSavingCategories)
                }
            }
        }
        .presentationDetents([.large])
        .interactiveDismissDisabled()
    }

    private func categoryButton(
        title: String,
        categoryID: UUID?
    ) -> some View {
        let isSelected = categoryID.map {
            viewModel.selectedCategoryIDs.contains($0)
        } ?? viewModel.selectedCategoryIDs.isEmpty

        return Button {
            if let categoryID {
                if viewModel.selectedCategoryIDs.contains(categoryID) {
                    viewModel.selectedCategoryIDs.remove(categoryID)
                } else {
                    viewModel.selectedCategoryIDs.insert(categoryID)
                }
            } else {
                viewModel.selectedCategoryIDs.removeAll()
            }

            viewModel.scheduleSearch()
        } label: {
            HStack(spacing: ZAZUSpacing.xSmall) {
                if isSelected {
                    Image(systemName: "checkmark")
                }

                Text(title)
            }
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
        LazyVStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            Text("Skills & Systeme")
                .font(.headline)
                .foregroundStyle(ZAZUColors.textPrimary)

            if viewModel.isSearching && viewModel.skills.isEmpty {
                ProgressView("Skills werden geladen …")
                    .tint(ZAZUColors.primary)
                    .padding(.vertical, ZAZUSpacing.medium)

            } else {
                if viewModel.filteredSkills.isEmpty {
                    Text(
                        viewModel.hasMoreSkills
                            ? "In diesem Abschnitt sind keine weiteren auswählbaren Skills."
                            : "Keine weiteren passenden Skills gefunden."
                    )
                    .foregroundStyle(ZAZUColors.textSecondary)
                    .padding(.vertical, ZAZUSpacing.medium)
                }

                ForEach(viewModel.filteredSkills) { skill in
                    skillRow(skill)
                }

                if viewModel.hasMoreSkills {
                    if viewModel.errorMessage == nil {
                        ProgressView("Weitere Skills laden …")
                            .tint(ZAZUColors.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, ZAZUSpacing.medium)
                            .task(id: viewModel.skills.count) {
                                await viewModel.loadMoreSkills()
                            }
                    } else {
                        Button("Erneut laden") {
                            Task {
                                await viewModel.loadMoreSkills()
                            }
                        }
                        .disabled(viewModel.isSearching)
                    }
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
