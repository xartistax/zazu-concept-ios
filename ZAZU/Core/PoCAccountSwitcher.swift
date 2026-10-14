//
//  PoCAccountSwitcher.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 09.10.2026.
//

import Foundation
import Supabase

@MainActor
final class PoCAccountSwitcher {
    private let client: SupabaseClient
    private let sessionService: SessionService

    init(
        client: SupabaseClient,
        sessionService: SessionService
    ) {
        self.client = client
        self.sessionService = sessionService
    }

    func switchToCandidate(
        appState: AppState
    ) async throws {
        guard let account = PoCTestAccounts.candidate else {
            throw PoCAccountSwitcherError.accountNotConfigured
        }

        try await switchAccount(
            account,
            appState: appState
        )
    }

    func switchToEmployer(
        appState: AppState
    ) async throws {
        guard let account = PoCTestAccounts.employer else {
            throw PoCAccountSwitcherError.accountNotConfigured
        }

        try await switchAccount(
            account,
            appState: appState
        )
    }

    private func switchAccount(
        _ account: PoCTestAccount,
        appState: AppState
    ) async throws {
        try await client.auth.signOut()

        _ = try await client.auth.signIn(
            email: account.email,
            password: account.password
        )

        await sessionService.restoreSession(
            appState: appState
        )
    }
}

enum PoCAccountSwitcherError: LocalizedError {
    case accountNotConfigured

    var errorDescription: String? {
        switch self {
        case .accountNotConfigured:
            return "Der PoC-Testaccount ist nicht konfiguriert."
        }
    }
}
