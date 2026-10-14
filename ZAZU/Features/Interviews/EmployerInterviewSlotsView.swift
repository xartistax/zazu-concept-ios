//
//  EmployerInterviewSlotsView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 10.10.2026.
//

import SwiftUI

struct EmployerInterviewSlotsView: View {
    @State private var viewModel: EmployerInterviewSlotsViewModel

    @State private var startsAt: Date
    @State private var endsAt: Date

    init(
        interviewRepository: InterviewRepository,
        matchId: UUID
    ) {
        _viewModel = State(
            initialValue: EmployerInterviewSlotsViewModel(
                interviewRepository: interviewRepository,
                matchId: matchId
            )
        )

        let calendar = Calendar.current
        let initialStart =
            calendar.date(
                byAdding: .day,
                value: 1,
                to: Date()
            ) ?? Date()

        let initialEnd =
            calendar.date(
                byAdding: .hour,
                value: 1,
                to: initialStart
            ) ?? initialStart

        _startsAt = State(initialValue: initialStart)
        _endsAt = State(initialValue: initialEnd)
    }

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.large
            ) {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(ZAZUColors.primary)
                } else {
                    content
                }
            }
            .padding(ZAZUSpacing.medium)
        }
        .background(ZAZUColors.veryLightPurple)
        .navigationTitle("Interview")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.confirmedInterview != nil {
            confirmedState
        } else {
            createSlotSection
            existingSlotsSection
        }

        if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .font(.footnote)
                .foregroundStyle(ZAZUColors.danger)
        }
    }

    private var createSlotSection: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            Text("Termin vorschlagen")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(ZAZUColors.textPrimary)

            Text(
                "Schlage dem Kandidaten mehrere passende Interviewtermine vor."
            )
            .font(.subheadline)
            .foregroundStyle(ZAZUColors.textSecondary)

            DatePicker(
                "Start",
                selection: $startsAt,
                in: Date()...,
                displayedComponents: [.date, .hourAndMinute]
            )

            DatePicker(
                "Ende",
                selection: $endsAt,
                in: startsAt...,
                displayedComponents: [.date, .hourAndMinute]
            )

            Button {
                Task {
                    let didCreate = await viewModel.createSlot(
                        startsAt: startsAt,
                        endsAt: endsAt
                    )

                    if didCreate {
                        prepareNextSlot()
                    }
                }
            } label: {
                HStack {
                    if viewModel.isSaving {
                        ProgressView()
                            .tint(ZAZUColors.white)
                    }

                    Text(
                        viewModel.isSaving
                            ? "Wird gespeichert ..."
                            : "Termin hinzufügen"
                    )
                    .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundStyle(ZAZUColors.white)
                .background(ZAZUColors.primary)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: ZAZURadius.medium
                    )
                )
            }
            .disabled(viewModel.isSaving)
        }
        .padding(ZAZUSpacing.medium)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: ZAZURadius.medium
            )
        )
    }

    @ViewBuilder
    private var existingSlotsSection: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            Text("Vorgeschlagene Termine")
                .font(.headline)
                .foregroundStyle(ZAZUColors.textPrimary)

            if viewModel.slots.isEmpty {
                Text("Noch keine Termine vorgeschlagen.")
                    .font(.subheadline)
                    .foregroundStyle(ZAZUColors.textSecondary)
            } else {
                ForEach(viewModel.slots) { slot in
                    slotRow(slot)
                }
            }
        }
    }

    private func slotRow(
        _ slot: InterviewSlot
    ) -> some View {
        HStack(spacing: ZAZUSpacing.medium) {
            Image(systemName: "calendar")
                .foregroundStyle(ZAZUColors.primary)

            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.xSmall
            ) {
                Text(
                    slot.startsAt.formatted(
                        date: .abbreviated,
                        time: .shortened
                    )
                )
                .font(.headline)
                .foregroundStyle(ZAZUColors.textPrimary)

                Text(
                    "bis \(slot.endsAt.formatted(date: .omitted, time: .shortened))"
                )
                .font(.subheadline)
                .foregroundStyle(ZAZUColors.textSecondary)
            }

            Spacer()
        }
        .padding(ZAZUSpacing.medium)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: ZAZURadius.medium
            )
        )
    }

    private var confirmedState: some View {
        VStack(spacing: ZAZUSpacing.medium) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(ZAZUColors.success)

            Text("Interview bestätigt")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(ZAZUColors.textPrimary)

            Text(
                "Der Kandidat hat einen Interviewtermin ausgewählt."
            )
            .font(.subheadline)
            .foregroundStyle(ZAZUColors.textSecondary)
            .multilineTextAlignment(.center)

            if let interview = viewModel.confirmedInterview,
               let slot = viewModel.slots.first(
                   where: {
                       $0.id == interview.interviewSlotId
                   }
               ) {
                Divider()

                VStack(spacing: ZAZUSpacing.small) {
                    Text(
                        slot.startsAt,
                        format: .dateTime
                            .weekday(.wide)
                            .day()
                            .month(.wide)
                            .year()
                    )
                    .font(.headline)
                    .foregroundStyle(ZAZUColors.textPrimary)

                    Text(
                        "\(slot.startsAt.formatted(date: .omitted, time: .shortened)) – \(slot.endsAt.formatted(date: .omitted, time: .shortened)) Uhr"
                    )
                    .foregroundStyle(ZAZUColors.textSecondary)
                    
                    
                    if let contact = viewModel.candidateContact {
                        Divider()

                        VStack(
                            alignment: .leading,
                            spacing: ZAZUSpacing.small
                        ) {
                            Text("Kontakt")
                                .font(.headline)
                                .foregroundStyle(ZAZUColors.textPrimary)

                            if !contact.fullName.isEmpty {
                                Label(
                                    contact.fullName,
                                    systemImage: "person.fill"
                                )
                                .foregroundStyle(ZAZUColors.textPrimary)
                            }

                            if let phoneNumber = contact.phoneNumber,
                               !phoneNumber.isEmpty {
                                Label(
                                    phoneNumber,
                                    systemImage: "phone.fill"
                                )
                                .foregroundStyle(ZAZUColors.textPrimary)
                            }
                        }
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .padding(.top, ZAZUSpacing.small)
                    }
                }
                .padding(.top, ZAZUSpacing.small)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(ZAZUSpacing.large)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: ZAZURadius.medium
            )
        )
    }

    private func prepareNextSlot() {
        let calendar = Calendar.current

        startsAt =
            calendar.date(
                byAdding: .day,
                value: 1,
                to: startsAt
            ) ?? startsAt

        endsAt =
            calendar.date(
                byAdding: .hour,
                value: 1,
                to: startsAt
            ) ?? startsAt
    }
}
