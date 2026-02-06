//
//  ThemeBlocks.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 2/5/26.
//

import SwiftUI

// MARK: - Theme Blocks

/// Block-specific styling configuration for a journal theme.
struct ThemeBlocks: Codable, Equatable {
    let moment: MomentBlockStyle
    let recommendation: RecommendationBlockStyle
    let photo: PhotoBlockStyle
    let tip: TipBlockStyle
    let divider: DividerBlockStyle
}

// MARK: - Moment Block Style

struct MomentBlockStyle: Codable, Equatable {
    let cardBackground: String
    let stampStyle: StampStyle
    let stampColor: String

    // MARK: - SwiftUI Color Accessors

    var cardBackgroundColor: Color { Color(hex: cardBackground) }
    var stampSwiftUIColor: Color { Color(hex: stampColor) }
}

// MARK: - Recommendation Block Style

struct RecommendationBlockStyle: Codable, Equatable {
    let cardBackground: String
    let stay: CategoryBadgeStyle
    let eat: CategoryBadgeStyle
    let `do`: CategoryBadgeStyle
    let shop: CategoryBadgeStyle

    // MARK: - SwiftUI Color Accessors

    var cardBackgroundColor: Color { Color(hex: cardBackground) }

    /// Returns the badge style for a given category.
    func badgeStyle(for category: RecommendationCategory) -> CategoryBadgeStyle {
        switch category {
        case .stay: return stay
        case .eat: return eat
        case .do: return `do`
        case .shop: return shop
        }
    }
}

// MARK: - Category Badge Style

struct CategoryBadgeStyle: Codable, Equatable {
    let background: String
    let text: String

    // MARK: - SwiftUI Color Accessors

    var backgroundColor: Color { Color(hex: background) }
    var textColor: Color { Color(hex: text) }
}

// MARK: - Photo Block Style

struct PhotoBlockStyle: Codable, Equatable {
    let borderColor: String
    let borderRadius: Int

    // MARK: - SwiftUI Accessors

    var borderSwiftUIColor: Color { Color(hex: borderColor) }
    var cornerRadius: CGFloat { CGFloat(borderRadius) }
}

// MARK: - Tip Block Style

struct TipBlockStyle: Codable, Equatable {
    let background: String
    let borderColor: String
    let iconColor: String

    // MARK: - SwiftUI Color Accessors

    var backgroundColor: Color { Color(hex: background) }
    var borderSwiftUIColor: Color { Color(hex: borderColor) }
    var iconSwiftUIColor: Color { Color(hex: iconColor) }
}

// MARK: - Divider Block Style

struct DividerBlockStyle: Codable, Equatable {
    let lineColor: String
    let lineStyle: DividerLineStyle

    // MARK: - SwiftUI Color Accessors

    var lineSwiftUIColor: Color { Color(hex: lineColor) }
}

// MARK: - Defaults

extension ThemeBlocks {
    static let `default` = ThemeBlocks(
        moment: MomentBlockStyle(
            cardBackground: "#ffffff",
            stampStyle: .minimal,
            stampColor: "#1a1a2e"
        ),
        recommendation: RecommendationBlockStyle(
            cardBackground: "#ffffff",
            stay: CategoryBadgeStyle(background: "#3b82f6", text: "#ffffff"),
            eat: CategoryBadgeStyle(background: "#ef4444", text: "#ffffff"),
            do: CategoryBadgeStyle(background: "#f59e0b", text: "#1a1a2e"),
            shop: CategoryBadgeStyle(background: "#22c55e", text: "#ffffff")
        ),
        photo: PhotoBlockStyle(
            borderColor: "#e0e0e0",
            borderRadius: 8
        ),
        tip: TipBlockStyle(
            background: "#f0f9ff",
            borderColor: "#3b82f6",
            iconColor: "#3b82f6"
        ),
        divider: DividerBlockStyle(
            lineColor: "#e0e0e0",
            lineStyle: .solid
        )
    )
}
