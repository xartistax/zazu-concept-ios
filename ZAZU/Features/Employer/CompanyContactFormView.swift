//
//  CompanyContactFormView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 14.10.2026.
//

import SwiftUI
import Supabase


import PhotosUI
import UIKit

struct CompanyContactFormView: View {

    let companyId: UUID
    let repository: CompanyContactRepository
    let imageStorageService: CompanyImageStorageService

    var contact: CompanyContact? = nil
    var onSaved: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var position = ""
    @State private var email = ""
    @State private var phone = ""

    @State private var isSaving = false
    @State private var errorMessage: String?
    
    
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImageData: Data?

    @State private var currentPortraitPath: String?
    @State private var portraitRevision = 0

    @State private var isUploadingPortrait = false
    @State private var showRemovePortraitConfirmation = false

    private var isEditing: Bool {
        contact != nil
    }

    private var canSave: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !isSaving
    }

    var body: some View {
        Form {
            Section {
                VStack(spacing: 16) {

                    if let selectedImageData,
                       let image = UIImage(data: selectedImageData) {

                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 110, height: 110)
                            .clipShape(Circle())

                    } else if let contact {

                        ContactAvatarView(
                            contactId: contact.id,
                            size: 110,
                            portraitPath: currentPortraitPath,
                            imageStorageService: imageStorageService,
                            revision: portraitRevision
                        )

                    } else {

                        ZStack {
                            Circle()
                                .fill(ZAZUColors.lightPurple)

                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 70))
                                .foregroundStyle(ZAZUColors.primary)
                        }
                        .frame(width: 110, height: 110)
                    }

                    if contact != nil {

                        PhotosPicker(
                            selection: $selectedPhoto,
                            matching: .images
                        ) {
                            Label(
                                "Porträt auswählen",
                                systemImage: "photo.on.rectangle"
                            )
                        }
                        .disabled(isUploadingPortrait)

                        if selectedImageData != nil {

                            Button {
                                Task {
                                    await uploadPortrait()
                                }
                            } label: {
                                if isUploadingPortrait {
                                    ProgressView()
                                } else {
                                    Label(
                                        "Porträt speichern",
                                        systemImage: "square.and.arrow.up"
                                    )
                                }
                            }
                            .disabled(isUploadingPortrait)

                        }

                        if currentPortraitPath != nil {

                            Button(role: .destructive) {
                                showRemovePortraitConfirmation = true
                            } label: {
                                Label(
                                    "Porträt entfernen",
                                    systemImage: "trash"
                                )
                            }
                            .disabled(isUploadingPortrait)
                        }

                    } else {

                        Text("Nach dem Erstellen kannst du ein Porträt hochladen.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .onChange(of: selectedPhoto) { _, newPhoto in
                Task {
                    await loadSelectedPhoto(newPhoto)
                }
            }
            .confirmationDialog(
                "Porträt entfernen?",
                isPresented: $showRemovePortraitConfirmation,
                titleVisibility: .visible
            ) {
                Button("Porträt entfernen", role: .destructive) {
                    Task {
                        await removePortrait()
                    }
                }
            }
            Section("Persönliche Angaben") {
                TextField("Vorname", text: $firstName)
                    .textContentType(.givenName)

                TextField("Nachname", text: $lastName)
                    .textContentType(.familyName)

                TextField("Position / Funktion", text: $position)
                    .textContentType(.jobTitle)
            }

            Section("Kontaktangaben") {
                TextField("Geschäftliche E-Mail", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                TextField("Telefon", text: $phone)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
            }

            Section {
                Button {
                    Task {
                        await saveContact()
                    }
                } label: {
                    HStack {
                        Spacer()

                        if isSaving {
                            ProgressView()
                        } else {
                            Text(isEditing ? "Änderungen speichern" : "Kontaktperson erstellen")
                                .fontWeight(.semibold)
                        }

                        Spacer()
                    }
                }
                .disabled(!canSave)
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(
            isEditing ? "Kontaktperson bearbeiten" : "Neue Kontaktperson"
        )
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            populateFields()
        }
    }

    // MARK: - Initial Values

    private func populateFields() {
        guard let contact else { return }

        firstName = contact.firstName
        lastName = contact.lastName
        position = contact.position ?? ""
        email = contact.email ?? ""
        phone = contact.phone ?? ""
        
        currentPortraitPath = contact.portraitPath
    }

    // MARK: - Save

    @MainActor
    private func saveContact() async {
        guard canSave else { return }

        isSaving = true
        errorMessage = nil

        defer {
            isSaving = false
        }

        do {
            if let contact {
                try await repository.updateContact(
                    id: contact.id,
                    firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                    lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
                    position: optionalValue(position),
                    email: optionalValue(email),
                    phone: optionalValue(phone)
                )
            } else {
                _ = try await repository.createContact(
                    companyId: companyId,
                    firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                    lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
                    position: optionalValue(position),
                    email: optionalValue(email),
                    phone: optionalValue(phone)
                )
            }

            onSaved?()
            dismiss()

        } catch {
            errorMessage = "Kontaktperson konnte nicht gespeichert werden: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Photo Selection

    @MainActor
    private func loadSelectedPhoto(_ item: PhotosPickerItem?) async {
        guard let item else {
            selectedImageData = nil
            return
        }

        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data),
                  let jpegData = image.jpegData(compressionQuality: 0.75) else {
                errorMessage = "Das ausgewählte Bild konnte nicht verarbeitet werden."
                return
            }

            guard jpegData.count <= 5 * 1024 * 1024 else {
                errorMessage = "Das Porträt darf maximal 5 MB gross sein."
                return
            }

            selectedImageData = jpegData
            errorMessage = nil

        } catch {
            errorMessage = "Das Bild konnte nicht geladen werden: \(error.localizedDescription)"
        }
    }

    // MARK: - Portrait Upload

    @MainActor
    private func uploadPortrait() async {
        guard let contact,
              let selectedImageData,
              !isUploadingPortrait else {
            return
        }

        isUploadingPortrait = true
        errorMessage = nil

        defer {
            isUploadingPortrait = false
        }

        do {
            let path = try await imageStorageService.uploadContactPortrait(
                data: selectedImageData,
                companyId: companyId,
                contactId: contact.id
            )

            try await repository.updatePortraitPath(
                contactId: contact.id,
                companyId: companyId,
                path: path
            )

            currentPortraitPath = path
            portraitRevision += 1

            self.selectedImageData = nil
            selectedPhoto = nil

            onSaved?()

        } catch {
            errorMessage = "Das Porträt konnte nicht gespeichert werden: \(error.localizedDescription)"
        }
    }

    // MARK: - Portrait Removal

    @MainActor
    private func removePortrait() async {
        guard let contact,
              let currentPortraitPath,
              !isUploadingPortrait else {
            return
        }

        isUploadingPortrait = true
        errorMessage = nil

        defer {
            isUploadingPortrait = false
        }

        do {
            // Zuerst den Datenbankverweis entfernen.
            try await repository.clearPortraitPath(
                contactId: contact.id,
                companyId: companyId
            )

            self.currentPortraitPath = nil
            portraitRevision += 1

            selectedImageData = nil
            selectedPhoto = nil

            onSaved?()

            // Anschliessend die nicht mehr referenzierte Datei löschen.
            try await imageStorageService.deleteImage(
                path: currentPortraitPath
            )

        } catch {
            errorMessage = "Das Porträt konnte nicht vollständig entfernt werden: \(error.localizedDescription)"
        }
    }

    private func optionalValue(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
