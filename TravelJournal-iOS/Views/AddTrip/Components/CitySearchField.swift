//
//  CitySearchField.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/21/26.
//

import Foundation
import SwiftUI

struct CitySearchField: View {
    @Binding var searchText: String
    let searchResults: [LocationSearchResult]
    let isSearching: Bool
    let onCitySelected: (LocationSearchResult) -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Search input
            searchInput

            // Results dropdown
            if isFocused && (!searchResults.isEmpty || isSearching || !searchText.isEmpty) {
                resultsDropdown
            }
        }
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
                prompt: Text("Search for a city...")
                    .foregroundColor(AppTheme.Colors.textPlaceholder)
            )
            .font(AppTheme.Typography.monoMedium())
            .foregroundColor(AppTheme.Colors.textPrimary)
            .focused($isFocused)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.words)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.textSecondary.opacity(0.6))
                }
            }

            if isSearching {
                ProgressView()
                    .scaleEffect(0.8)
                    .tint(AppTheme.Colors.primary)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.inputBackground)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .stroke(
                    isFocused ? AppTheme.Colors.primary : AppTheme.Colors.primary.opacity(0.3),
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
                ForEach(searchResults) { result in
                    resultRow(result)

                    if result.id != searchResults.last?.id {
                        Divider()
                            .background(AppTheme.Colors.primary.opacity(0.2))
                    }
                }
            }
        }
        .background(AppTheme.Colors.backgroundMedium)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .stroke(AppTheme.Colors.primary.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(AppTheme.CornerRadius.medium)
        .padding(.top, AppTheme.Spacing.xxxs)
    }

    // MARK: - Result Row

    private func resultRow(_ result: LocationSearchResult) -> some View {
        Button {
            onCitySelected(result)
            searchText = ""
            isFocused = false
        } label: {
            HStack(spacing: AppTheme.Spacing.sm) {
                // Flag
                if let countryCode = result.countryCode {
                    Text(flag(for: countryCode))
                        .font(.system(size: 20))
                }

                // City and country name
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.name)
                        .font(AppTheme.Typography.monoMedium())
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    if let countryCode = result.countryCode {
                        Text(countryName(for: countryCode))
                            .font(AppTheme.Typography.monoCaption())
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }

                Spacer()

                Image(systemName: "plus.circle")
                    .font(.system(size: 18))
                    .foregroundColor(AppTheme.Colors.primary.opacity(0.7))
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
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, AppTheme.Spacing.md)
    }

    // MARK: - No Results Row

    private var noResultsRow: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "mappin.slash")
                .font(.system(size: 16))
                .foregroundColor(AppTheme.Colors.textSecondary.opacity(0.6))

            Text("No cities found")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, AppTheme.Spacing.md)
    }

    // MARK: - Helpers

    private func flag(for countryCode: String) -> String {
        let base: UInt32 = 127_397
        var flag = ""
        for scalar in countryCode.uppercased().unicodeScalars {
            if let unicode = UnicodeScalar(base + scalar.value) {
                flag.append(String(unicode))
            }
        }
        return flag
    }

    private func countryName(for code: String) -> String {
        Locale.current.localizedString(forRegionCode: code) ?? code
    }
}

// MARK: - Preview

#Preview("Empty State") {
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()

        CitySearchField(
            searchText: .constant(""),
            searchResults: [],
            isSearching: false,
            onCitySelected: { _ in }
        )
        .padding()
    }
}

#Preview("With Results") {
    let mockResults = [
        LocationSearchResult(
            displayName: "Paris, France",
            name: "Paris",
            osmType: "R",
            osmId: 123_456,
            latitude: 48.8566,
            longitude: 2.3522,
            placeType: .city,
            countryCode: "FR",
            boundingBox: nil
        ),
        LocationSearchResult(
            displayName: "Parma, Italy",
            name: "Parma",
            osmType: "R",
            osmId: 234_567,
            latitude: 44.8015,
            longitude: 10.3279,
            placeType: .city,
            countryCode: "IT",
            boundingBox: nil
        ),
    ]

    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()

        CitySearchField(
            searchText: .constant("Par"),
            searchResults: mockResults,
            isSearching: false,
            onCitySelected: { city in print("Selected: \(city.name)") }
        )
        .padding()
    }
}

#Preview("Searching") {
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()

        CitySearchField(
            searchText: .constant("Tok"),
            searchResults: [],
            isSearching: true,
            onCitySelected: { _ in }
        )
        .padding()
    }
}
