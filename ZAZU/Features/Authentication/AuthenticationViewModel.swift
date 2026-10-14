//
//  AuthenticationViewModel.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class AuthenticationViewModel {

    var email = ""
    var password = ""

    var isLoading = false
    var errorMessage: String?

    var selectedAccountRole: AccountRole = .candidate
    
    
    private let authenticationService: AuthenticationService
    private let appState: AppState
    
    private let sessionService: SessionService

    init(
        authenticationService: AuthenticationService,
        sessionService: SessionService,
        appState: AppState
    ) {
        self.authenticationService = authenticationService
        self.sessionService = sessionService
        self.appState = appState
    }

    var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        password.count >= 6 &&
        !isLoading
    }

    func signUp() async {
        await performAuthentication {
            try await authenticationService.signUp(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password,
                accountRole: selectedAccountRole
            )

            await sessionService.restoreSession(appState: appState)
        }
    }

    func signIn() async {
        await performAuthentication {
            try await authenticationService.signIn(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )

            await sessionService.restoreSession(appState: appState)
        }
    }

    private func performAuthentication(
        action: () async throws -> Void
    ) async {
        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            try await action()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
