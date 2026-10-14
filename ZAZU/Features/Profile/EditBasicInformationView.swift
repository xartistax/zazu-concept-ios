//
//  EditBasicInformationView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 29.09.2026.
//

import SwiftUI

struct EditBasicInformationView: View {
    @Environment(\.dismiss) private var dismiss
    let onSaved: () -> Void

    @State private var viewModel: OnboardingViewModel

    init(
        viewModel: OnboardingViewModel,
        onSaved: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onSaved = onSaved
    }
    
    
    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.large
            ) {
                Text("Basisinformationen")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(ZAZUColors.textPrimary)

                Text("Passe deine persönlichen Angaben und deine Arbeitsberechtigung an.")
                    .foregroundStyle(ZAZUColors.textSecondary)

                BasicInformationForm(
                    viewModel: viewModel
                )

                saveButton
            }
            .padding(ZAZUSpacing.large)
        }
        .background(ZAZUColors.veryLightPurple)
        .navigationTitle("Bearbeiten")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
    }

    private var saveButton: some View {
        Button {
            Task {
                let didSave =
                    await viewModel.saveBasicInformation()

                if didSave {
                    onSaved()
                    dismiss()
                }
            }
        } label: {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Speichern")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .background(
            viewModel.canContinue
                ? ZAZUColors.primary
                : ZAZUColors.textSecondary.opacity(0.4)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: ZAZURadius.medium
            )
        )
        .disabled(!viewModel.canContinue)
    }
}
