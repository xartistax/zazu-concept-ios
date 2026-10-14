//
//  ContactAvatarView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 14.10.2026.
//

import SwiftUI
import UIKit

struct ContactAvatarView: View {

    let contactId: UUID

    var size: CGFloat = 80
    var portraitPath: String? = nil
    var imageStorageService: CompanyImageStorageService? = nil
    var revision: Int = 0

    @State private var avatarImage: UIImage?

    var body: some View {
        ZStack {
            if let avatarImage {
                Image(uiImage: avatarImage)
                    .resizable()
                    .scaledToFill()
            } else {
                fallbackAvatar
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .task(id: "\(contactId.uuidString)-\(portraitPath ?? "")-\(revision)") {
            await loadAvatar()
        }
        .accessibilityLabel("Profilbild der Kontaktperson")
    }

    @MainActor
    private func loadAvatar() async {
        avatarImage = nil

        // 1. Hochgeladenes Porträt bevorzugen.
        if let portraitPath,
           let imageStorageService {

            do {
                let data = try await imageStorageService.downloadImage(
                    path: portraitPath
                )

                try Task.checkCancellation()

                if let image = UIImage(data: data) {
                    avatarImage = image
                    return
                }
            } catch {
                if Task.isCancelled {
                    return
                }
            }
        }

        // 2. DiceBear-Fallback.
        do {
            let image = try await CompanyAvatarCache.shared.loadAvatar(
                companyId: contactId
            )

            try Task.checkCancellation()

            avatarImage = image

        } catch {
            // Falls DiceBear nicht erreichbar ist,
            // bleibt das lokale Fallback-Icon sichtbar.
        }
    }

    private var fallbackAvatar: some View {
        ZStack {
            Circle()
                .fill(ZAZUColors.lightPurple)

            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: size * 0.65))
                .foregroundStyle(ZAZUColors.primary)
        }
    }
}
