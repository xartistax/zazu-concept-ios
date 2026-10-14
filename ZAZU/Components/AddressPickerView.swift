//
//  AddressPickerView.swift
//  ZAZU
//
//  Created by Demian Füglistaler on 13.10.2026.
//


import SwiftUI

struct AddressPickerView: View {
    
    @Binding var selectedAddress: SelectedAddress?

    
    @State private var searchText = ""
    @State private var autocomplete = AddressAutocompleteService()
    @State private var isResolvingAddress = false
    @State private var selectionError: String?

    private let searchService = LocationSearchService()
    
    // MARK: - Body
    
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: ZAZUSpacing.small
        ) {
            addressField
            
            if autocomplete.isSearching {
                ProgressView("Adressvorschläge werden gesucht …")
                    .tint(ZAZUColors.primary)
                    .font(.footnote)
            }

            if isResolvingAddress {
                ProgressView("Adresse wird überprüft …")
                    .tint(ZAZUColors.primary)
                    .font(.footnote)
            }

            if let selectionError {
                Text(selectionError)
                    .font(.footnote)
                    .foregroundStyle(ZAZUColors.danger)
            }
            if let errorMessage = autocomplete.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(ZAZUColors.danger)
            }
            
            if !autocomplete.suggestions.isEmpty {
                searchResults
            }
            
            if selectedAddress == nil {
                Text(
                    "Bitte wähle eine vollständige Adresse aus den Suchergebnissen aus."
                )
                .font(.footnote)
                .foregroundStyle(ZAZUColors.textSecondary)
            }
        }
    }
    
    // MARK: - Eingabefeld
    
    private var addressField: some View {
        HStack(spacing: ZAZUSpacing.small) {
            
            Image(systemName: "mappin.and.ellipse")
                .foregroundStyle(ZAZUColors.primary)
            
            if let selectedAddress {
                
                Text(selectedAddress.formattedAddress)
                    .foregroundStyle(ZAZUColors.textPrimary)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                
                Spacer(minLength: 8)
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(ZAZUColors.success)
                
                Button {
                    clearSelection()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(ZAZUColors.textSecondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Adresse entfernen")
                
            } else {
                
                TextField(
                    "Strasse, Hausnummer und Ort suchen …",
                    text: $searchText
                )
                .foregroundStyle(ZAZUColors.textPrimary)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .onChange(of: searchText) { _, newValue in
                    autocomplete.search(query: newValue)
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
            
            ForEach(autocomplete.suggestions) { suggestion in
                
                Button {
                    selectSuggestion(suggestion)
                } label: {
                    
                    HStack(spacing: ZAZUSpacing.small) {
                        
                        Image(systemName: "mappin.circle.fill")
                            .foregroundStyle(ZAZUColors.primary)
                        
                        VStack(
                            alignment: .leading,
                            spacing: 4
                        ) {
                            Text(suggestion.title)
                                .fontWeight(.medium)
                            
                            if !suggestion.subtitle.isEmpty {
                                Text(suggestion.subtitle)
                                    .font(.footnote)
                                    .foregroundStyle(
                                        ZAZUColors.textSecondary
                                    )
                            }
                        }
                        .foregroundStyle(ZAZUColors.textPrimary)
                        
                        Spacer(minLength: 8)
                        
                        Image(systemName: "chevron.right")
                            .foregroundStyle(
                                ZAZUColors.textSecondary
                            )
                    }
                    .padding(ZAZUSpacing.medium)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                if suggestion.id != autocomplete.suggestions.last?.id {
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
        
        // MARK: - Auswahl
        
    private func selectSuggestion(
        _ suggestion: AddressSuggestion
    ) {
        autocomplete.clear()
        searchText = suggestion.displayText
        selectionError = nil

        Task {
            await resolveSuggestion(suggestion)
        }
    }

    @MainActor
    private func resolveSuggestion(
        _ suggestion: AddressSuggestion
    ) async {
        isResolvingAddress = true
        defer {
            isResolvingAddress = false
        }

        do {
            guard let address = try await searchService.resolveAddress(
                suggestion: suggestion
            ) else {
                selectionError = """
                Diese Adresse konnte nicht vollständig bestätigt werden. \
                Bitte wähle einen anderen Vorschlag.
                """
                return
            }

            selectedAddress = address
            searchText = ""
            selectionError = nil

        } catch {
            selectionError = """
            Die Adresse konnte nicht geladen werden. \
            Bitte versuche es erneut.
            """
        }
    }
        
        private func clearSelection() {
            selectedAddress = nil
            searchText = ""
            autocomplete.clear()
        }
    }

