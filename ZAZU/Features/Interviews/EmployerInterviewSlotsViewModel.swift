//
//  EmployerInterviewSlotsViewModel.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 10.10.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class EmployerInterviewSlotsViewModel {
    private let interviewRepository: InterviewRepository
    private let matchId: UUID

    var slots: [InterviewSlot] = []
    var confirmedInterview: Interview?
    var candidateContact: CandidateContact?

    var isLoading = false
    var isSaving = false
    var errorMessage: String?

    init(
        interviewRepository: InterviewRepository,
        matchId: UUID
    ) {
        self.interviewRepository = interviewRepository
        self.matchId = matchId
    }

    func load() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            async let slotsTask =
                interviewRepository.fetchEmployerSlots(
                    matchId: matchId
                )

            async let interviewTask =
                interviewRepository.fetchEmployerInterview(
                    matchId: matchId
                )

            let (
                loadedSlots,
                loadedInterview
            ) = try await (
                slotsTask,
                interviewTask
            )

            slots = loadedSlots
            confirmedInterview = loadedInterview

            // Kontaktdaten erst nach bestätigtem Interview laden.
            if loadedInterview != nil {
                candidateContact =
                    try await interviewRepository
                        .fetchConfirmedCandidateContact(
                            matchId: matchId
                        )
            } else {
                candidateContact = nil
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
 
    func createSlot(
        startsAt: Date,
        endsAt: Date
    ) async -> Bool {
        guard endsAt > startsAt else {
            errorMessage = "Die Endzeit muss nach der Startzeit liegen."
            return false
        }

        guard startsAt > Date() else {
            errorMessage = "Der Interviewtermin muss in der Zukunft liegen."
            return false
        }

        guard confirmedInterview == nil else {
            errorMessage = "Der Interviewtermin wurde bereits bestätigt."
            return false
        }

        isSaving = true
        errorMessage = nil

        defer {
            isSaving = false
        }

        do {
            _ = try await interviewRepository.createEmployerSlot(
                matchId: matchId,
                startsAt: startsAt,
                endsAt: endsAt
            )

            slots = try await interviewRepository.fetchEmployerSlots(
                matchId: matchId
            )
            
            
            
           

            return true
        } catch {
           
            errorMessage = error.localizedDescription
            return false
        }
    }
}
