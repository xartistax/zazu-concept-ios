//
//  CompanyContactRepository.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 14.10.2026.
//

import Foundation
import Supabase

final class CompanyContactRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    // MARK: - Fetch

    func fetchContacts(companyId: UUID) async throws -> [CompanyContact] {
        try await client
            .from("company_contacts")
            .select()
            .eq("company_id", value: companyId)
            .order("last_name", ascending: true)
            .execute()
            .value
    }

    // MARK: - Create

    func createContact(
        companyId: UUID,
        firstName: String,
        lastName: String,
        position: String?,
        email: String?,
        phone: String?
    ) async throws -> CompanyContact {
        struct Payload: Encodable {
            let companyId: UUID
            let firstName: String
            let lastName: String
            let position: String?
            let email: String?
            let phone: String?

            enum CodingKeys: String, CodingKey {
                case companyId = "company_id"
                case firstName = "first_name"
                case lastName = "last_name"
                case position
                case email
                case phone
            }
        }

        let payload = Payload(
            companyId: companyId,
            firstName: firstName,
            lastName: lastName,
            position: position,
            email: email,
            phone: phone
        )

        return try await client
            .from("company_contacts")
            .insert(payload)
            .select()
            .single()
            .execute()
            .value
    }

    // MARK: - Update

    func updateContact(
        id: UUID,
        firstName: String,
        lastName: String,
        position: String?,
        email: String?,
        phone: String?
    ) async throws {
        struct Payload: Encodable {
            let firstName: String
            let lastName: String
            let position: String?
            let email: String?
            let phone: String?

            enum CodingKeys: String, CodingKey {
                case firstName = "first_name"
                case lastName = "last_name"
                case position
                case email
                case phone
            }
        }

        let payload = Payload(
            firstName: firstName,
            lastName: lastName,
            position: position,
            email: email,
            phone: phone
        )

        try await client
            .from("company_contacts")
            .update(payload)
            .eq("id", value: id)
            .execute()
    }
    
    func clearPortraitPath(
        contactId: UUID,
        companyId: UUID
    ) async throws {

        struct Payload: Encodable {
            enum CodingKeys: String, CodingKey {
                case portraitPath = "portrait_path"
            }

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(
                    keyedBy: CodingKeys.self
                )

                try container.encodeNil(forKey: .portraitPath)
            }
        }

        try await client
            .from("company_contacts")
            .update(Payload())
            .eq("id", value: contactId)
            .eq("company_id", value: companyId)
            .execute()
    }
    
    
    
    // MARK: - Portrait

    func updatePortraitPath(
        contactId: UUID,
        companyId: UUID,
        path: String
    ) async throws {

        struct Payload: Encodable {
            let portraitPath: String

            enum CodingKeys: String, CodingKey {
                case portraitPath = "portrait_path"
            }
        }

        try await client
            .from("company_contacts")
            .update(Payload(portraitPath: path))
            .eq("id", value: contactId)
            .eq("company_id", value: companyId)
            .execute()
    }

    // MARK: - Delete

    func deleteContact(id: UUID) async throws {
        try await client
            .from("company_contacts")
            .delete()
            .eq("id", value: id)
            .execute()
    }
}
