//
//  ProfileRepository.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 28.09.2026.
//

import Foundation
import Supabase

final class ProfileRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }
    
    
    func resetForPoC(
        userId: UUID
    ) async throws {
        struct Update: Encodable {
            let firstName: String?
            let lastName: String?
            let phoneNumber: String?

            enum CodingKeys: String, CodingKey {
                case firstName = "first_name"
                case lastName = "last_name"
                case phoneNumber = "phone_number"
            }

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)

                try container.encode(firstName, forKey: .firstName)
                try container.encode(lastName, forKey: .lastName)
                try container.encode(phoneNumber, forKey: .phoneNumber)
            }
        }

        let update = Update(
            firstName: nil,
            lastName: nil,
            phoneNumber: nil
        )

        try await client
            .from("profiles")
            .update(update)
            .eq("id", value: userId)
            .execute()
    }

    func fetchProfile(
        userId: UUID
    ) async throws -> Profile {
        try await client
            .from("profiles")
            .select("id, first_name, last_name, phone_number, account_role")
            .eq("id", value: userId)
            .single()
            .execute()
            .value
    }

    func updateBasicInformation(
        userId: UUID,
        firstName: String,
        lastName: String,
        phoneNumber: String?
    ) async throws {
        struct Update: Encodable {
            let firstName: String
            let lastName: String
            let phoneNumber: String?

            enum CodingKeys: String, CodingKey {
                case firstName = "first_name"
                case lastName = "last_name"
                case phoneNumber = "phone_number"
            }

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)

                try container.encode(firstName, forKey: .firstName)
                try container.encode(lastName, forKey: .lastName)
                try container.encode(phoneNumber, forKey: .phoneNumber)
            }
        }

        let update = Update(
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber
        )

        try await client
            .from("profiles")
            .update(update)
            .eq("id", value: userId)
            .execute()
    }
}
