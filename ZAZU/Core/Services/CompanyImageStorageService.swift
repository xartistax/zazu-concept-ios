//
//  CompanyImageStorageService.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 13.10.2026.
//



import Foundation
import Supabase

final class CompanyImageStorageService {

    private let client: SupabaseClient
    private let bucketName = "company-assets"

    init(client: SupabaseClient) {
        self.client = client
    }

    // MARK: - Image Type

    enum ImageType: String {
        case logo
        case header

        var fileName: String {
            "\(rawValue).jpg"
        }
    }

    // MARK: - Upload

    func uploadImage(
        data: Data,
        companyId: UUID,
        type: ImageType
    ) async throws -> String {

        guard !data.isEmpty,
              data.count <= 5 * 1024 * 1024 else {
            throw StorageError.invalidImageSize
        }

        let path = "\(companyId.uuidString.lowercased())/\(type.fileName)"

        try await client.storage
            .from(bucketName)
            .upload(
                path,
                data: data,
                options: FileOptions(
                    cacheControl: "3600",
                    contentType: "image/jpeg",
                    upsert: true
                )
            )

        return path
    }
    
    
    // MARK: - Contact Portrait Upload

    func uploadContactPortrait(
        data: Data,
        companyId: UUID,
        contactId: UUID
    ) async throws -> String {

        guard !data.isEmpty,
              data.count <= 5 * 1024 * 1024 else {
            throw StorageError.invalidImageSize
        }

        let path = [
            companyId.uuidString.lowercased(),
            "contacts",
            contactId.uuidString.lowercased(),
            "portrait.jpg"
        ].joined(separator: "/")

        try await client.storage
            .from(bucketName)
            .upload(
                path,
                data: data,
                options: FileOptions(
                    cacheControl: "3600",
                    contentType: "image/jpeg",
                    upsert: true
                )
            )

        return path
    }

    // MARK: - Download

    func downloadImage(
        path: String
    ) async throws -> Data {

        try await client.storage
            .from(bucketName)
            .download(path: path)
    }

    // MARK: - Errors

    enum StorageError: LocalizedError {
        case invalidImageSize

        var errorDescription: String? {
            switch self {
            case .invalidImageSize:
                return "Das Bild darf maximal 5 MB gross sein."
            }
        }
    }
    
    
    // MARK: - Delete

    func deleteImage(
        path: String
    ) async throws {
        try await client.storage
            .from(bucketName)
            .remove(paths: [path])
    }
}
