//
//  JobMatchCelebrationView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 03.10.2026.
//

import SwiftUI

struct JobMatchCelebrationView: View {
    let job: Job
    let company: Company?
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            ZAZUColors.primary
                .ignoresSafeArea()

            VStack(spacing: ZAZUSpacing.xLarge) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(ZAZUColors.white.opacity(0.15))
                        .frame(width: 150, height: 150)

                    Circle()
                        .fill(ZAZUColors.white)
                        .frame(width: 105, height: 105)

                    Image(systemName: "heart.fill")
                        .font(.system(size: 46))
                        .foregroundStyle(ZAZUColors.primary)
                }

                VStack(spacing: ZAZUSpacing.medium) {
                    Text("IT’S A JOB MATCH!")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(ZAZUColors.white)

                    Text("Ihr habt euch beide gematcht.")
                        .font(.headline)
                        .foregroundStyle(
                            ZAZUColors.white.opacity(0.85)
                        )
                }

                VStack(spacing: ZAZUSpacing.small) {
                    Text(job.title)
                        .font(.title2)
                        .fontWeight(.bold)

                    if let company {
                        Text(company.name)
                            .font(.headline)
                            .opacity(0.8)
                    }
                }
                .foregroundStyle(ZAZUColors.white)
                .multilineTextAlignment(.center)

                Spacer()

                Button {
                    onContinue()
                } label: {
                    Text("Weiter")
                        .fontWeight(.bold)
                        .foregroundStyle(ZAZUColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, ZAZUSpacing.medium)
                        .background(ZAZUColors.white)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: ZAZURadius.medium
                            )
                        )
                }
            }
            .padding(ZAZUSpacing.xLarge)
        }
    }
}
