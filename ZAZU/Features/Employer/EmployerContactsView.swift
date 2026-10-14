//
//  EmployerContactsView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 14.10.2026.
//

import SwiftUI
import Supabase

struct EmployerContactsView: View {

    let companyId: UUID
    let supabaseClient: SupabaseClient

    @State private var contacts: [CompanyContact] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    @State private var showingCreateContact = false

    private var repository: CompanyContactRepository {
        CompanyContactRepository(client: supabaseClient)
    }

    private var imageStorageService: CompanyImageStorageService {
        CompanyImageStorageService(client: supabaseClient)
    }

    var body: some View {
        Group {
            if isLoading && contacts.isEmpty {
                ProgressView("Kontaktpersonen werden geladen …")
            } else {
                List {
                    if let errorMessage {
                        Section {
                            Text(errorMessage)
                                .foregroundStyle(ZAZUColors.danger)

                            Button("Erneut versuchen") {
                                Task { await loadContacts() }
                            }
                        }
                    }

                    if contacts.isEmpty && !isLoading && errorMessage == nil {
                        ContentUnavailableView(
                            "Noch keine Jobverantwortlichen",
                            systemImage: "person.crop.circle.badge.plus",
                            description: Text(
                                "Erstelle eine Kontaktperson, die du später einem Job zuweisen kannst."
                            )
                        )
                    }

                    ForEach(contacts) { contact in
                        NavigationLink {
                            CompanyContactFormView(
                                companyId: companyId,
                                repository: repository,
                                imageStorageService: imageStorageService,
                                contact: contact,
                                onSaved: {
                                    Task { await loadContacts() }
                                }
                            )
                        } label: {
                            HStack(spacing: ZAZUSpacing.medium) {
                                ContactAvatarView(
                                    contactId: contact.id,
                                    size: 52,
                                    portraitPath: contact.portraitPath,
                                    imageStorageService: imageStorageService
                                )

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(contact.fullName)
                                        .font(.headline)
                                        .foregroundStyle(ZAZUColors.textPrimary)

                                    if let position = contact.position,
                                       !position.isEmpty {
                                        Text(position)
                                            .font(.subheadline)
                                            .foregroundStyle(ZAZUColors.textSecondary)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .refreshable {
                    await loadContacts()
                }
            }
        }
        .navigationTitle("Jobverantwortliche")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingCreateContact = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Kontaktperson hinzufügen")
            }
        }
        .sheet(isPresented: $showingCreateContact) {
            NavigationStack {
                CompanyContactFormView(
                    companyId: companyId,
                    repository: repository,
                    imageStorageService: imageStorageService,
                    onSaved: {
                        Task { await loadContacts() }
                    }
                )
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Schliessen") {
                            showingCreateContact = false
                        }
                    }
                }
            }
        }
        .task {
            await loadContacts()
        }
    }

    @MainActor
    private func loadContacts() async {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            contacts = try await repository.fetchContacts(
                companyId: companyId
            )
        } catch {
            errorMessage = "Kontaktpersonen konnten nicht geladen werden: \(error.localizedDescription)"
        }
    }
}
