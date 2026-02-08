//
//  PlaceSearchField.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 2/7/26.
//

import SwiftUI

/// A compact place search field for block sheets.
/// Searches venues via the Places API and returns an EditorLocation when selected.
struct PlaceSearchField: View {
    @Binding var searchText: String
    @Binding var selectedLocation: EditorLocation?
    let onPlaceSelected: (LocationSearchResult) -> Void
    
    @State private var searchResults: [LocationSearchResult] = []
    @State private var isSearching = false
    @State private var searchTask: Task<Void, Never>?
    @FocusState private var isFocused: Bool
    
    /// Whether we have a selected location (show selected state vs search state)
    private var hasSelection: Bool {
        selectedLocation != nil
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Show selected location or search input
            if hasSelection {
                selectedLocationView
            } else {
                searchInput
                
                // Results dropdown
                if isFocused && (!searchResults.isEmpty || isSearching || !searchText.isEmpty) {
                    resultsDropdown
                        .padding(.top, AppTheme.Spacing.xxxs)
                }
            }
        }
    }
    
    // MARK: - Selected Location View
    
    private var selectedLocationView: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.primary)
            
            Text(selectedLocation?.displayName ?? "")
                .font(AppTheme.Typography.monoMedium())
                .foregroundColor(AppTheme.Colors.passportTextPrimary)
                .lineLimit(1)
            
            Spacer()
            
            Button {
                selectedLocation = nil
                searchText = ""
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.Colors.passportTextMuted)
            }
        }
        .padding(AppTheme.Spacing.sm)
        .background(AppTheme.Colors.passportInputBackground)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .stroke(AppTheme.Colors.primary, lineWidth: 1)
        )
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
    
    // MARK: - Search Input
    
    private var searchInput: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.primary.opacity(0.7))
            
            TextField(
                "",
                text: $searchText,
                prompt: Text("Search for a place or address...")
                    .foregroundColor(AppTheme.Colors.passportTextPlaceholder)
            )
            .font(AppTheme.Typography.monoMedium())
            .foregroundColor(AppTheme.Colors.passportTextPrimary)
            .focused($isFocused)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.words)
            .onChange(of: searchText) { _, newValue in
                performSearch(query: newValue)
            }
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    searchResults = []
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.passportTextSecondary.opacity(0.6))
                }
            }
            
            if isSearching {
                ProgressView()
                    .scaleEffect(0.8)
                    .tint(AppTheme.Colors.primary)
            }
        }
        .padding(AppTheme.Spacing.sm)
        .background(AppTheme.Colors.passportInputBackground)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .stroke(
                    isFocused ? AppTheme.Colors.primary : AppTheme.Colors.passportInputBorder,
                    lineWidth: isFocused ? 1.5 : 1
                )
        )
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
    
    // MARK: - Results Dropdown
    
    private var resultsDropdown: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isSearching {
                searchingRow
            } else if searchResults.isEmpty && !searchText.isEmpty {
                noResultsRow
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(searchResults) { result in
                            resultRow(result)
                            
                            if result.id != searchResults.last?.id {
                                Divider()
                                    .background(AppTheme.Colors.passportInputBorder)
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
        }
        .background(AppTheme.Colors.passportInputBackground)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .stroke(AppTheme.Colors.passportInputBorder, lineWidth: 1)
        )
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
    
    // MARK: - Result Row
    
    private func resultRow(_ result: LocationSearchResult) -> some View {
        Button {
            onPlaceSelected(result)
            searchText = ""
            searchResults = []
            isFocused = false
        } label: {
            HStack(spacing: AppTheme.Spacing.sm) {
                // Pin icon
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.Colors.primary.opacity(0.8))
                
                // Place name and address
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.name)
                        .font(AppTheme.Typography.monoMedium())
                        .foregroundColor(AppTheme.Colors.passportTextPrimary)
                        .lineLimit(1)
                    
                    Text(truncatedAddress(result.displayName))
                        .font(AppTheme.Typography.monoCaption())
                        .foregroundColor(AppTheme.Colors.passportTextSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.left")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.Colors.passportTextMuted)
            }
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.vertical, AppTheme.Spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Searching Row
    
    private var searchingRow: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            ProgressView()
                .scaleEffect(0.8)
                .tint(AppTheme.Colors.primary)
            
            Text("Searching...")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.passportTextSecondary)
        }
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, AppTheme.Spacing.md)
    }
    
    // MARK: - No Results Row
    
    private var noResultsRow: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "mappin.slash")
                .font(.system(size: 16))
                .foregroundColor(AppTheme.Colors.passportTextSecondary.opacity(0.6))
            
            Text("No places found")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.passportTextSecondary)
        }
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, AppTheme.Spacing.md)
    }
    
    // MARK: - Helpers
    
    /// Truncate address to remove the first part (which is usually the name)
    private func truncatedAddress(_ displayName: String) -> String {
        // Split by comma and skip the first component (the name)
        let components = displayName.components(separatedBy: ", ")
        if components.count > 1 {
            return components.dropFirst().joined(separator: ", ")
        }
        return displayName
    }
    
    // MARK: - Search
    
    private func performSearch(query: String) {
        // Cancel previous search
        searchTask?.cancel()
        
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else {
            searchResults = []
            isSearching = false
            return
        }
        
        isSearching = true
        
        searchTask = Task {
            // Debounce
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
            
            guard !Task.isCancelled else { return }
            
            do {
                // Search for venues specifically, or all types if venue search yields few results
                let results = try await PlaceService.shared.search(
                    query: trimmed,
                    placeType: nil, // Search all types for recommendations
                    limit: 8
                )
                
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    searchResults = results
                    isSearching = false
                }
            } catch {
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    searchResults = []
                    isSearching = false
                }
                print("Place search error: \(error)")
            }
        }
    }
}

// MARK: - Preview

#Preview("Empty") {
    ZStack {
        AppTheme.Colors.passportPageDark
            .ignoresSafeArea()
        
        PlaceSearchField(
            searchText: .constant(""),
            selectedLocation: .constant(nil),
            onPlaceSelected: { place in
                print("Selected: \(place.name)")
            }
        )
        .padding()
    }
}

#Preview("With Selection") {
    ZStack {
        AppTheme.Colors.passportPageDark
            .ignoresSafeArea()
        
        PlaceSearchField(
            searchText: .constant(""),
            selectedLocation: .constant(EditorLocation(
                osmType: "N",
                osmId: 123456,
                name: "Cafe de Flore",
                displayName: "Cafe de Flore, 172 Boulevard Saint-Germain, Paris, France",
                latitude: 48.8541,
                longitude: 2.3326
            )),
            onPlaceSelected: { place in
                print("Selected: \(place.name)")
            }
        )
        .padding()
    }
}
