//
//  ThemeTypography.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 2/5/26.
//

import SwiftUI

// MARK: - Theme Typography

/// Typography configuration for a journal theme.
struct ThemeTypography: Codable, Equatable {
    let headingFont: String    // "system-serif", "Playfair Display", etc.
    let bodyFont: String       // "system", "IBM Plex Mono", etc.
    let labelFont: String      // "system", "Special Elite", etc.

    // MARK: - Font Resolution

    /// Returns a SwiftUI Font for headings at the given size.
    func headingFont(size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        resolveFont(name: headingFont, size: size, weight: weight, design: .serif)
    }

    /// Returns a SwiftUI Font for body text at the given size.
    func bodyFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        resolveFont(name: bodyFont, size: size, weight: weight, design: .default)
    }

    /// Returns a SwiftUI Font for labels at the given size.
    func labelFont(size: CGFloat, weight: Font.Weight = .medium) -> Font {
        resolveFont(name: labelFont, size: size, weight: weight, design: .monospaced)
    }

    // MARK: - Private

    private func resolveFont(
        name: String,
        size: CGFloat,
        weight: Font.Weight,
        design: Font.Design
    ) -> Font {
        switch name.lowercased() {
        case "system", "system-default":
            return .system(size: size, weight: weight, design: .default)
        case "system-serif":
            return .system(size: size, weight: weight, design: .serif)
        case "system-mono", "system-monospaced":
            return .system(size: size, weight: weight, design: .monospaced)
        case "system-rounded":
            return .system(size: size, weight: weight, design: .rounded)
        default:
            // Try to load custom font, fall back to system with design hint
            if UIFont(name: name, size: size) != nil {
                return .custom(name, size: size)
            }
            return .system(size: size, weight: weight, design: design)
        }
    }
}

// MARK: - Defaults

extension ThemeTypography {
    static let `default` = ThemeTypography(
        headingFont: "system-serif",
        bodyFont: "system",
        labelFont: "system-mono"
    )
}
