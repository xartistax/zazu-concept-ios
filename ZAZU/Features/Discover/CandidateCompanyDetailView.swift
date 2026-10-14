//
//  CandidateCompanyDetailView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 11.10.2026.
//

import SwiftUI

struct CandidateCompanyDetailView: View {
    let company: Company

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.large
            ) {
                header
                companyInformation

                if let description = company.description,
                   !description.isEmpty {
                    descriptionSection(description)
                }
            }
            .padding(ZAZUSpacing.medium)
        }
        .background(
            ZAZUColors.veryLightPurple
                .ignoresSafeArea()
        )
        .navigationTitle("Unternehmen")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            ZStack {
                RoundedRectangle(
                    cornerRadius: ZAZURadius.medium
                )
                .fill(ZAZUColors.lightPurple)
                .frame(width: 64, height: 64)

                Image(systemName: "building.2.fill")
                    .font(.title)
                    .foregroundStyle(ZAZUColors.primary)
            }

            Text(company.name)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(ZAZUColors.textPrimary)

            if let industry = company.industry,
               !industry.isEmpty {
                Text(industry)
                    .font(.subheadline)
                    .foregroundStyle(ZAZUColors.textSecondary)
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }

    private var companyInformation: some View {
        sectionCard {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.medium
            ) {
                Text("Unternehmen")
                    .font(.headline)
                    .foregroundStyle(ZAZUColors.textPrimary)

                if let location = company.location,
                   !location.isEmpty {
                    infoRow(
                        icon: "mappin.and.ellipse",
                        title: "Standort",
                        value: location
                    )
                }

                if let companySize = company.companySize,
                   !companySize.isEmpty {
                    infoRow(
                        icon: "person.3",
                        title: "Unternehmensgrösse",
                        value: companySize
                    )
                }

                if let website = company.website,
                   !website.isEmpty {
                    infoRow(
                        icon: "globe",
                        title: "Website",
                        value: website
                    )
                }
            }
        }
    }

    private func descriptionSection(
        _ description: String
    ) -> some View {
        sectionCard {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.small
            ) {
                Text("Über uns")
                    .font(.headline)
                    .foregroundStyle(ZAZUColors.textPrimary)

                Text(description)
                    .font(.body)
                    .foregroundStyle(ZAZUColors.textPrimary)
            }
        }
    }

    private func infoRow(
        icon: String,
        title: String,
        value: String
    ) -> some View {
        HStack(
            alignment: .top,
            spacing: ZAZUSpacing.medium
        ) {
            Image(systemName: icon)
                .foregroundStyle(ZAZUColors.primary)
                .frame(width: 24)

            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.xSmall
            ) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(ZAZUColors.textSecondary)

                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(ZAZUColors.textPrimary)
            }
        }
    }

    private func sectionCard<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(ZAZUSpacing.medium)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .background(ZAZUColors.white)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: ZAZURadius.medium
                )
            )
            .shadow(
                color: .black.opacity(0.04),
                radius: 8,
                y: 3
            )
    }
}
