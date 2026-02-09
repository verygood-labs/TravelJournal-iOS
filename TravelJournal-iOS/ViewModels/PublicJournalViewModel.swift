//
//  PublicJournalViewModel.swift
//  TravelJournal-iOS
//
//  Created on 2/8/26.
//

import Combine
import Foundation
import SwiftUI

@MainActor
class PublicJournalViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var trip: Trip
    @Published var entries: [JournalEntry] = []
    @Published var theme: JournalTheme = .default
    @Published var isLoading = false
    @Published var error: String?

    /// Tracks save status for each entry by ID
    @Published var entrySaveStatus: [UUID: Bool] = [:]

    /// Whether the current user is the trip author
    let isAuthor: Bool

    // MARK: - Services

    private let journalService = JournalService.shared
    private let savedContentService = SavedContentService.shared
    private let tripService = TripService.shared
    private let themeService = ThemeService.shared

    /// Returns true when running in SwiftUI preview canvas
    private static var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    // MARK: - Initialization

    init(trip: Trip, previewEntries: [JournalEntry]? = nil, previewTheme: JournalTheme? = nil) {
        self.trip = trip
        // Check if current user is the author
        if let currentUserId = AuthManager.shared.currentUserId {
            self.isAuthor = trip.author.id == currentUserId
        } else {
            self.isAuthor = false
        }

        // For previews, use provided entries and theme
        if let previewEntries = previewEntries {
            self.entries = previewEntries
            for entry in previewEntries {
                if let isSaved = entry.isSaved {
                    entrySaveStatus[entry.id] = isSaved
                }
            }
        }
        if let previewTheme = previewTheme {
            self.theme = previewTheme
        }
    }

    // MARK: - Loading

    func loadJournal() async {
        // Skip network calls in preview
        guard !Self.isPreview else { return }

        isLoading = true
        error = nil

        do {
            // Load theme from slug
            if let themeSlug = trip.themeSlug {
                theme = try await themeService.getTheme(slug: themeSlug)
            }

            // Load entries
            entries = try await journalService.getJournalEntries(tripId: trip.id)

            // Initialize save status from entries
            for entry in entries {
                if let isSaved = entry.isSaved {
                    entrySaveStatus[entry.id] = isSaved
                }
            }

            // Refresh trip to get latest save status
            trip = try await tripService.getTrip(id: trip.id)
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Save Actions

    /// Toggle save status for the entire trip (pin button)
    func toggleSaveTrip() async {
        guard !isAuthor else { return }

        do {
            let response = try await savedContentService.toggleSaveTrip(tripId: trip.id)

            // Update local state
            trip = Trip(
                id: trip.id,
                author: trip.author,
                title: trip.title,
                description: trip.description,
                coverImageUrl: trip.coverImageUrl,
                status: trip.status,
                tripMode: trip.tripMode,
                startDate: trip.startDate,
                endDate: trip.endDate,
                createdAt: trip.createdAt,
                updatedAt: trip.updatedAt,
                stops: trip.stops,
                primaryDestination: trip.primaryDestination,
                saveCount: response.newSaveCount,
                viewCount: trip.viewCount,
                isSaved: response.isSaved,
                stopCount: trip.stopCount,
                themeId: trip.themeId,
                themeSlug: trip.themeSlug,
                draftThemeSlug: trip.draftThemeSlug
            )
        } catch {
            self.error = "Failed to save trip"
        }
    }

    /// Toggle save status for a journal entry (heart button)
    func toggleSaveEntry(_ entry: JournalEntry) async {
        guard !isAuthor else { return }

        do {
            let response = try await savedContentService.toggleSaveItem(entryId: entry.id)

            // Update local state
            entrySaveStatus[entry.id] = response.isSaved
        } catch {
            self.error = "Failed to save item"
        }
    }

    /// Check if an entry is saved
    func isEntrySaved(_ entry: JournalEntry) -> Bool {
        return entrySaveStatus[entry.id] ?? entry.isSaved ?? false
    }
}
