//
//  EmployerEducationRequirementsView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 08.10.2026.
//

import SwiftUI

struct EmployerEducationRequirementsView: View {
    @Bindable var jobViewModel: EmployerJobFormViewModel

    var body: some View {
        List {
            if jobViewModel.educationRequirements.isEmpty {
                ContentUnavailableView(
                    "Keine Ausbildungsanforderungen",
                    systemImage: "graduationcap",
                    description: Text(
                        "Füge einen gewünschten Abschluss oder eine Qualifikation hinzu."
                    )
                )
            } else {
                ForEach($jobViewModel.educationRequirements) { $requirement in
                    Section {
                        TextField(
                            "Abschluss / Qualifikation",
                            text: $requirement.degree
                        )

                        TextField(
                            "Fachrichtung (optional)",
                            text: $requirement.fieldOfStudy
                        )

                        Picker(
                            "Priorität",
                            selection: $requirement.requirementType
                        ) {
                            Text(RequirementType.must.title)
                                .tag(RequirementType.must)

                            Text(RequirementType.optional.title)
                                .tag(RequirementType.optional)
                        }
                        .pickerStyle(.segmented)

                        Button(role: .destructive) {
                            jobViewModel.removeEducationRequirement(
                                id: requirement.id
                            )
                        } label: {
                            Label(
                                "Anforderung entfernen",
                                systemImage: "trash"
                            )
                        }
                    }
                }
            }

            Section {
                Button {
                    jobViewModel.addEducationRequirement()
                } label: {
                    Label(
                        "Ausbildungsanforderung hinzufügen",
                        systemImage: "plus.circle.fill"
                    )
                    .foregroundStyle(ZAZUColors.primary)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Ausbildung")
        .navigationBarTitleDisplayMode(.inline)
    }
}
