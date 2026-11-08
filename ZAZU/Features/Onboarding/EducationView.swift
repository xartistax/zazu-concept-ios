//
//  EducationView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import SwiftUI

struct EducationView: View {

    @State private var viewModel: EducationViewModel
    

    enum Mode {
        case onboarding
        case editing
    }

    private let mode: Mode
    let onContinue: () -> Void

    init(
        viewModel: EducationViewModel,
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
                    educationList

                    if mode == .onboarding {
                        Toggle(
                            "Ich habe keinen formalen Bildungsabschluss",
                            isOn: $viewModel.hasNoFormalQualification
                        )
                        .tint(ZAZUColors.primary)
                        .disabled(!viewModel.educations.isEmpty)
                    }

                    if mode == .editing || !viewModel.hasNoFormalQualification {
                        form
                    }

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
    }

    // MARK: - Header

    private var progressHeader: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            HStack {
                Text(
                    "Füge relevante Ausbildungen und Qualifikationen zu deinem Profil hinzu."
                )
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(ZAZUColors.primary)

                Spacer()

                Text("2 von 8")
                    .font(.subheadline)
                    .foregroundStyle(ZAZUColors.textSecondary)
            }

            ProgressView(value: 2, total: 8)
                .tint(ZAZUColors.primary)
        }
    }

    private var title: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            Text("Ausbildung & Qualifikationen")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(ZAZUColors.textPrimary)

            Text(
                mode == .onboarding
                    ? "Füge relevante Ausbildungen und Qualifikationen zu deinem Profil hinzu."
                    : "Verwalte deine Ausbildungen und Qualifikationen."
            )
            .foregroundStyle(ZAZUColors.textSecondary)
        }
    }

    // MARK: - Existing Educations

    @ViewBuilder
    private var educationList: some View {
        if !viewModel.educations.isEmpty {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.medium
            ) {
                Text("Deine Einträge")
                    .font(.headline)
                    .foregroundStyle(ZAZUColors.textPrimary)

                ForEach(viewModel.educations) { education in
                    educationCard(education)
                }
            }
        }
    }

    private func educationCard(
        _ education: Education
    ) -> some View {
        HStack(
            alignment: .top,
            spacing: ZAZUSpacing.medium
        ) {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.xSmall
            ) {
                
                if let qualification = education.qualification {
                    Text(qualification.name)
                        .font(.subheadline)
                        .foregroundStyle(ZAZUColors.primary)
                }

                Text(education.institutionName)
                    .foregroundStyle(ZAZUColors.textSecondary)

                if let field = education.fieldOfStudy,
                   !field.isEmpty {
                    Text(field)
                        .font(.subheadline)
                        .foregroundStyle(ZAZUColors.textSecondary)
                }

                Text(dateDescription(for: education))
                    .font(.caption)
                    .foregroundStyle(ZAZUColors.textSecondary)

                if education.isCurrent {
                    Text("Aktuell")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(ZAZUColors.primary)
                }
            }

            Spacer()

            Button {
                Task {
                    await viewModel.deleteEducation(education)
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

    // MARK: - Form

    private var form: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            Text("Eintrag hinzufügen")
                .font(.headline)
                .foregroundStyle(ZAZUColors.textPrimary)

            educationCatalogSelection

            startDateSection

            Picker(
                "Ausbildungsstatus",
                selection: $viewModel.completionStatus
            ) {
                Text("Abgeschlossen").tag("completed")
                Text("In Ausbildung").tag("in_progress")
                Text("Nicht abgeschlossen").tag("not_completed")
            }
            .pickerStyle(.segmented)
            .onChange(
                of: viewModel.completionStatus
            ) { _, newValue in
                viewModel.isCurrent = newValue == "in_progress"
            }

            if !viewModel.isCurrent {
                endDateSection
            }

            descriptionSection

            addButton
        }
        .padding(ZAZUSpacing.medium)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(cornerRadius: ZAZURadius.large)
        )
    }

    // MARK: - Education Catalog

    private var educationCatalogSelection: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            if viewModel.isLoadingCatalog {
                ProgressView("Ausbildungskatalog laden …")
                    .tint(ZAZUColors.primary)
            }

            if let error = viewModel.catalogErrorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            educationTypeSelection

            if viewModel.selectedEducationType != nil {
                educationDegreeSelection
            }

            if viewModel.selectedEducationTypeDegree != nil {
                educationFieldSelection
            }

            if viewModel.selectedEducationType != nil {
                institutionSelection
            }

            if viewModel.selectedEducationTypeDegree != nil {
                qualificationSelection
            }
        }
        .task(id: viewModel.qualificationContextID) {
            await viewModel.loadQualificationOptions()
        }
    }

    // MARK: - Education Type

    private var educationTypeSelection: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            fieldLabel("Ausbildungsart")

            ZAZUDropdownField(
                "Ausbildungsart",
                selection: Binding<UUID?>(
                    get: {
                        viewModel.selectedEducationType?.id
                    },
                    set: { newId in
                        guard let type = viewModel.educationTypes.first(
                            where: { $0.id == newId }
                        ) else {
                            return
                        }

                        Task {
                            await viewModel.selectEducationType(type)
                        }
                    }
                )
            ) {
                Text("Bitte auswählen")
                    .tag(nil as UUID?)

                ForEach(viewModel.educationTypes) { type in
                    Text(type.nameDe)
                        .tag(Optional(type.id))
                }
            }
        }
    }
    
    private var qualificationSelection: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            fieldLabel("Offizieller Abschlusstitel (optional)")

            if viewModel.isLoadingQualifications {
                ProgressView("Abschlusstitel laden …")
                    .tint(ZAZUColors.primary)

            } else if viewModel.qualifications.isEmpty {
                Text(
                    viewModel.catalogErrorMessage == nil
                        ? "Für diese Auswahl ist noch kein Abschlusstitel hinterlegt."
                        : "Abschlusstitel sind momentan nicht verfügbar."
                )
                .font(.caption)
                .foregroundStyle(ZAZUColors.textSecondary)

            } else {
                ZAZUDropdownField(
                    "Abschlusstitel auswählen",
                    selection: Binding<UUID?>(
                        get: {
                            viewModel.selectedQualification?.id
                        },
                        set: { newID in
                            guard let qualification =
                                viewModel.qualifications.first(
                                    where: { $0.id == newID }
                                )
                            else {
                                viewModel.selectedQualification = nil
                                return
                            }

                            viewModel.selectQualification(qualification)
                        }
                    )
                ) {
                    Text("Nicht ausgewählt")
                        .tag(nil as UUID?)

                    ForEach(viewModel.qualifications) { qualification in
                        Text(qualification.name)
                            .tag(Optional(qualification.id))
                    }
                }
            }
        }
    }

    // MARK: - Education Degree

    private var educationDegreeSelection: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            fieldLabel("Abschluss / Qualifikation")

            if viewModel.isLoadingDegrees {
                ProgressView()
                    .tint(ZAZUColors.primary)
            } else {
                ZAZUDropdownField(
                    "Abschluss",
                    selection: Binding<UUID?>(
                        get: {
                            viewModel.selectedEducationTypeDegree?.id
                        },
                        set: { newId in
                            guard let degree =
                                viewModel.educationTypeDegrees.first(
                                    where: { $0.id == newId }
                                ) else {
                                    return
                                }

                            Task {
                                await viewModel.selectEducationTypeDegree(
                                    degree
                                )
                            }
                        }
                    )
                ) {
                    Text("Bitte auswählen")
                        .tag(nil as UUID?)

                    ForEach(viewModel.educationTypeDegrees) { degree in
                        Text(degree.nameDe)
                            .tag(Optional(degree.id))
                    }
                }
            }
        }
    }

    
    private var educationFieldSelection: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            fieldLabel(
                isApprenticeship
                    ? "Lehrberuf"
                    : isHigherEducation
                        ? "Studienrichtung"
                        : "Fachrichtung"
            )

            if viewModel.isLoadingFields {
                ProgressView("Fachrichtungen laden …")
                    .tint(ZAZUColors.primary)
            } else {
                textField(
                    "Fachrichtung / Lehrberuf suchen",
                    text: $viewModel.educationFieldSearchText
                )
                .onChange(
                    of: viewModel.selectedEducationTypeDegree?.id
                ) { _, _ in
                    viewModel.educationFieldSearchText = ""
                }

                ZAZUDropdownField(
                    "Fachrichtung auswählen",
                    selection: Binding<UUID?>(
                        get: {
                            viewModel.selectedEducationField?.id
                        },
                        set: { newId in
                            guard let field = viewModel.educationFields.first(
                                where: { $0.id == newId }
                            ) else {
                                viewModel.selectedEducationField = nil
                                viewModel.fieldOfStudy = ""
                                return
                            }

                            viewModel.selectEducationField(field)
                        }
                    )
                ) {
                    Text("Bitte auswählen")
                        .tag(nil as UUID?)

                    ForEach(viewModel.educationFields.filter { field in
                        let query = viewModel.educationFieldSearchText
                            .trimmingCharacters(in: .whitespacesAndNewlines)

                        return query.isEmpty
                            || field.nameDe.localizedStandardContains(query)
                            || field.id == viewModel.selectedEducationField?.id
                    }) { field in
                        Text(field.nameDe)
                            .tag(Optional(field.id))
                    }
                }

                if viewModel.educationFields.isEmpty {
                    Text(
                        "Für diesen Abschluss sind noch keine Fachrichtungen im Katalog hinterlegt."
                    )
                    .font(.caption)
                    .foregroundStyle(ZAZUColors.textSecondary)
                } else if !viewModel.educationFields.contains(where: { field in
                    let query = viewModel.educationFieldSearchText
                        .trimmingCharacters(in: .whitespacesAndNewlines)

                    return query.isEmpty
                        || field.nameDe.localizedStandardContains(query)
                }) {
                    Text("Keine passende Fachrichtung gefunden.")
                        .font(.caption)
                        .foregroundStyle(ZAZUColors.textSecondary)
                }            }
        }
    }


    // MARK: - Institution Context

    private var educationTypeCode: String? {
        viewModel.selectedEducationType?.code
    }

    private var isApprenticeship: Bool {
        educationTypeCode == "A02"
    }

    private var isHigherEducation: Bool {
        educationTypeCode == "A01"
            || educationTypeCode == "A10"
    }

    private var isSchoolEducation: Bool {
        guard let code = educationTypeCode else {
            return false
        }

        return [
            "A03", "A04", "A05",
            "A06", "A13", "A14"
        ].contains(code)
    }

    private var isProfessionalEducation: Bool {
        guard let code = educationTypeCode else {
            return false
        }

        return [
            "A07", "A08", "A09",
            "A11", "A12"
        ].contains(code)
    }

    private var institutionTitle: String {
        if isApprenticeship {
            return "Lehrbetrieb"
        }

        if isHigherEducation {
            return "Hochschule / Universität"
        }

        if isSchoolEducation {
            return "Schule / Bildungsinstitution"
        }

        if isProfessionalEducation {
            return "Bildungsanbieter / Institution"
        }

        return "Institution / Bildungsort"
    }

    private var institutionPlaceholder: String {
        if isApprenticeship {
            return "Name des Lehrbetriebs"
        }

        if isHigherEducation {
            return "Name der Hochschule oder Universität"
        }

        if isSchoolEducation {
            return "Name der Schule"
        }

        if isProfessionalEducation {
            return "Name des Bildungsanbieters"
        }

        return "Schule, Bildungsanbieter oder Institution"
    }

    
    // MARK: - Institution

    @ViewBuilder
    private var institutionSelection: some View {
        if isHigherEducation {
            higherEducationInstitutionSelection
        } else {
            otherInstitutionSelection
        }
    }

    private var higherEducationInstitutionSelection: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            fieldLabel("Hochschule / Universität")

            ZAZUDropdownField(
                "Hochschule auswählen",
                selection: Binding<UUID?>(
                    get: {
                        viewModel.selectedInstitution?.id
                    },
                    set: { newId in
                        guard let institution =
                            viewModel.educationInstitutions.first(
                                where: { $0.id == newId }
                            ) else {
                                return
                            }

                        viewModel.selectInstitution(institution)
                    }
                )
            ) {
                Text("Bitte auswählen")
                    .tag(nil as UUID?)

                ForEach(viewModel.educationInstitutions) { institution in
                    Text(institution.name)
                        .tag(Optional(institution.id))
                }
            }
        }
    }

    private var otherInstitutionSelection: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            fieldLabel(institutionTitle)

            textField(
                institutionPlaceholder,
                text: $viewModel.institutionName
            )
            .onChange(
                of: viewModel.institutionName
            ) { _, newValue in
                if viewModel.selectedInstitution?.name != newValue {
                    viewModel.selectedInstitution = nil
                }
            }

            if isApprenticeship {
                Text(
                    "Gib den Betrieb an, bei dem du deine Lehre absolviert hast."
                )
                .font(.caption)
                .foregroundStyle(ZAZUColors.textSecondary)
            } else {
                institutionTypeSelection
            }
        }
    }
    

    @ViewBuilder
    private var institutionTypeSelection: some View {
        if !viewModel.educationInstitutionTypes.isEmpty {
            fieldLabel("Institutionstyp (optional)")

            ZAZUDropdownField(
                "Institutionstyp",
                selection: Binding<UUID?>(
                    get: {
                        viewModel.selectedInstitutionType?.id
                    },
                    set: { newId in
                        viewModel.selectedInstitutionType =
                            viewModel.educationInstitutionTypes.first {
                                $0.id == newId
                            }
                    }
                )
            ) {
                Text("Nicht angegeben")
                    .tag(nil as UUID?)

                ForEach(viewModel.educationInstitutionTypes) { type in
                    Text(type.nameDe)
                        .tag(Optional(type.id))
                }
            }
        }
    }

    private var institutionCatalogSearch: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            fieldLabel("Hochschule im Katalog suchen")

            textField(
                "Hochschule suchen (optional)",
                text: $viewModel.institutionSearchText
            )
            .task(id: viewModel.institutionSearchText) {
                guard !viewModel.institutionSearchText
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                    .isEmpty else {
                    return
                }

                do {
                    try await Task.sleep(
                        for: .milliseconds(300)
                    )
                    try Task.checkCancellation()

                    await viewModel.searchInstitutions()
                } catch {
                    // Eine neuere Suche ersetzt diese Anfrage.
                }
            }

            if viewModel.isLoadingInstitutions {
                ProgressView()
                    .tint(ZAZUColors.primary)
            } else if !viewModel.institutionSearchText.isEmpty {
                ForEach(viewModel.educationInstitutions) { institution in
                    Button {
                        viewModel.selectInstitution(institution)
                    } label: {
                        HStack {
                            Text(institution.name)
                                .foregroundStyle(
                                    ZAZUColors.textPrimary
                                )

                            Spacer()

                            Image(systemName: "plus.circle")
                                .foregroundStyle(
                                    ZAZUColors.primary
                                )
                        }
                        .padding(ZAZUSpacing.small)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Dates

    private var startDateSection: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            Toggle(
                "Startdatum bekannt",
                isOn: $viewModel.hasStartDate
            )
            .tint(ZAZUColors.primary)

            if viewModel.hasStartDate {
                DatePicker(
                    "Startdatum",
                    selection: $viewModel.startDate,
                    displayedComponents: .date
                )
            }
        }
    }

    private var endDateSection: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            Toggle(
                "Enddatum bekannt",
                isOn: $viewModel.hasEndDate
            )
            .tint(ZAZUColors.primary)

            if viewModel.hasEndDate {
                DatePicker(
                    "Enddatum",
                    selection: $viewModel.endDate,
                    displayedComponents: .date
                )
            }
        }
    }

    // MARK: - Description

    private var descriptionSection: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            fieldLabel("Beschreibung (optional)")

            TextEditor(text: $viewModel.description)
                .frame(minHeight: 100)
                .padding(ZAZUSpacing.small)
                .background(ZAZUColors.veryLightPurple)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: ZAZURadius.medium
                    )
                )
        }
    }

    // MARK: - Actions

    private var addButton: some View {
        Button {
            Task {
                _ = await viewModel.addEducation()
            }
        } label: {
            Group {
                if viewModel.isSaving {
                    ProgressView()
                        .tint(ZAZUColors.primary)
                } else {
                    Label(
                        "Eintrag hinzufügen",
                        systemImage: "plus"
                    )
                    .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
        .buttonStyle(.plain)
        .foregroundStyle(ZAZUColors.primary)
        .background(ZAZUColors.lightPurple)
        .clipShape(
            RoundedRectangle(cornerRadius: ZAZURadius.medium)
        )
        .disabled(!viewModel.canSaveEducation)
        .opacity(viewModel.canSaveEducation ? 1 : 0.5)
    }

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
        if let error = viewModel.errorMessage {
            Text(error)
                .font(.footnote)
                .foregroundStyle(.red)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
        }
    }

    // MARK: - Helpers

    private func fieldLabel(_ title: String) -> some View {
        Text(title)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(ZAZUColors.textPrimary)
    }

    private func textField(
        _ title: String,
        text: Binding<String>
    ) -> some View {
        TextField(title, text: text)
            .padding(ZAZUSpacing.medium)
            .background(ZAZUColors.veryLightPurple)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: ZAZURadius.medium
                )
            )
    }

    private func dateDescription(
        for education: Education
    ) -> String {
        switch (
            education.startDate,
            education.endDate,
            education.isCurrent
        ) {
        case let (.some(start), _, true):
            return "\(start) – heute"

        case let (.some(start), .some(end), false):
            return "\(start) – \(end)"

        case let (.some(start), nil, false):
            return "Seit \(start)"

        case let (nil, .some(end), false):
            return "Bis \(end)"

        default:
            return "Zeitraum nicht angegeben"
        }
    }
}
