//
//  PublicJournalView.swift
//  TravelJournal-iOS
//
//  Created on 2/8/26.
//

import SwiftUI

struct PublicJournalView: View {
    @StateObject private var viewModel: PublicJournalViewModel
    @Environment(\.dismiss) private var dismiss

    init(trip: Trip, previewEntries: [JournalEntry]? = nil, previewTheme: JournalTheme? = nil) {
        _viewModel = StateObject(wrappedValue: PublicJournalViewModel(
            trip: trip,
            previewEntries: previewEntries,
            previewTheme: previewTheme
        ))
    }

    var body: some View {
        ZStack {
            // Theme background
            viewModel.theme.colors.backgroundColor
                .ignoresSafeArea()

            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.error {
                errorView(message: error)
            } else {
                journalContent
            }

            // Floating navigation bar
            VStack {
                navigationBar
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .journalTheme(viewModel.theme)
        .task {
            await viewModel.loadJournal()
        }
    }

    // MARK: - Navigation Bar

    private var navigationBar: some View {
        HStack {
            // Back button
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
            }

            Spacer()

            // Author info
            HStack(spacing: 8) {
                if let profileUrl = viewModel.trip.author.profilePictureUrl,
                   let url = URL(string: profileUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        authorPlaceholder
                    }
                    .frame(width: 28, height: 28)
                    .clipShape(Circle())
                } else {
                    authorPlaceholder
                }

                Text(viewModel.trip.author.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.black.opacity(0.3))
            .clipShape(Capsule())

            Spacer()

            // Save trip button (hidden for author)
            if !viewModel.isAuthor {
                Button(action: {
                    Task { await viewModel.toggleSaveTrip() }
                }) {
                    Image(systemName: viewModel.trip.isSaved == true ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(viewModel.trip.isSaved == true ? viewModel.theme.colors.accentColor : .white)
                        .frame(width: 44, height: 44)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
            } else {
                Color.clear.frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var authorPlaceholder: some View {
        Circle()
            .fill(Color.gray.opacity(0.5))
            .frame(width: 28, height: 28)
            .overlay(
                Image(systemName: "person.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            )
    }

    // MARK: - Journal Content

    private var journalContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Themed header with cover, title, dates, and stats
                ThemedJournalHeader(
                    title: viewModel.trip.title,
                    description: viewModel.trip.description,
                    coverImageUrl: viewModel.trip.coverImageUrl,
                    startDate: viewModel.trip.startDate,
                    endDate: viewModel.trip.endDate,
                    stops: viewModel.trip.stops ?? [],
                    statsConfig: HeaderStatsConfig(
                        viewCount: viewModel.trip.viewCount,
                        saveCount: viewModel.trip.saveCount
                    )
                )

                // Journal entries with save buttons
                entriesSection
                    .padding(.top, -24)
                    .padding(.bottom, 60)
            }
        }
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - Entries Section

    private var entriesSection: some View {
        LazyVStack(spacing: 16) {
            ForEach(viewModel.entries) { entry in
                SaveableEntryCard(
                    entry: entry,
                    isSaved: viewModel.isEntrySaved(entry),
                    showSaveButton: !viewModel.isAuthor
                ) {
                    Task { await viewModel.toggleSaveEntry(entry) }
                }
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: viewModel.theme.colors.textPrimaryColor))
            Text("Loading journal...")
                .font(viewModel.theme.typography.bodyFont(size: 15))
                .foregroundColor(viewModel.theme.colors.textMutedColor)
        }
    }

    // MARK: - Error View

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(viewModel.theme.colors.accentColor)

            Text("Failed to load journal")
                .font(viewModel.theme.typography.headingFont(size: 20, weight: .semibold))
                .foregroundColor(viewModel.theme.colors.textPrimaryColor)

            Text(message)
                .font(viewModel.theme.typography.bodyFont(size: 15))
                .foregroundColor(viewModel.theme.colors.textSecondaryColor)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                Task { await viewModel.loadJournal() }
            }
            .font(viewModel.theme.typography.bodyFont(size: 15, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(viewModel.theme.colors.primaryColor)
            .cornerRadius(viewModel.theme.style.borderRadius)
        }
        .padding(32)
    }
}

// MARK: - Saveable Entry Card

/// Wrapper that passes action config to themed cards.
private struct SaveableEntryCard: View {
    let entry: JournalEntry
    let isSaved: Bool
    let showSaveButton: Bool
    let onSave: () -> Void

    var body: some View {
        let block = entry.toEditorBlock()
        let actionConfig: CardActionConfig? = showSaveButton 
            ? .interactive(saveCount: entry.saveCount, isSaved: isSaved, onSave: onSave)
            : nil

        switch entry.blockType {
        case .moment:
            ThemedMomentCard(block: block, actionConfig: actionConfig)
        case .recommendation:
            ThemedRecommendationCard(block: block, actionConfig: actionConfig)
        case .photo:
            ThemedPhotoCard(block: block, actionConfig: actionConfig)
        case .tip:
            ThemedTipCard(block: block, actionConfig: actionConfig)
        case .divider:
            ThemedDividerView()
        }
    }
}

// MARK: - Previews

#Preview("Passport Theme") {
    PublicJournalView(
        trip: .preview(title: "Tokyo Adventure", themeSlug: "passport"),
        previewEntries: .previewEntries,
        previewTheme: .passport
    )
}

#Preview("Default Theme") {
    PublicJournalView(
        trip: .preview(title: "Paris Getaway", themeSlug: "default"),
        previewEntries: .previewEntries,
        previewTheme: .default
    )
}

#Preview("Retro Theme") {
    PublicJournalView(
        trip: .preview(title: "Italian Summer", themeSlug: "retro"),
        previewEntries: .previewEntries,
        previewTheme: .retro
    )
}

#Preview("Author View (No Save Buttons)") {
    PublicJournalView(
        trip: .preview(
            author: Author(id: AuthManager.shared.currentUserId ?? UUID(), name: "You", profilePictureUrl: nil),
            title: "My Trip"
        ),
        previewEntries: .previewEntries,
        previewTheme: .passport
    )
}
