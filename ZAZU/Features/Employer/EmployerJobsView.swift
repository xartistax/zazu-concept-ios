//
//  EmployerJobsView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 07.10.2026.
//

import SwiftUI
import Supabase

struct EmployerJobsView: View {
    @State private var viewModel: EmployerJobsViewModel
    @State private var editingJob: Job?

    private let userId: UUID
    private let companyRepository: CompanyRepository
    private let jobRepository: JobRepository
    private let skillRepository: SkillRepository
    private let languageRepository: LanguageRepository
    private let supabaseClient: SupabaseClient

    init(
        userId: UUID,
        companyRepository: CompanyRepository,
        jobRepository: JobRepository,
        skillRepository: SkillRepository,
        languageRepository: LanguageRepository,
        supabaseClient: SupabaseClient
    ) {
        self.userId = userId
        self.companyRepository = companyRepository
        self.jobRepository = jobRepository
        self.skillRepository = skillRepository
        self.languageRepository = languageRepository
        self.supabaseClient = supabaseClient

        _viewModel = State(
            initialValue: EmployerJobsViewModel(
                userId: userId,
                companyRepository: companyRepository,
                jobRepository: jobRepository
            )
        )
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.jobs.isEmpty {
                    ProgressView()
                } else if let errorMessage = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Jobs konnten nicht geladen werden",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                } else if viewModel.jobs.isEmpty {
                    ContentUnavailableView(
                        "Noch keine Jobs",
                        systemImage: "briefcase",
                        description: Text(
                            "Erstelle deinen ersten Job, um passende Kandidaten zu finden."
                        )
                    )
                } else {
                    List(viewModel.jobs) { job in
                        VStack(
                            alignment: .leading,
                            spacing: ZAZUSpacing.medium
                        ) {
                            // MARK: Job öffnen / bearbeiten

                            Button {
                                editingJob = job
                            } label: {
                                HStack(
                                    alignment: .center,
                                    spacing: ZAZUSpacing.medium
                                ) {
                                    VStack(
                                        alignment: .leading,
                                        spacing: ZAZUSpacing.small
                                    ) {
                                        Text(job.title)
                                            .font(.headline)
                                            .foregroundStyle(
                                                ZAZUColors.textPrimary
                                            )

                                        Label(
                                            job.location,
                                            systemImage: "mappin.and.ellipse"
                                        )
                                        .font(.subheadline)
                                        .foregroundStyle(
                                            ZAZUColors.textSecondary
                                        )

                                        HStack {
                                            Text(job.workModel.title)

                                            Text("·")

                                            Text(
                                                "\(job.workloadMin)–\(job.workloadMax) %"
                                            )
                                        }
                                        .font(.caption)
                                        .foregroundStyle(
                                            ZAZUColors.textSecondary
                                        )
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(
                                            ZAZUColors.textSecondary
                                        )
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)

                            Divider()

                            // MARK: Status

                            HStack(spacing: ZAZUSpacing.small) {
                                Circle()
                                    .fill(
                                        job.isActive
                                            ? ZAZUColors.success
                                            : ZAZUColors.textSecondary
                                    )
                                    .frame(width: 8, height: 8)

                                Text(
                                    job.isActive
                                        ? "Aktiv"
                                        : "Inaktiv"
                                )
                                .font(.caption)
                                .fontWeight(.medium)

                                Spacer()

                                Button(
                                    job.isActive
                                        ? "Deaktivieren"
                                        : "Aktivieren"
                                ) {
                                    Task {
                                        await viewModel.setActiveStatus(
                                            for: job,
                                            isActive: !job.isActive
                                        )
                                    }
                                }
                                .font(.caption)
                                .buttonStyle(.borderless)
                                .foregroundStyle(
                                    job.isActive
                                        ? ZAZUColors.textSecondary
                                        : ZAZUColors.primary
                                )
                            }
                        }
                        .padding(.vertical, ZAZUSpacing.xSmall)
                        .swipeActions(
                            edge: .trailing,
                            allowsFullSwipe: false
                        ) {
                            Button {
                                editingJob = job
                            } label: {
                                Label(
                                    "Bearbeiten",
                                    systemImage: "pencil"
                                )
                            }
                            .tint(ZAZUColors.primary)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Jobs")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        EmployerJobFormView(
                            userId: userId,
                            companyRepository: companyRepository,
                            jobRepository: jobRepository,
                            skillRepository: skillRepository,
                            languageRepository: languageRepository,
                            supabaseClient: supabaseClient
                        )
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .task {
                await viewModel.loadJobs()
            }
            .refreshable {
                await viewModel.loadJobs()
            }
            .sheet(
                item: $editingJob,
                onDismiss: {
                    Task {
                        await viewModel.loadJobs()
                    }
                }
            ) { job in
                NavigationStack {
                    EmployerJobFormView(
                        userId: userId,
                        companyRepository: companyRepository,
                        jobRepository: jobRepository,
                        skillRepository: skillRepository,
                        languageRepository: languageRepository,
                        editingJob: job, supabaseClient: supabaseClient
                    )
                }
            }
        }
    }
}
