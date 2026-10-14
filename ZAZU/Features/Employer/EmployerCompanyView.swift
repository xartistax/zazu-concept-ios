//
//  EmployerCompanyView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 09.10.2026.
//

import SwiftUI
import Supabase

struct EmployerCompanyView: View {
    @Bindable var appState: AppState

    let authenticationService: AuthenticationService
    let supabaseClient: SupabaseClient
    let accountSwitcher: PoCAccountSwitcher
    let companyRepository: CompanyRepository
    let userId: UUID

    @State private var viewModel: EmployerCompanyViewModel
    @State private var isSigningOut = false
    @State private var signOutErrorMessage: String?
    @State private var isAvatarReady = false
    @State private var bannerImage: UIImage?
    @State private var isLoadingBanner = false

    init(
        appState: AppState,
        authenticationService: AuthenticationService,
        supabaseClient: SupabaseClient,
        accountSwitcher: PoCAccountSwitcher,
        companyRepository: CompanyRepository,
        userId: UUID
    ) {
        self.appState = appState
        self.authenticationService = authenticationService
        self.supabaseClient = supabaseClient
        self.accountSwitcher = accountSwitcher
        self.companyRepository = companyRepository
        self.userId = userId

        _viewModel = State(
            initialValue: EmployerCompanyViewModel(
                companyRepository: companyRepository,
                userId: userId
            )
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ZAZUColors.veryLightPurple
                    .ignoresSafeArea()

                content
            }
            .navigationTitle("Unternehmen")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        EmployerCompanyEditView(
                            viewModel: viewModel,
                            companyRepository: companyRepository,
                            imageStorageService: CompanyImageStorageService(
                                client: supabaseClient
                            )
                        )
                    } label: {
                        Text("Bearbeiten")
                            .fontWeight(.semibold)
                    }
                    .disabled(viewModel.company == nil)
                }
            }
            .task {
                if viewModel.company == nil {
                    await viewModel.load()
                }
            }        }
    }

    @ViewBuilder
    private var content: some View {
        ZStack {
            if let companyId = viewModel.company?.id {
                CompanyAvatarView(
                    companyId: companyId,
                    logoPath: viewModel.company?.logoPath,
                    imageStorageService: CompanyImageStorageService(
                        client: supabaseClient
                    ),
                    onLoadComplete: {
                        isAvatarReady = true
                    }, revision: viewModel.logoRevision
                )
                .frame(width: 1, height: 1)
                .opacity(0)
                .accessibilityHidden(true)
            }

            if viewModel.company == nil && viewModel.errorMessage != nil {
                VStack(spacing: ZAZUSpacing.medium) {
                    Text(viewModel.errorMessage ?? "Profil konnte nicht geladen werden.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(ZAZUColors.danger)

                    Button("Erneut versuchen") {
                        Task {
                            isAvatarReady = false
                            await viewModel.load()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(ZAZUColors.primary)
                }
                .padding(ZAZUSpacing.large)

            } else if viewModel.isLoading || !isAvatarReady {
                ProgressView("Unternehmensprofil wird geladen …")
                    .tint(ZAZUColors.primary)
            } else if let errorMessage = viewModel.errorMessage,
                      viewModel.company == nil {
                Text(errorMessage)
                    .foregroundStyle(ZAZUColors.danger)
            } else {
                profileContent
            }
        }
    }
    
    
    private var companyProfileSkeleton: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ZAZUSpacing.large) {

                // Header
                VStack(spacing: ZAZUSpacing.medium) {
                    Circle()
                        .fill(ZAZUColors.lightPurple)
                        .frame(width: 80, height: 80)

                    skeletonLine(width: 220, height: 24)
                    skeletonLine(width: 160, height: 16)
                }
                .frame(maxWidth: .infinity)

                skeletonCard(lineWidths: [0.55, 1.0, 1.0, 1.0])

                skeletonCard(lineWidths: [0.55, 1.0, 1.0])
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(ZAZUSpacing.large)
            .modifier(CompanySkeletonPulse())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityLabel("Unternehmensprofil wird geladen")
    }

    private func skeletonCard(lineWidths: [CGFloat]) -> some View {
        VStack(alignment: .leading, spacing: ZAZUSpacing.medium) {
            ForEach(lineWidths.indices, id: \.self) { index in
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(ZAZUColors.lightPurple)
                        .frame(
                            width: geometry.size.width * lineWidths[index],
                            height: index == 0 ? 20 : 16
                        )
                }
                .frame(height: index == 0 ? 20 : 16)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(ZAZUSpacing.medium)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(cornerRadius: ZAZURadius.large)
        )
    }

    private func skeletonLine(
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        RoundedRectangle(cornerRadius: height / 2)
            .fill(ZAZUColors.lightPurple)
            .frame(width: width, height: height)
    }

    private var profileContent: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.large
            ) {
                companyHeader
                companyInformation
                contactInformation
                jobContactsSection
                toolsSection
                signOutSection
            }
            .padding(ZAZUSpacing.large)
        }
    }
    
    
    
    // MARK: - Jobverantwortliche

    @ViewBuilder
    private var jobContactsSection: some View {
        if let companyId = viewModel.company?.id {
            NavigationLink {
                EmployerContactsView(
                    companyId: companyId,
                    supabaseClient: supabaseClient
                )
            } label: {
                HStack(spacing: ZAZUSpacing.medium) {
                    Image(systemName: "person.2.crop.square.stack.fill")
                        .foregroundStyle(ZAZUColors.primary)
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Jobverantwortliche")
                            .font(.headline)
                            .foregroundStyle(ZAZUColors.textPrimary)

                        Text("Kontaktpersonen für Stellen verwalten")
                            .font(.subheadline)
                            .foregroundStyle(ZAZUColors.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(ZAZUColors.textSecondary)
                }
                .padding(ZAZUSpacing.medium)
                .background(ZAZUColors.white)
                .clipShape(
                    RoundedRectangle(cornerRadius: ZAZURadius.large)
                )
            }
        }
    }
    
    // MARK: - Company Banner

    private var companyBanner: some View {
        Group {
            if viewModel.company != nil {
                CompanyBannerView(
                    headerImagePath: viewModel.company?.headerImagePath,
                    imageStorageService: CompanyImageStorageService(
                        client: supabaseClient
                    ),
                    height: 170,
                    revision: viewModel.bannerRevision
                )
            } else {
                RoundedRectangle(cornerRadius: ZAZURadius.large)
                    .fill(ZAZUColors.lightPurple)
                    .frame(height: 170)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityLabel("Unternehmensbanner")
    }

    private var companyHeader: some View {
        VStack(spacing: ZAZUSpacing.small) {

            ZStack(alignment: .bottomLeading) {

                companyBanner

                if let companyId = viewModel.company?.id {
                    CompanyAvatarView(
                        companyId: companyId,
                        size: 88,
                        logoPath: viewModel.company?.logoPath,
                        imageStorageService: CompanyImageStorageService(
                            client: supabaseClient
                        ),
                        revision: viewModel.logoRevision
                    )
                    .padding(4)
                    .background(
                        Circle()
                            .fill(ZAZUColors.white)
                    )
                    .offset(
                        x: ZAZUSpacing.medium,
                        y: 44
                    )
                }
            }
            .padding(.bottom, 44)

            VStack(
                alignment: .leading,
                spacing: ZAZUSpacing.small
            ) {
                Text(viewModel.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(ZAZUColors.textPrimary)

                if !viewModel.industry.isEmpty {
                    Text(viewModel.industry)
                        .font(.subheadline)
                        .foregroundStyle(ZAZUColors.textSecondary)
                }
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        }
        .frame(maxWidth: .infinity)
    }
    private var companyInformation: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            Text("Unternehmensprofil")
                .font(.headline)
                .foregroundStyle(ZAZUColors.textPrimary)

            profileRow(
                icon: "mappin.and.ellipse",
                title: "Firmenadresse",
                value: formattedCompanyAddress
            )

            profileRow(
                icon: "person.3.fill",
                title: "Unternehmensgrösse",
                value: viewModel.companySize
            )

            profileRow(
                icon: "globe",
                title: "Website",
                value: viewModel.website
            )

            if !viewModel.description.isEmpty {
                Divider()

                VStack(
                    alignment: .leading,
                    spacing: ZAZUSpacing.small
                ) {
                    Text("Über uns")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(ZAZUColors.textPrimary)

                    Text(viewModel.description)
                        .font(.subheadline)
                        .foregroundStyle(ZAZUColors.textSecondary)
                }
            }
        }
        .padding(ZAZUSpacing.medium)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: ZAZURadius.large
            )
        )
    }
    
    // MARK: - Firmenadresse

    private var formattedCompanyAddress: String {
        let streetLine = [
            viewModel.addressStreet,
            viewModel.addressHouseNumber
        ]
        .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        .joined(separator: " ")

        let cityLine = [
            viewModel.addressPostalCode,
            viewModel.addressCity
        ]
        .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        .joined(separator: " ")

        let address = [streetLine, cityLine]
            .filter { !$0.isEmpty }
            .joined(separator: "\n")

        return address.isEmpty ? viewModel.location : address
    }

    private var contactInformation: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.medium
        ) {
            Text("Kontaktperson")
                .font(.headline)
                .foregroundStyle(ZAZUColors.textPrimary)

            profileRow(
                icon: "person.fill",
                title: "Name",
                value: [
                    viewModel.contactFirstName,
                    viewModel.contactLastName
                ]
                .filter { !$0.isEmpty }
                .joined(separator: " ")
            )

            profileRow(
                icon: "envelope.fill",
                title: "E-Mail",
                value: viewModel.contactEmail
            )

            profileRow(
                icon: "phone.fill",
                title: "Telefon",
                value: viewModel.contactPhone
            )
        }
        .padding(ZAZUSpacing.medium)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: ZAZURadius.large
            )
        )
    }

    private var toolsSection: some View {
        NavigationLink {
            EmployerPoCToolsView(
                supabaseClient: supabaseClient,
                appState: appState,
                accountSwitcher: accountSwitcher
            )
        } label: {
            HStack {
                Image(systemName: "hammer.fill")

                Text("PoC Tools")

                Spacer()

                Image(systemName: "chevron.right")
            }
            .foregroundStyle(ZAZUColors.textPrimary)
            .padding(ZAZUSpacing.medium)
            .background(ZAZUColors.white)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: ZAZURadius.medium
                )
            )
        }
    }

    // MARK: - Logout

    private var signOutSection: some View {
        VStack(spacing: ZAZUSpacing.small) {
            Button(role: .destructive) {
                Task {
                    await signOut()
                }
            } label: {
                HStack {
                    if isSigningOut {
                        ProgressView()
                            .tint(ZAZUColors.danger)
                    } else {
                        Image(
                            systemName: "rectangle.portrait.and.arrow.right"
                        )
                    }

                    Text(
                        isSigningOut
                            ? "Wird abgemeldet …"
                            : "Abmelden"
                    )
                    .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, ZAZUSpacing.medium)
            }
            .disabled(isSigningOut)

            if let signOutErrorMessage {
                Text(signOutErrorMessage)
                    .font(.caption)
                    .foregroundStyle(ZAZUColors.danger)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    
    @MainActor
    private func loadCompanyBanner() async {
        bannerImage = nil

        guard let path = viewModel.company?.headerImagePath else {
            return
        }

        isLoadingBanner = true
        defer {
            isLoadingBanner = false
        }

        do {
            let data = try await CompanyImageStorageService(
                client: supabaseClient
            ).downloadImage(path: path)

            try Task.checkCancellation()

            guard let image = UIImage(data: data) else {
                return
            }

            bannerImage = image
        } catch is CancellationError {
            return
        } catch {
            print("Firmenbanner konnte nicht geladen werden: \(error)")
        }
    }

    @ViewBuilder
    private func profileRow(
        icon: String,
        title: String,
        value: String
    ) -> some View {
        if !value.isEmpty {
            HStack(alignment: .top, spacing: ZAZUSpacing.medium) {
                Image(systemName: icon)
                    .foregroundStyle(ZAZUColors.primary)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(ZAZUColors.textSecondary)

                    Text(value)
                        .font(.subheadline)
                        .foregroundStyle(ZAZUColors.textPrimary)
                }

                Spacer()
            }
        }
    }

    @MainActor
    private func signOut() async {
        guard !isSigningOut else {
            return
        }

        isSigningOut = true
        signOutErrorMessage = nil

        defer {
            isSigningOut = false
        }

        do {
            try await authenticationService.signOut()
            appState.rootState = .authentication
        } catch {
            signOutErrorMessage = error.localizedDescription
        }
    }
    
    private struct CompanySkeletonPulse: ViewModifier {

        @State private var isPulsing = false

        func body(content: Content) -> some View {
            content
                .opacity(isPulsing ? 0.45 : 1)
                .onAppear {
                    isPulsing = true
                }
                .animation(
                    .easeInOut(duration: 0.9)
                        .repeatForever(autoreverses: true),
                    value: isPulsing
                )
        }
    }
}
