//
//  CompanyBannerView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 13.10.2026.
//


import SwiftUI
import UIKit

struct CompanyBannerView: View {

    // MARK: - Dependencies

    let headerImagePath: String?
    let imageStorageService: CompanyImageStorageService

    // MARK: - Configuration

    var height: CGFloat = 160
    var revision: Int = 0

    // MARK: - State

    @State private var bannerImage: UIImage?

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: ZAZURadius.medium)
                    .fill(
                        LinearGradient(
                            colors: [
                                ZAZUColors.primary,
                                ZAZUColors.lightPurple
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                if let bannerImage {
                    Image(uiImage: bannerImage)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height
                        )
                        .clipped()
                } else {
                    Image(systemName: "building.2.crop.circle")
                        .font(.system(size: 48, weight: .ultraLight))
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
            .clipShape(
                RoundedRectangle(cornerRadius: ZAZURadius.medium)
            )
        }
        .frame(height: height)
        .task(id: "\(headerImagePath ?? "")-\(revision)") {
            await loadBanner()
        }
        .accessibilityLabel("Unternehmensbanner")
    }

    // MARK: - Load Banner

    @MainActor
    private func loadBanner() async {
        bannerImage = nil

        guard let headerImagePath else {
            return
        }

        do {
            let data = try await imageStorageService.downloadImage(
                path: headerImagePath
            )

            try Task.checkCancellation()

            bannerImage = UIImage(data: data)

        } catch {
            let nsError = error as NSError

            // Abgebrochene Requests sind bei SwiftUI-View-Updates normal.
            if Task.isCancelled ||
                nsError.domain == NSURLErrorDomain &&
                nsError.code == NSURLErrorCancelled {
                return
            }

            print(
                "Firmenbanner konnte nicht geladen werden: \(error.localizedDescription)"
            )
        }
    }
}
