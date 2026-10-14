//
//  EmployerCompanyEditView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 10.10.2026.
//

import SwiftUI
import PhotosUI
import UIKit

struct EmployerCompanyEditView: View {

    // MARK: - Dependencies

    @Bindable var viewModel: EmployerCompanyViewModel

    let companyRepository: CompanyRepository
    let imageStorageService: CompanyImageStorageService

    @Environment(\.dismiss) private var dismiss

    // MARK: - Logo State

    @State private var selectedLogoItem: PhotosPickerItem?
    @State private var selectedLogoImage: UIImage?

    @State private var logoSelectionError: String?
    @State private var logoUploadError: String?

    @State private var isUploadingLogo = false
    @State private var isRemovingLogo = false
    @State private var showRemoveLogoConfirmation = false

    // MARK: - Banner State

    @State private var selectedBannerItem: PhotosPickerItem?
    @State private var selectedBannerImage: UIImage?

    @State private var bannerError: String?
    @State private var isUploadingBanner = false
    
    @State private var showRemoveBannerConfirmation = false
    @State private var isRemovingBanner = false

    // MARK: - Body

    var body: some View {
        ZStack {
            ZAZUColors.veryLightPurple
                .ignoresSafeArea()

            ScrollView {
                VStack(
                    alignment: .leading,
                    spacing: ZAZUSpacing.large
                ) {
                    bannerSection
                    logoSection

                    EmployerCompanyForm(
                        companyName: $viewModel.name,
                        industry: $viewModel.industry,
                        companySize: $viewModel.companySize,
                        legalForm: $viewModel.legalForm,
                        selectedLocation: $viewModel.selectedLocation,
                        website: $viewModel.website,
                        description: $viewModel.description,

                        // Firmenadresse
                        addressStreet: $viewModel.addressStreet,
                        addressHouseNumber: $viewModel.addressHouseNumber,
                        addressPostalCode: $viewModel.addressPostalCode,
                        addressCity: $viewModel.addressCity,

                        // Kontaktperson
                        contactFirstName: $viewModel.contactFirstName,
                        contactLastName: $viewModel.contactLastName,
                        contactEmail: $viewModel.contactEmail,
                        contactPhone: $viewModel.contactPhone
                    )

                    saveButton
                }
                .padding(ZAZUSpacing.large)
            }
        }
        .navigationTitle("Profil bearbeiten")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Banner Section

    private var bannerSection: some View {
        VStack(spacing: ZAZUSpacing.medium) {

            Text("Firmenbanner")
                .font(.headline)
                .foregroundStyle(ZAZUColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                CompanyBannerView(
                    headerImagePath: viewModel.company?.headerImagePath,
                    imageStorageService: imageStorageService,
                    revision: viewModel.bannerRevision
                )

                if let selectedBannerImage {
                    GeometryReader { geometry in
                        Image(uiImage: selectedBannerImage)
                            .resizable()
                            .scaledToFill()
                            .frame(
                                width: geometry.size.width,
                                height: geometry.size.height
                            )
                            .clipped()
                    }
                }
            }
            .frame(height: 160)
            .frame(maxWidth: .infinity)
            .clipShape(
                RoundedRectangle(cornerRadius: ZAZURadius.medium)
            )

            PhotosPicker(
                selection: $selectedBannerItem,
                matching: .images
            ) {
                Label(
                    "Firmenbanner auswählen",
                    systemImage: "photo.on.rectangle"
                )
                .fontWeight(.semibold)
                .foregroundStyle(ZAZUColors.primary)
            }
            .disabled(isUploadingBanner || isRemovingBanner)

            if selectedBannerImage != nil {
                Button {
                    Task {
                        await uploadSelectedBanner()
                    }
                } label: {
                    Group {
                        if isUploadingBanner {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Banner speichern")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                }
                .foregroundStyle(.white)
                .background(ZAZUColors.primary)
                .clipShape(
                    RoundedRectangle(cornerRadius: ZAZURadius.medium)
                )
                .disabled(isUploadingBanner || isRemovingBanner)
            }
            
            
            if viewModel.company?.headerImagePath != nil {
                Button(role: .destructive) {
                    showRemoveBannerConfirmation = true
                } label: {
                    Label(
                        "Firmenbanner entfernen",
                        systemImage: "trash"
                    )
                    .fontWeight(.medium)
                }
                .disabled(isUploadingBanner || isRemovingBanner)

                if isRemovingBanner {
                    ProgressView("Firmenbanner wird entfernt …")
                        .tint(ZAZUColors.primary)
                }
            }

            if let bannerError {
                Text(bannerError)
                    .font(.footnote)
                    .foregroundStyle(ZAZUColors.danger)
            }

            Text("Empfohlenes Bildformat: 3:1 · maximal 5 MB")
                .font(.caption)
                .foregroundStyle(ZAZUColors.textSecondary)
        }
        .padding(ZAZUSpacing.large)
        .frame(maxWidth: .infinity)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(cornerRadius: ZAZURadius.medium)
        )
        .onChange(of: selectedBannerItem) { _, newItem in
            Task {
                await loadSelectedBanner(from: newItem)
            }
        }
        .confirmationDialog(
            "Firmenbanner entfernen?",
            isPresented: $showRemoveBannerConfirmation,
            titleVisibility: .visible
        ) {
            Button("Banner entfernen", role: .destructive) {
                Task {
                    await removeCompanyBanner()
                }
            }

            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text(
                "Anschliessend wird wieder das violette Standardbanner angezeigt."
            )
        }
    }

    // MARK: - Logo Section

    private var logoSection: some View {
        VStack(spacing: ZAZUSpacing.medium) {

            if let selectedLogoImage {
                Image(uiImage: selectedLogoImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 96, height: 96)
                    .clipShape(Circle())

            } else if let companyId = viewModel.company?.id {
                CompanyAvatarView(
                    companyId: companyId,
                    size: 96,
                    logoPath: viewModel.company?.logoPath,
                    imageStorageService: imageStorageService,
                    revision: viewModel.logoRevision
                )

            } else {
                Image(systemName: "building.2.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(ZAZUColors.primary)
                    .frame(width: 96, height: 96)
                    .background(ZAZUColors.lightPurple)
                    .clipShape(Circle())
            }

            PhotosPicker(
                selection: $selectedLogoItem,
                matching: .images
            ) {
                Label(
                    "Firmenlogo auswählen",
                    systemImage: "photo.on.rectangle"
                )
                .fontWeight(.semibold)
                .foregroundStyle(ZAZUColors.primary)
            }
            .disabled(isUploadingLogo || isRemovingLogo)

            if selectedLogoImage != nil {
                Button {
                    Task {
                        await uploadSelectedLogo()
                    }
                } label: {
                    Group {
                        if isUploadingLogo {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Logo speichern")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                }
                .foregroundStyle(.white)
                .background(ZAZUColors.primary)
                .clipShape(
                    RoundedRectangle(cornerRadius: ZAZURadius.medium)
                )
                .disabled(isUploadingLogo || isRemovingLogo)
            }

            if viewModel.company?.logoPath != nil {
                Button(role: .destructive) {
                    showRemoveLogoConfirmation = true
                } label: {
                    Label(
                        "Firmenlogo entfernen",
                        systemImage: "trash"
                    )
                    .fontWeight(.medium)
                }
                .disabled(isUploadingLogo || isRemovingLogo)

                if isRemovingLogo {
                    ProgressView("Firmenlogo wird entfernt …")
                        .tint(ZAZUColors.primary)
                }
            }

            if let logoUploadError {
                Text(logoUploadError)
                    .font(.footnote)
                    .foregroundStyle(ZAZUColors.danger)
            }

            if let logoSelectionError {
                Text(logoSelectionError)
                    .font(.footnote)
                    .foregroundStyle(ZAZUColors.danger)
            }

            Text("JPG, PNG oder WebP · maximal 5 MB nach Verarbeitung")
                .font(.caption)
                .foregroundStyle(ZAZUColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(ZAZUSpacing.large)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(cornerRadius: ZAZURadius.medium)
        )
        .onChange(of: selectedLogoItem) { _, newItem in
            Task {
                await loadSelectedLogo(from: newItem)
            }
        }
        .confirmationDialog(
            "Firmenlogo entfernen?",
            isPresented: $showRemoveLogoConfirmation,
            titleVisibility: .visible
        ) {
            Button("Logo entfernen", role: .destructive) {
                Task {
                    await removeCompanyLogo()
                }
            }

            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text(
                "Anschliessend wird wieder dein automatisch generierter DiceBear-Avatar angezeigt."
            )
        }
    }
    
    
    @MainActor
    private func removeCompanyBanner() async {
        guard let company = viewModel.company else {
            bannerError = "Unternehmen nicht geladen."
            return
        }

        guard let bannerPath = company.headerImagePath else {
            bannerError = "Kein gespeichertes Firmenbanner gefunden."
            return
        }

        isRemovingBanner = true
        bannerError = nil

        defer {
            isRemovingBanner = false
        }

        do {
            // 1. Datenbankreferenz entfernen
            try await companyRepository.clearCompanyHeaderImagePath(
                companyId: company.id
            )

            // 2. Unternehmensdaten aktualisieren
            await viewModel.load()

            // 3. Vorschau zurücksetzen
            selectedBannerItem = nil
            selectedBannerImage = nil

            // 4. Banneransicht aktualisieren
            viewModel.bannerRevision += 1

            // 5. Datei aus Supabase Storage löschen
            try await imageStorageService.deleteImage(
                path: bannerPath
            )

        } catch {
            bannerError = "Banner entfernen fehlgeschlagen: \(error.localizedDescription)"
        }
    }

    // MARK: - Banner Actions

    @MainActor
    private func loadSelectedBanner(
        from item: PhotosPickerItem?
    ) async {
        bannerError = nil

        guard let item else {
            selectedBannerImage = nil
            return
        }

        do {
            guard
                let data = try await item.loadTransferable(type: Data.self),
                let image = UIImage(data: data)
            else {
                bannerError = "Das ausgewählte Banner konnte nicht geladen werden."
                return
            }

            selectedBannerImage = image

        } catch {
            bannerError = "Banner konnte nicht geladen werden: \(error.localizedDescription)"
        }
    }

    @MainActor
    private func uploadSelectedBanner() async {
        guard
            let companyId = viewModel.company?.id,
            let image = selectedBannerImage
        else {
            return
        }

        isUploadingBanner = true
        bannerError = nil

        defer {
            isUploadingBanner = false
        }

        do {
            guard let jpegData = image.jpegData(
                compressionQuality: 0.8
            ) else {
                bannerError = "Das Banner konnte nicht verarbeitet werden."
                return
            }

            let uploadedPath = try await imageStorageService.uploadImage(
                data: jpegData,
                companyId: companyId,
                type: .header
            )

            try await companyRepository.updateCompanyImagePath(
                companyId: companyId,
                path: uploadedPath,
                field: .header
            )

            // Unternehmensdaten aktualisieren
            await viewModel.load()

            // Gespeichertes Banner neu laden
            viewModel.bannerRevision += 1

            // Auswahl zurücksetzen
            selectedBannerItem = nil
            selectedBannerImage = nil

        } catch {
            bannerError = "Banner konnte nicht gespeichert werden: \(error.localizedDescription)"
        }
    }

    // MARK: - Logo Actions

    @MainActor
    private func loadSelectedLogo(
        from item: PhotosPickerItem?
    ) async {
        logoSelectionError = nil

        guard let item else {
            selectedLogoImage = nil
            return
        }

        do {
            guard
                let data = try await item.loadTransferable(type: Data.self),
                let image = UIImage(data: data)
            else {
                logoSelectionError = "Das ausgewählte Bild konnte nicht geladen werden."
                return
            }

            selectedLogoImage = image

        } catch {
            logoSelectionError = "Das Bild konnte nicht geladen werden: \(error.localizedDescription)"
        }
    }

    @MainActor
    private func uploadSelectedLogo() async {
        guard
            let companyId = viewModel.company?.id,
            let image = selectedLogoImage
        else {
            return
        }

        isUploadingLogo = true
        logoUploadError = nil

        defer {
            isUploadingLogo = false
        }

        do {
            guard let jpegData = image.jpegData(
                compressionQuality: 0.8
            ) else {
                throw LogoUploadError.imageProcessingFailed
            }

            let uploadedPath = try await imageStorageService.uploadImage(
                data: jpegData,
                companyId: companyId,
                type: .logo
            )

            try await companyRepository.updateCompanyImagePath(
                companyId: companyId,
                path: uploadedPath,
                field: .logo
            )

            await viewModel.load()
            viewModel.logoRevision += 1

            selectedLogoItem = nil
            selectedLogoImage = nil

        } catch {
            logoUploadError = error.localizedDescription
        }
    }

    @MainActor
    private func removeCompanyLogo() async {
        guard let company = viewModel.company else {
            logoUploadError = "Unternehmen nicht geladen."
            return
        }

        guard let logoPath = company.logoPath else {
            logoUploadError = "Kein gespeichertes Firmenlogo gefunden."
            return
        }

        isRemovingLogo = true
        logoUploadError = nil

        defer {
            isRemovingLogo = false
        }

        do {
            try await companyRepository.clearCompanyLogoPath(
                companyId: company.id
            )

            await viewModel.load()

            selectedLogoItem = nil
            selectedLogoImage = nil

            viewModel.logoRevision += 1

            try await imageStorageService.deleteImage(
                path: logoPath
            )

        } catch {
            logoUploadError = "Logo entfernen fehlgeschlagen: \(error.localizedDescription)"
        }
    }

    // MARK: - Save

    private var saveButton: some View {
        VStack(spacing: ZAZUSpacing.small) {

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(ZAZUColors.danger)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
            }

            Button {
                Task {
                    if await viewModel.save() {
                        dismiss()
                    }
                }
            } label: {
                Group {
                    if viewModel.isSaving {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Änderungen speichern")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .background(
                viewModel.canSave
                    ? ZAZUColors.primary
                    : ZAZUColors.textSecondary.opacity(0.4)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: ZAZURadius.medium)
            )
            .disabled(!viewModel.canSave || viewModel.isSaving)
        }
    }

    // MARK: - Errors

    private enum LogoUploadError: LocalizedError {
        case imageProcessingFailed

        var errorDescription: String? {
            switch self {
            case .imageProcessingFailed:
                return "Das Firmenlogo konnte nicht verarbeitet werden."
            }
        }
    }
}
