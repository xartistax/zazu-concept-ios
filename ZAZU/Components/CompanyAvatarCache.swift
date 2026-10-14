//
//  CompanyAvatarCache.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 13.10.2026.
//



import Foundation
import UIKit

actor CompanyAvatarCache {

    static let shared = CompanyAvatarCache()

    private let fileManager = FileManager.default

    private var cacheDirectory: URL? {
        fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first?
            .appendingPathComponent(
                "CompanyAvatars",
                isDirectory: true
            )
    }

    func loadAvatar(
        companyId: UUID
    ) async throws -> UIImage {

        guard let directory = cacheDirectory else {
            throw AvatarError.cacheUnavailable
        }

        let fileURL = directory.appendingPathComponent(
            "dicebear-v10-blobs-\(companyId.uuidString).png"
        )
        // 1. Bereits gespeicherten Avatar verwenden
        if let data = try? Data(contentsOf: fileURL),
           let image = UIImage(data: data) {
            return image
        }

        // 2. Avatar bei DiceBear laden
        var components = URLComponents(
            string: "https://api.dicebear.com/10.x/blobs/png"
        )

        components?.queryItems = [
            URLQueryItem(
                name: "seed",
                value: companyId.uuidString
            )
        ]

        guard let url = components?.url else {
            throw AvatarError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(
            from: url
        )

        guard let response = response as? HTTPURLResponse,
              (200...299).contains(response.statusCode),
              let image = UIImage(data: data)
        else {
            throw AvatarError.invalidResponse
        }

        // 3. Bild für spätere App-Starts speichern
        try fileManager.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )

        try data.write(
            to: fileURL,
            options: .atomic
        )

        return image
    }

    enum AvatarError: Error {
        case cacheUnavailable
        case invalidURL
        case invalidResponse
    }
}
