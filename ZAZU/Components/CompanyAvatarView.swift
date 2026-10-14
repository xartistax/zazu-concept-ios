//
//  CompanyAvatarView.swift
//  ZAZU
//

import SwiftUI
import UIKit

struct CompanyAvatarView: View {

    let companyId: UUID
    var size: CGFloat = 80

    var logoPath: String? = nil
    var imageStorageService: CompanyImageStorageService? = nil

    var onLoadComplete: (() -> Void)? = nil
    
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
        .task(id: "\(companyId.uuidString)-\(logoPath ?? "")-\(revision)") {
            await loadAvatar()
        }
    }

    @MainActor
    private func loadAvatar() async {
        avatarImage = nil

        defer {
            if !Task.isCancelled {
                onLoadComplete?()
            }
        }

        // 1. Hochgeladenes Firmenlogo bevorzugen.
        if let logoPath,
           let imageStorageService {

            do {
                let data = try await imageStorageService.downloadImage(
                    path: logoPath
                )

                try Task.checkCancellation()

                if let image = UIImage(data: data) {
                    avatarImage = image
                    return
                }
            } catch is CancellationError {
                return
            } catch {
                // Falls das Logo nicht geladen werden kann,
                // versuchen wir den DiceBear-Avatar.
            }
        }

        // 2. DiceBear-Fallback.
        do {
            let image = try await CompanyAvatarCache.shared.loadAvatar(
                companyId: companyId
            )

            try Task.checkCancellation()

            avatarImage = image
        } catch is CancellationError {
            return
        } catch {
            // 3. Das Fallback-Icon bleibt sichtbar.
        }
    }

    private var fallbackAvatar: some View {
        ZStack {
            Circle()
                .fill(ZAZUColors.lightPurple)

            Image(systemName: "building.2.fill")
                .font(.system(size: size * 0.4))
                .foregroundStyle(ZAZUColors.primary)
        }
    }
}
