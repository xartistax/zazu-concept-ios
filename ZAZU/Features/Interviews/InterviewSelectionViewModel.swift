//
//  InterviewSelectionViewModel.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 03.10.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class InterviewSelectionViewModel {
    private let interviewRepository: InterviewRepository
    let match: Match

    var slots: [InterviewSlot] = []
    var interview: Interview?

    var isLoading = false
    var isConfirming = false
    var errorMessage: String?

    init(
        interviewRepository: InterviewRepository,
        match: Match
    ) {
        self.interviewRepository = interviewRepository
        self.match = match
    }

    var selectedSlot: InterviewSlot? {
        guard let interview else {
            return nil
        }

        return slots.first {
            $0.id == interview.interviewSlotId
        }
    }

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            async let slotsTask =
                interviewRepository.fetchSlots(
                    matchId: match.id
                )

            async let interviewTask =
                interviewRepository.fetchInterview(
                    matchId: match.id
                )

            let (
                loadedSlots,
                loadedInterview
            ) = try await (
                slotsTask,
                interviewTask
            )

            slots = loadedSlots
            interview = loadedInterview
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func select(
        _ slot: InterviewSlot
    ) async -> Bool {
        isConfirming = true
        errorMessage = nil

        do {
            _ = try await interviewRepository.selectSlot(
                matchId: match.id,
                slotId: slot.id
            )

            interview = try await interviewRepository.fetchInterview(
                matchId: match.id
            )

            isConfirming = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isConfirming = false
            return false
        }
    }
}
