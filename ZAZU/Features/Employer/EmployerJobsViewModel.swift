//
//  EmployerJobsViewModel.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 07.10.2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class EmployerJobsViewModel {
    var jobs: [Job] = []
    var isLoading = false
    var errorMessage: String?

    private(set) var companyId: UUID?

    private let userId: UUID
    private let companyRepository: CompanyRepository
    private let jobRepository: JobRepository

    init(
        userId: UUID,
        companyRepository: CompanyRepository,
        jobRepository: JobRepository
    ) {
        self.userId = userId
        self.companyRepository = companyRepository
        self.jobRepository = jobRepository
    }
    
    func setActiveStatus(
        for job: Job,
        isActive: Bool
    ) async {
        errorMessage = nil

        do {
            try await jobRepository.updateActiveStatus(
                jobId: job.id,
                isActive: isActive
            )

            await loadJobs()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadJobs() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            guard let membership =
                    try await companyRepository.fetchOwnMembership(
                        userId: userId
                    ) else {
                jobs = []
                companyId = nil
                errorMessage = "Dein Unternehmen konnte nicht gefunden werden."
                return
            }

            companyId = membership.companyId

            jobs = try await jobRepository.fetchJobs(
                companyId: membership.companyId
            )

        } catch {
            jobs = []
            errorMessage = error.localizedDescription
        }
    }
}
