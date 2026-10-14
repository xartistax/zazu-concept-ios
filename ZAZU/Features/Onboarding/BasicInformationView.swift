//
//  BasicInformationView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import SwiftUI

struct BasicInformationView: View {
    @Bindable var viewModel: OnboardingViewModel

    let onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ZAZUSpacing.large) {
                progressHeader
                title
                BasicInformationForm(viewModel: viewModel)
                continueButton
            }
            .padding(ZAZUSpacing.large)
        }
        .background(ZAZUColors.veryLightPurple)
    }

    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: ZAZUSpacing.small) {
            HStack {
                Text("Profil erstellen")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(ZAZUColors.primary)

                Spacer()

                Text("1 von 8")
                    .font(.subheadline)
                    .foregroundStyle(ZAZUColors.textSecondary)
            }

            ProgressView(value: 1, total: 8)
                .tint(ZAZUColors.primary)
        }
    }

    private var title: some View {
        VStack(alignment: .leading, spacing: ZAZUSpacing.small) {
            Text("Basisinformationen")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(ZAZUColors.textPrimary)

            Text("Erzähl uns kurz etwas über dich und deine Arbeitsberechtigung.")
                .foregroundStyle(ZAZUColors.textSecondary)
        }
    }





    private var continueButton: some View {
        Button {
            Task {
                let didSave = await viewModel.saveBasicInformation()

                if didSave {
                    onContinue()
                }
            }
        } label: {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Weiter")
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
            RoundedRectangle(cornerRadius: ZAZURadius.medium)
        )
        .disabled(!viewModel.canContinue)
    }
}
