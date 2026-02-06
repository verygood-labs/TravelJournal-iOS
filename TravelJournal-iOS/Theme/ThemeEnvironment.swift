//
//  ThemeEnvironment.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 2/5/26.
//

import SwiftUI

// MARK: - Journal Theme Environment Key

private struct JournalThemeKey: EnvironmentKey {
    static let defaultValue: JournalTheme = .default
}

extension EnvironmentValues {
    /// The current journal theme for preview rendering.
    var journalTheme: JournalTheme {
        get { self[JournalThemeKey.self] }
        set { self[JournalThemeKey.self] = newValue }
    }
}

// MARK: - View Extension

extension View {
    /// Applies a journal theme to the view hierarchy.
    func journalTheme(_ theme: JournalTheme) -> some View {
        environment(\.journalTheme, theme)
    }
}
