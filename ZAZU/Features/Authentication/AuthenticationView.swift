//
//  AuthenticationView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import SwiftUI

struct AuthenticationView: View {
    @State private var viewModel: AuthenticationViewModel
    @State private var isRegistering = false

    init(viewModel: AuthenticationViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            ZAZUColors.veryLightPurple
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: ZAZUSpacing.xLarge) {
                    header
                    form
                }
                .padding(.horizontal, ZAZUSpacing.large)
                .padding(.top, 80)
            }
        }
    }

    private var header: some View {
        VStack(spacing: ZAZUSpacing.small) {
            Text("ZAZU")
                .font(.system(size: 44, weight: .bold))
                .foregroundStyle(ZAZUColors.primary)

            Text("Swipe. Match. Job.")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(ZAZUColors.textSecondary)
        }
    }

    private var form: some View {
        VStack(spacing: ZAZUSpacing.medium) {
            Text(isRegistering ? "Konto erstellen" : "Willkommen zurück")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(ZAZUColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if isRegistering {
                VStack(alignment: .leading, spacing: ZAZUSpacing.small) {
                    Text("Ich möchte …")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(ZAZUColors.textPrimary)

                    accountRoleButton(
                        title: "einen Job finden",
                        subtitle: "Als Kandidat Jobs entdecken und matchen",
                        role: .candidate
                    )

                    accountRoleButton(
                        title: "Mitarbeitende finden",
                        subtitle: "Als Arbeitgeber passende Kandidaten finden",
                        role: .employer
                    )
                }
            }

            TextField("E-Mail", text: $viewModel.email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .padding()
                .background(ZAZUColors.white)
                .clipShape(
                    RoundedRectangle(cornerRadius: ZAZURadius.medium)
                )

            SecureField("Passwort", text: $viewModel.password)
                .textContentType(
                    isRegistering ? .newPassword : .password
                )
                .padding()
                .background(ZAZUColors.white)
                .clipShape(
                    RoundedRectangle(cornerRadius: ZAZURadius.medium)
                )

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                Task {
                    if isRegistering {
                        await viewModel.signUp()
                    } else {
                        await viewModel.signIn()
                    }
                }
            } label: {
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(isRegistering ? "Registrieren" : "Einloggen")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .background(
                viewModel.canSubmit
                    ? ZAZUColors.primary
                    : ZAZUColors.textSecondary.opacity(0.4)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: ZAZURadius.medium)
            )
            .disabled(!viewModel.canSubmit)

            /*
            Button {
                viewModel.errorMessage = nil
                isRegistering.toggle()
            } label: {
                Text(
                    isRegistering
                        ? "Bereits registriert? Einloggen"
                        : "Noch kein Konto? Registrieren"
                )
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(ZAZUColors.primary)
            }
            .disabled(viewModel.isLoading)
             */
            
            VStack(spacing: ZAZUSpacing.small) {
                Divider()
                    .padding(.vertical, ZAZUSpacing.small)

                Text("PoC Testzugänge")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(ZAZUColors.textSecondary)

                VStack(spacing: ZAZUSpacing.xSmall) {
                    Text("Kandidat")
                        .fontWeight(.semibold)

                    Text("candidate@mail.com")
                    Text("Passwort: 123456")
                }

                VStack(spacing: ZAZUSpacing.xSmall) {
                    Text("Arbeitgeber")
                        .fontWeight(.semibold)

                    Text("employer@mail.com")
                    Text("Passwort: 123456")
                }
                .padding(.top, ZAZUSpacing.small)
            }
            .font(.caption)
            .foregroundStyle(ZAZUColors.textSecondary)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
        }
        .padding(ZAZUSpacing.large)
        .background(ZAZUColors.white.opacity(0.6))
        .clipShape(
            RoundedRectangle(cornerRadius: ZAZURadius.large)
        )
        
        
        
    }
    
    private func accountRoleButton(
        title: String,
        subtitle: String,
        role: AccountRole
    ) -> some View {
        let isSelected = viewModel.selectedAccountRole == role

        return Button {
            viewModel.selectedAccountRole = role
        } label: {
            HStack(spacing: ZAZUSpacing.medium) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(
                        isSelected
                            ? ZAZUColors.primary
                            : ZAZUColors.textSecondary
                    )

                VStack(alignment: .leading, spacing: ZAZUSpacing.xSmall) {
                    Text(title)
                        .fontWeight(.semibold)
                        .foregroundStyle(ZAZUColors.textPrimary)

                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(ZAZUColors.textSecondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()
            }
            .padding(ZAZUSpacing.medium)
            .background(
                isSelected
                    ? ZAZUColors.lightPurple
                    : ZAZUColors.white
            )
            .overlay {
                RoundedRectangle(cornerRadius: ZAZURadius.medium)
                    .stroke(
                        isSelected
                            ? ZAZUColors.primary
                            : ZAZUColors.textSecondary.opacity(0.15),
                        lineWidth: isSelected ? 2 : 1
                    )
            }
            .clipShape(
                RoundedRectangle(cornerRadius: ZAZURadius.medium)
            )
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isLoading)
    }
}
