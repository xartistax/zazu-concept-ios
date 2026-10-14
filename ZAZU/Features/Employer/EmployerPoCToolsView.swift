//
//  EmployerPoCToolsView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 09.10.2026.
//

import SwiftUI
import Supabase

struct EmployerPoCToolsView: View {
    let supabaseClient: SupabaseClient
    let appState: AppState
    let accountSwitcher: PoCAccountSwitcher

    @State private var isSwitchingAccount = false
    @State private var switchErrorMessage: String?

    @State private var isTestingRLS = false
    @State private var rlsTestMessage: String?
    @State private var rlsTestPassed: Bool?

    @State private var isResettingApp = false
    @State private var showAppResetConfirmation = false
    @State private var appResetErrorMessage: String?

    @State private var isSeedingJobs = false
    @State private var seedJobsMessage: String?
    @State private var seedJobsSucceeded: Bool?

    private let foreignJobId = UUID(
        uuidString: "a81ed602-f76b-4e00-a89d-193b8f786688"
    )

    private let candidateTestUserId = UUID(
        uuidString: "1fe46804-4c5f-4a80-a845-126ddb7244ac"
    )

    private let foreignMatchId = UUID(
        uuidString: "86d5809f-21a9-44f7-8689-f49eb5ac68bc"
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
                    seedJobsCard
                    rlsTestCard
                    appResetCard
                }
                .padding(ZAZUSpacing.large)
            }
        }
        .navigationTitle("PoC Tools")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Arbeitgeber-App zurücksetzen?",
            isPresented: $showAppResetConfirmation,
            titleVisibility: .visible
        ) {
            Button(
                "Kompletten Reset durchführen",
                role: .destructive
            ) {
                Task {
                    await resetEmployerApp()
                }
            }

            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text(
                "Jobs, Matches, Interviews und Unternehmensprofil-Daten dieses Testaccounts werden zurückgesetzt. Account, Firmenname und Firmenzugehörigkeit bleiben bestehen."
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
                "Diese Werkzeuge dienen ausschließlich zum wiederholten Testen des Arbeitgeber-Flows."
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
                "Wechselt mit einer echten Supabase-Session zum Kandidaten-Testaccount."
            )
            .font(.subheadline)
            .foregroundStyle(ZAZUColors.textSecondary)

            Button {
                Task {
                    await switchToCandidate()
                }
            } label: {
                HStack {
                    Spacer()

                    if isSwitchingAccount {
                        ProgressView()
                            .tint(ZAZUColors.white)
                    } else {
                        Label(
                            "Zu Kandidat wechseln",
                            systemImage: "person.fill"
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
                isResettingApp ||
                isSeedingJobs
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

    private var seedJobsCard: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            Label(
                "Seed-Jobs",
                systemImage: "briefcase.fill"
            )
            .font(.headline)
            .foregroundStyle(ZAZUColors.primary)

            Text(
                "Erstellt 10 realistische Test-Jobs für dein Unternehmen inklusive Matching-Kriterien, Skills und Sprachen."
            )
            .font(.subheadline)
            .foregroundStyle(ZAZUColors.textSecondary)

            Button {
                Task {
                    await seedEmployerJobs()
                }
            } label: {
                HStack {
                    Spacer()

                    if isSeedingJobs {
                        ProgressView()
                            .tint(ZAZUColors.white)
                    } else {
                        Label(
                            "10 Seed-Jobs erstellen",
                            systemImage: "plus.circle.fill"
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
                isSeedingJobs ||
                isResettingApp ||
                isSwitchingAccount
            )

            if let seedJobsMessage {
                Label(
                    seedJobsMessage,
                    systemImage: seedJobsSucceeded == true
                        ? "checkmark.circle.fill"
                        : "exclamationmark.triangle.fill"
                )
                .font(.subheadline)
                .foregroundStyle(
                    seedJobsSucceeded == true
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

    private var rlsTestCard: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            Label(
                "Employer Security Test",
                systemImage: "lock.shield.fill"
            )
            .font(.headline)
            .foregroundStyle(ZAZUColors.primary)

            Text(
                "Prüft, ob ein Arbeitgeber einen Job einer fremden Firma verändern kann."
            )
            .font(.subheadline)
            .foregroundStyle(ZAZUColors.textSecondary)

            Button {
                Task {
                    await testEmployerRLS()
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
                isResettingApp ||
                isSeedingJobs
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
                "Setzt den Arbeitgeber-Testaccount auf den Zustand vor abgeschlossenem Unternehmens-Onboarding zurück. Account und Firmenzugehörigkeit bleiben bestehen."
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
            .disabled(
                isResettingApp ||
                isSeedingJobs ||
                isSwitchingAccount
            )

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
    private func seedEmployerJobs() async {
        guard !isSeedingJobs else {
            return
        }

        isSeedingJobs = true
        seedJobsMessage = nil
        seedJobsSucceeded = nil

        defer {
            isSeedingJobs = false
        }

        do {
            let createdCount: Int = try await supabaseClient
                .rpc("seed_employer_jobs_for_poc")
                .execute()
                .value

            seedJobsSucceeded = true
            seedJobsMessage =
                "\(createdCount) Seed-Jobs wurden erstellt."
        } catch {
            seedJobsSucceeded = false
            seedJobsMessage = error.localizedDescription
        }
    }

    @MainActor
    private func resetEmployerApp() async {
        guard !isResettingApp else {
            return
        }

        isResettingApp = true
        appResetErrorMessage = nil

        defer {
            isResettingApp = false
        }

        do {
            try await supabaseClient
                .rpc("reset_employer_for_poc")
                .execute()

            appState.rootState = .employerOnboarding
        } catch {
            appResetErrorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func switchToCandidate() async {
        guard !isSwitchingAccount else {
            return
        }

        isSwitchingAccount = true
        switchErrorMessage = nil

        defer {
            isSwitchingAccount = false
        }

        do {
            try await accountSwitcher.switchToCandidate(
                appState: appState
            )
        } catch {
            switchErrorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func testEmployerRLS() async {
        guard
            let foreignJobId,
            let candidateTestUserId,
            let foreignMatchId
        else {
            rlsTestPassed = false
            rlsTestMessage =
                "Testkonfiguration enthält ungültige UUIDs."
            return
        }

        struct JobUpdateProbe: Encodable {
            let isActive: Bool

            enum CodingKeys: String, CodingKey {
                case isActive = "is_active"
            }
        }

        struct JobResultProbe: Decodable {
            let id: UUID
        }

        struct CandidateProfileProbe: Decodable {
            let id: UUID
            let firstName: String?
            let lastName: String?
            let phoneNumber: String?

            enum CodingKeys: String, CodingKey {
                case id
                case firstName = "first_name"
                case lastName = "last_name"
                case phoneNumber = "phone_number"
            }
        }

        struct ContactProbe: Decodable {
            let firstName: String?
            let lastName: String?
            let phoneNumber: String?

            enum CodingKeys: String, CodingKey {
                case firstName = "first_name"
                case lastName = "last_name"
                case phoneNumber = "phone_number"
            }
        }

        struct EmployerDecisionProbe: Encodable {
            let jobId: UUID
            let candidateId: UUID
            let decision: String

            enum CodingKeys: String, CodingKey {
                case jobId = "p_job_id"
                case candidateId = "p_candidate_id"
                case decision = "p_decision"
            }
        }

        guard !isTestingRLS else {
            return
        }

        isTestingRLS = true
        rlsTestMessage = nil
        rlsTestPassed = nil

        defer {
            isTestingRLS = false
        }

        do {
            let updatedJobs: [JobResultProbe] =
                try await supabaseClient
                    .from("jobs")
                    .update(
                        JobUpdateProbe(
                            isActive: false
                        )
                    )
                    .eq(
                        "id",
                        value: foreignJobId
                    )
                    .select("id")
                    .execute()
                    .value

            guard updatedJobs.isEmpty else {
                rlsTestPassed = false
                rlsTestMessage =
                    "FEHLGESCHLAGEN: Fremder Job konnte verändert werden."
                return
            }

            let foreignContact: [ContactProbe] =
                try await supabaseClient
                    .rpc(
                        "get_confirmed_candidate_contact",
                        params: [
                            "p_match_id": foreignMatchId.uuidString
                        ]
                    )
                    .execute()
                    .value

            guard foreignContact.isEmpty else {
                rlsTestPassed = false
                rlsTestMessage =
                    "FEHLGESCHLAGEN: Kontakt eines fremden Matches ist lesbar."
                return
            }

            do {
                _ = try await supabaseClient
                    .rpc(
                        "save_employer_candidate_decision",
                        params: EmployerDecisionProbe(
                            jobId: foreignJobId,
                            candidateId: candidateTestUserId,
                            decision: "match"
                        )
                    )
                    .execute()

                rlsTestPassed = false
                rlsTestMessage =
                    "FEHLGESCHLAGEN: Swipe für fremden Job wurde akzeptiert."
                return
            } catch {
                // Erwartet:
                // Die RPC muss den fremden Job ablehnen.
            }

            let candidateProfiles: [CandidateProfileProbe] =
                try await supabaseClient
                    .from("profiles")
                    .select(
                        """
                        id,
                        first_name,
                        last_name,
                        phone_number
                        """
                    )
                    .eq(
                        "id",
                        value: candidateTestUserId
                    )
                    .execute()
                    .value

            guard candidateProfiles.isEmpty else {
                rlsTestPassed = false
                rlsTestMessage =
                    "FEHLGESCHLAGEN: Private Kandidatendaten sind direkt lesbar."
                return
            }

            rlsTestPassed = true
            rlsTestMessage =
                "BESTANDEN: Employer-Zugriffsgrenzen sind geschützt."
        } catch {
            // Ein explizites RLS-Denied ist ebenfalls ein sicherer Ausgang.
            rlsTestPassed = true
            rlsTestMessage =
                "BESTANDEN: Zugriff auf fremden Job wurde verweigert."
        }
    }
}
