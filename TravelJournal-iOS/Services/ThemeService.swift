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

    private init() {}

    // MARK: - Public API

    /// Returns all system themes (built-in, no API call needed).
    func getSystemThemes() -> [JournalTheme] {
        return JournalTheme.systemThemes
    }

    /// Fetches a theme by ID.
    /// Returns local system theme if available, otherwise fetches from API.
    func getTheme(id: UUID) async throws -> JournalTheme {
        // Check if it's a known system theme first
        if let systemTheme = JournalTheme.systemThemes.first(where: { $0.id == id }) {
            return systemTheme
        }
        // Fetch custom theme from API
        return try await api.request(endpoint: "/themes/\(id)")
    }

    /// Fetches a theme by slug.
    /// Returns local system theme if available, otherwise fetches from API.
    func getTheme(slug: String) async throws -> JournalTheme {
        // Check if it's a known system theme first
        if let systemTheme = JournalTheme.systemThemes.first(where: { $0.slug == slug }) {
            return systemTheme
        }
        // Fetch custom theme from API
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
