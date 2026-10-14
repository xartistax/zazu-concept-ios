import SwiftUI

struct LocationPickerView: View {
    @Binding var selectedLocation: SelectedLocation?

    @State private var searchText = ""
    @State private var results: [SelectedLocation] = []
    @State private var isSearching = false
    @State private var errorMessage: String?

    private let searchService = LocationSearchService()

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            locationField

            if isSearching {
                ProgressView("Orte werden gesucht …")
                    .tint(ZAZUColors.primary)
                    .font(.footnote)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(ZAZUColors.danger)
            }

            if !results.isEmpty {
                searchResults
            }

            if selectedLocation == nil {
                Text("Bitte wähle einen Ort aus den Suchergebnissen aus.")
                    .font(.footnote)
                    .foregroundStyle(ZAZUColors.textSecondary)
            }
        }
    }

    // MARK: - Eingabefeld

    private var locationField: some View {
        HStack(spacing: ZAZUSpacing.small) {
            Image(systemName: "mappin.and.ellipse")
                .foregroundStyle(ZAZUColors.primary)

            if let selectedLocation {
                Text(selectedLocation.name)
                    .foregroundStyle(ZAZUColors.textPrimary)
                    .fontWeight(.medium)

                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(ZAZUColors.success)

                Button {
                    clearSelection()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(ZAZUColors.textSecondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Standort entfernen")
            } else {
                TextField(
                    "Standort suchen …",
                    text: $searchText
                )
                .foregroundStyle(ZAZUColors.textPrimary)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .onChange(of: searchText) { _, newValue in
                    results = []
                    errorMessage = nil

                    if !newValue.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ).isEmpty {
                        selectedLocation = nil
                    }
                }
                .task(id: searchText) {
                    await searchLocations()
                }
            }
        }
        .padding(ZAZUSpacing.medium)
        .frame(minHeight: 52)
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: ZAZURadius.medium
            )
        )
    }

    // MARK: - Suchergebnisse

    private var searchResults: some View {
        VStack(spacing: 0) {
            ForEach(results) { location in
                Button {
                    selectLocation(location)
                } label: {
                    HStack(spacing: ZAZUSpacing.small) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundStyle(ZAZUColors.primary)

                        Text(location.name)
                            .foregroundStyle(ZAZUColors.textPrimary)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundStyle(ZAZUColors.textSecondary)
                    }
                    .padding(ZAZUSpacing.medium)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if location.id != results.last?.id {
                    Divider()
                }
            }
        }
        .background(ZAZUColors.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: ZAZURadius.medium
            )
        )
    }

    // MARK: - Suche

    @MainActor
    private func searchLocations() async {
        let query = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard query.count >= 2 else {
            results = []
            isSearching = false
            return
        }

        do {
            try await Task.sleep(for: .milliseconds(100))
            try Task.checkCancellation()

            isSearching = true
            errorMessage = nil

            let locations = try await searchService.search(
                query: query
            )

            try Task.checkCancellation()

            results = locations
        } catch is CancellationError {
            return
        } catch {
            results = []
            errorMessage = "Die Ortssuche ist momentan nicht verfügbar."
        }

        isSearching = false
    }

    // MARK: - Auswahl

    private func selectLocation(_ location: SelectedLocation) {
        searchText = ""
        results = []
        selectedLocation = location
    }

    private func clearSelection() {
        selectedLocation = nil
        searchText = ""
        results = []
        errorMessage = nil
    }
}
