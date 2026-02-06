//
//  ThemeColors.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 2/5/26.
//

import SwiftUI

// MARK: - Theme Colors

/// Color palette for a journal theme.
struct ThemeColors: Codable, Equatable {
    let primary: String
    let secondary: String
    let background: String
    let cardBackground: String
    let textPrimary: String
    let textSecondary: String
    let textMuted: String
    let accent: String
    let border: String

    // MARK: - SwiftUI Color Accessors

    var primaryColor: Color { Color(hex: primary) }
    var secondaryColor: Color { Color(hex: secondary) }
    var backgroundColor: Color { Color(hex: background) }
    var cardBackgroundColor: Color { Color(hex: cardBackground) }
    var textPrimaryColor: Color { Color(hex: textPrimary) }
    var textSecondaryColor: Color { Color(hex: textSecondary) }
    var textMutedColor: Color { Color(hex: textMuted) }
    var accentColor: Color { Color(hex: accent) }
    var borderColor: Color { Color(hex: border) }
}

// MARK: - Defaults

extension ThemeColors {
    static let `default` = ThemeColors(
        primary: "#1a1a2e",
        secondary: "#c9a227",
        background: "#ffffff",
        cardBackground: "#f8f9fa",
        textPrimary: "#1a1a2e",
        textSecondary: "#666666",
        textMuted: "#888888",
        accent: "#c9a227",
        border: "#e0e0e0"
    )
}
