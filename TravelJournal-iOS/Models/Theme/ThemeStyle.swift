//
//  ThemeStyle.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 2/5/26.
//

import Foundation

// MARK: - Theme Style

/// Global style configuration for a journal theme.
struct ThemeStyle: Codable, Equatable {
    let showPaperTexture: Bool
    let showGridLines: Bool
    let cardBorderRadius: Int
    let cardShadow: Bool
    let headerStyle: HeaderStyle

    // MARK: - Computed Properties

    var borderRadius: CGFloat {
        CGFloat(cardBorderRadius)
    }
}

// MARK: - Defaults

extension ThemeStyle {
    static let `default` = ThemeStyle(
        showPaperTexture: false,
        showGridLines: false,
        cardBorderRadius: 12,
        cardShadow: true,
        headerStyle: .standard
    )
}
