//
//  TravelersSearchView.swift
//  TravelJournal-iOS
//
//  Search mode view for finding travelers
//

import SwiftUI

struct TravelersSearchView: View {
    @ObservedObject var viewModel: MapViewModel
    let onTravelerTap: (Traveler) -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            // Search bar
            TravelerSearchBar(
                text: $viewModel.searchQuery,
                placeholder: "Search travelers...",
                onClear: {
                    viewModel.clearSearch()
                }
            )
            .onChange(of: viewModel.searchQuery) { _, _ in
                viewModel.searchTravelers()
            }

            // Sort chips
            SortChipsView(selectedOption: $viewModel.selectedSortOption)
                .onChange(of: viewModel.selectedSortOption) { _, newValue in
                    Task {
                        await viewModel.updateSortOption(newValue)
                    }
                }

            // Results
            if viewModel.isSearching {
                loadingView
            } else if viewModel.travelers.isEmpty {
                emptyView
            } else {
                resultsView
            }

            Spacer()
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.sm)
        .task {
            await viewModel.loadInitialTravelers()
        }
    }

    // MARK: - Results View

    private var resultsView: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            // Header
            Text(viewModel.resultsHeaderText)
                .font(AppTheme.Typography.monoCaption())
                .tracking(1)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .padding(.top, AppTheme.Spacing.xxs)

            // List
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: AppTheme.Spacing.xs) {
                    ForEach(viewModel.travelers) { traveler in
                        TravelerCard(traveler: traveler) {
                            onTravelerTap(traveler)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()

            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.primary))
                .scaleEffect(1.2)

            Text("Searching...")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.textSecondary)

            Spacer()
        }
    }

    // MARK: - Empty View

    private var emptyView: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Spacer()

            Image(systemName: "person.2.slash")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.Colors.textSecondary.opacity(0.5))

            VStack(spacing: AppTheme.Spacing.xxs) {
                Text("No Travelers Found")
                    .font(AppTheme.Typography.serifSmall())
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text("Try a different search term")
                    .font(AppTheme.Typography.monoSmall())
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()

        TravelersSearchView(
            viewModel: MapViewModel(),
            onTravelerTap: { _ in }
        )
    }
}
