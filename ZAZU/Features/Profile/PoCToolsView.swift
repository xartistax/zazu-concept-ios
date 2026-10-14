//
//  PoCToolsView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 02.10.2026.
//

import SwiftUI
import Supabase

struct PoCToolsView: View {
    let resetService: PoCResetService
    let appState: AppState
    let userId: UUID
    let supabaseClient: SupabaseClient
    let accountSwitcher: PoCAccountSwitcher

    @State private var isResettingApp = false
    @State private var showAppResetConfirmation = false
    @State private var appResetErrorMessage: String?

    @State private var isTestingRLS = false
    @State private var rlsTestMessage: String?
    @State private var rlsTestPassed: Bool?

    @State private var isSwitchingAccount = false
    @State private var switchErrorMessage: String?

    private let foreignCandidateId = UUID(
        uuidString: "3f7ed3b2-61e4-4607-809a-c79b67140d43"
    )

    var body: some View {
        ZStack {
            ZAZUColors.veryLightPurple
                .ignoresSafeArea()

            ScrollView {
                VStack(
                    alignment: .leading,
                    spacing: ZAZUSpacing.large
                ) {
                    warningCard
                    accountSwitchCard
                    rlsTestCard
                    appResetCard
                }
                .padding(ZAZUSpacing.large)
            }
        }
        .navigationTitle("PoC Tools")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Kompletten App-Zustand zurücksetzen?",
            isPresented: $showAppResetConfirmation,
            titleVisibility: .visible
        ) {
            Button(
                "Kompletten Reset durchführen",
                role: .destructive
            ) {
                Task {
                    await resetApp()
                }
            }

            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text(
                "Onboarding, Profilangaben, Berufserfahrung, Skills, Ausbildung, Sprachen, Matches und Swipe-Verlauf dieses Testusers werden zurückgesetzt. Login und Account bleiben bestehen."
            )
        }
    }

    private var warningCard: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            Label(
                "Nur für den PoC",
                systemImage: "hammer.fill"
            )
            .font(.headline)
            .foregroundStyle(ZAZUColors.primary)

            Text(
                "Diese Werkzeuge dienen ausschließlich zum wiederholten Testen der App."
            )
            .font(.subheadline)
            .foregroundStyle(ZAZUColors.textSecondary)
        }
        .padding(ZAZUSpacing.medium)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(ZAZUColors.lightPurple)
        .clipShape(
            RoundedRectangle(
                cornerRadius: ZAZURadius.large
            )
        )
    }

    private var accountSwitchCard: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            Label(
                "Testaccount wechseln",
                systemImage: "arrow.left.arrow.right"
            )
            .font(.headline)
            .foregroundStyle(ZAZUColors.primary)

            Text(
                "Wechselt mit einer echten Supabase-Session zum Arbeitgeber-Testaccount."
            )
            .font(.subheadline)
            .foregroundStyle(ZAZUColors.textSecondary)

            Button {
                Task {
                    await switchToEmployer()
                }
            } label: {
                HStack {
                    Spacer()

                    if isSwitchingAccount {
                        ProgressView()
                            .tint(ZAZUColors.white)
                    } else {
                        Label(
                            "Zu Arbeitgeber wechseln",
                            systemImage: "building.2.fill"
                        )
                    }

                    Spacer()
                }
                .fontWeight(.semibold)
                .foregroundStyle(ZAZUColors.white)
                .padding(.vertical, ZAZUSpacing.medium)
                .background(ZAZUColors.primary)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: ZAZURadius.medium
                    )
                )
            }
            .disabled(
                isSwitchingAccount ||
                isResettingApp
            )

            if let switchErrorMessage {
                Label(
                    switchErrorMessage,
                    systemImage: "exclamationmark.triangle.fill"
                )
                .font(.footnote)
                .foregroundStyle(ZAZUColors.danger)
            }
        }
        .padding(ZAZUSpacing.medium)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: ZAZURadius.large
            )
        )
    }

    private var rlsTestCard: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            Label(
                "RLS Security Test",
                systemImage: "lock.shield.fill"
            )
            .font(.headline)
            .foregroundStyle(ZAZUColors.primary)

            Text(
                "Prüft Kandidaten-Isolation und ob interne Arbeitgeberentscheidungen für Kandidaten verborgen bleiben."
            )
            .font(.subheadline)
            .foregroundStyle(ZAZUColors.textSecondary)

            Button {
                Task {
                    await testRLSProtection()
                }
            } label: {
                HStack {
                    Spacer()

                    if isTestingRLS {
                        ProgressView()
                            .tint(ZAZUColors.white)
                    } else {
                        Label(
                            "Security prüfen",
                            systemImage: "lock.fill"
                        )
                    }

                    Spacer()
                }
                .fontWeight(.semibold)
                .foregroundStyle(ZAZUColors.white)
                .padding(.vertical, ZAZUSpacing.medium)
                .background(ZAZUColors.primary)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: ZAZURadius.medium
                    )
                )
            }
            .disabled(
                isTestingRLS ||
                isResettingApp
            )

            if let rlsTestMessage {
                Label(
                    rlsTestMessage,
                    systemImage: rlsTestPassed == true
                        ? "checkmark.shield.fill"
                        : "exclamationmark.triangle.fill"
                )
                .font(.footnote)
                .foregroundStyle(
                    rlsTestPassed == true
                        ? ZAZUColors.success
                        : ZAZUColors.danger
                )
            }
        }
        .padding(ZAZUSpacing.medium)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: ZAZURadius.large
            )
        )
    }

    private var appResetCard: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            Label(
                "Kompletter App-Reset",
                systemImage: "trash.fill"
            )
            .font(.headline)
            .foregroundStyle(ZAZUColors.danger)

            Text(
                "Setzt diesen Testuser auf den Zustand direkt nach der Registrierung zurück. Der Account bleibt bestehen."
            )
            .font(.subheadline)
            .foregroundStyle(ZAZUColors.textSecondary)

            Button {
                showAppResetConfirmation = true
            } label: {
                HStack {
                    Spacer()

                    if isResettingApp {
                        ProgressView()
                            .tint(ZAZUColors.white)
                    } else {
                        Label(
                            "Kompletten App-Reset",
                            systemImage: "trash"
                        )
                    }

                    Spacer()
                }
                .fontWeight(.semibold)
                .foregroundStyle(ZAZUColors.white)
                .padding(.vertical, ZAZUSpacing.medium)
                .background(ZAZUColors.danger)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: ZAZURadius.medium
                    )
                )
            }
            .disabled(isResettingApp)

            if let appResetErrorMessage {
                Label(
                    appResetErrorMessage,
                    systemImage: "exclamationmark.triangle.fill"
                )
                .font(.footnote)
                .foregroundStyle(ZAZUColors.danger)
            }
        }
        .padding(ZAZUSpacing.medium)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: ZAZURadius.large
            )
        )
    }

    @MainActor
    private func switchToEmployer() async {
        guard !isSwitchingAccount else {
            return
        }

        isSwitchingAccount = true
        switchErrorMessage = nil

        defer {
            isSwitchingAccount = false
        }

        do {
            try await accountSwitcher.switchToEmployer(
                appState: appState
            )
        } catch {
            switchErrorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func testRLSProtection() async {
        guard let foreignCandidateId else {
            rlsTestPassed = false
            rlsTestMessage =
                "Testkonfiguration enthält eine ungültige UUID."
            return
        }

        isTestingRLS = true
        rlsTestMessage = nil
        rlsTestPassed = nil

        defer {
            isTestingRLS = false
        }

        do {
            let foreignProfiles: [ForeignProfileProbe] =
                try await supabaseClient
                    .from("profiles")
                    .select("id")
                    .eq(
                        "id",
                        value: foreignCandidateId.uuidString
                    )
                    .execute()
                    .value

            guard foreignProfiles.isEmpty else {
                rlsTestPassed = false
                rlsTestMessage =
                    "FEHLGESCHLAGEN: Fremdes Kandidatenprofil ist lesbar."
                return
            }

            let updatedForeignProfiles: [ForeignProfileProbe] =
                try await supabaseClient
                    .from("profiles")
                    .update(
                        ForeignProfileUpdate(
                            firstName: "RLS_SHOULD_BLOCK"
                        )
                    )
                    .eq(
                        "id",
                        value: foreignCandidateId.uuidString
                    )
                    .select("id")
                    .execute()
                    .value

            guard updatedForeignProfiles.isEmpty else {
                rlsTestPassed = false
                rlsTestMessage =
                    "FEHLGESCHLAGEN: Fremdes Kandidatenprofil konnte verändert werden."
                return
            }

            let employerDecisions: [EmployerDecisionProbe] =
                try await supabaseClient
                    .from("employer_job_interactions")
                    .select("job_id")
                    .execute()
                    .value

            guard employerDecisions.isEmpty else {
                rlsTestPassed = false
                rlsTestMessage =
                    "FEHLGESCHLAGEN: Arbeitgeberentscheidungen sind für Kandidaten lesbar."
                return
            }

            rlsTestPassed = true
            rlsTestMessage =
                "BESTANDEN: Fremdprofile sind weder lesbar noch veränderbar und Arbeitgeberentscheidungen bleiben geschützt."
        } catch {
            rlsTestPassed = false
            rlsTestMessage =
                "Testfehler: \(error.localizedDescription)"
        }
    }

    @MainActor
    private func resetApp() async {
        guard !isResettingApp else {
            return
        }

        isResettingApp = true
        appResetErrorMessage = nil

        defer {
            isResettingApp = false
        }

        do {
            try await resetService.resetCandidate(
                userId: userId
            )

            appState.rootState = .onboarding
        } catch {
            appResetErrorMessage = error.localizedDescription
        }
    }
}

private struct ForeignProfileProbe: Decodable {
    let id: UUID
}

private struct EmployerDecisionProbe: Decodable {
    let jobId: UUID

    enum CodingKeys: String, CodingKey {
        case jobId = "job_id"
    }
}

private struct ForeignProfileUpdate: Encodable {
    let firstName: String

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
    }
}
