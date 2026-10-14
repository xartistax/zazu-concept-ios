import Foundation
import Supabase

enum AuthenticationError: LocalizedError {
    case missingSession

    var errorDescription: String? {
        switch self {
        case .missingSession:
            return "Es konnte keine aktive Sitzung erstellt werden."
        }
    }
}

final class AuthenticationService {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func signUp(
        email: String,
        password: String,
        accountRole: AccountRole
    ) async throws {
        let response = try await client.auth.signUp(
            email: email,
            password: password,
            data: [
                "account_role": .string(accountRole.rawValue)
            ]
        )

        guard response.session != nil else {
            throw AuthenticationError.missingSession
        }
    }

    func signIn(
        email: String,
        password: String
    ) async throws {
        try await client.auth.signIn(
            email: email,
            password: password
        )
    }
    
    func currentUserEmail() async throws -> String? {
        let session = try await client.auth.session
        return session.user.email
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }
}
