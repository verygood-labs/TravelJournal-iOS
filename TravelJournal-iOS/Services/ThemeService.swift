//
//  ThemeService.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 2/5/26.
//

import Foundation

// MARK: - Theme Service

/// Service for fetching and managing journal themes.
class ThemeService {
    static let shared = ThemeService()
    private let api = APIService.shared

    /// Cached themes to avoid repeated API calls.
    private var cachedThemes: [JournalTheme]?

    private init() {}

    // MARK: - Public API

    /// Fetches all system themes from the API.
    /// Falls back to built-in themes if the API call fails.
    func getSystemThemes() async -> [JournalTheme] {
        // Return cached if available
        if let cached = cachedThemes {
            return cached
        }

        do {
            let themes: [JournalTheme] = try await api.request(endpoint: "/themes")
            cachedThemes = themes
            return themes
        } catch {
            print("⚠️ Failed to fetch themes from API, using fallbacks: \(error)")
            return JournalTheme.systemThemes
        }
    }

    /// Fetches a theme by ID.
    func getTheme(id: UUID) async throws -> JournalTheme {
        return try await api.request(endpoint: "/themes/\(id)")
    }

    /// Fetches a theme by slug.
    func getTheme(slug: String) async throws -> JournalTheme {
        return try await api.request(endpoint: "/themes/slug/\(slug)")
    }

    /// Sets the draft theme for a trip (for preview).
    func setDraftTheme(tripId: UUID, themeId: UUID) async throws {
        let body = SetDraftThemeRequest(themeId: themeId)
        try await api.requestVoid(
            endpoint: "/trips/\(tripId)/draft-theme",
            method: "PATCH",
            body: body
        )
    }

    /// Clears the cached themes, forcing a refresh on next fetch.
    func clearCache() {
        cachedThemes = nil
    }

    // MARK: - Fallback Themes

    /// Returns the default theme (used when no theme is selected).
    var defaultTheme: JournalTheme {
        .default
    }

    /// Returns all built-in fallback themes.
    var fallbackThemes: [JournalTheme] {
        JournalTheme.systemThemes
    }
}

// MARK: - Request Models

private struct SetDraftThemeRequest: Encodable {
    let themeId: UUID
}
