//
//  PoCTestAccounts.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 09.10.2026.
//

import Foundation

struct PoCTestAccount {
    let email: String
    let password: String
}

enum PoCTestAccounts {
    static var candidate: PoCTestAccount? {
        account(
            emailKey: "POC_CANDIDATE_EMAIL",
            passwordKey: "POC_CANDIDATE_PASSWORD"
        )
    }

    static var employer: PoCTestAccount? {
        account(
            emailKey: "POC_EMPLOYER_EMAIL",
            passwordKey: "POC_EMPLOYER_PASSWORD"
        )
    }

    private static func account(
        emailKey: String,
        passwordKey: String
    ) -> PoCTestAccount? {
        guard
            let email = Bundle.main.object(
                forInfoDictionaryKey: emailKey
            ) as? String,
            let password = Bundle.main.object(
                forInfoDictionaryKey: passwordKey
            ) as? String,
            !email.isEmpty,
            !password.isEmpty,
            !email.contains("$("),
            !password.contains("$(")
        else {
            return nil
        }

        return PoCTestAccount(
            email: email,
            password: password
        )
    }
}
