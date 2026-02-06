//
//  JournalTheme.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 2/5/26.
//

import Foundation

// MARK: - Journal Theme

/// Complete theme configuration for a journal.
/// Matches the ThemeDto from the backend API.
struct JournalTheme: Codable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let slug: String
    let description: String?
    let isSystem: Bool
    let typography: ThemeTypography
    let colors: ThemeColors
    let blocks: ThemeBlocks
    let style: ThemeStyle
}

// MARK: - System Themes

extension JournalTheme {
    /// Clean, minimal design that lets your content shine.
    static let `default` = JournalTheme(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        name: "Default",
        slug: "default",
        description: "Clean, minimal design that lets your content shine",
        isSystem: true,
        typography: ThemeTypography(
            headingFont: "system-serif",
            bodyFont: "system",
            labelFont: "system"
        ),
        colors: ThemeColors(
            primary: "#1a1a2e",
            secondary: "#c9a227",
            background: "#ffffff",
            cardBackground: "#f8f9fa",
            textPrimary: "#1a1a2e",
            textSecondary: "#666666",
            textMuted: "#888888",
            accent: "#c9a227",
            border: "#e0e0e0"
        ),
        blocks: ThemeBlocks(
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
        ),
        style: ThemeStyle(
            showPaperTexture: false,
            showGridLines: false,
            cardBorderRadius: 12,
            cardShadow: true,
            headerStyle: .standard
        )
    )

    /// Vintage travel journal with paper texture and stamps.
    static let passport = JournalTheme(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
        name: "Passport",
        slug: "passport",
        description: "Vintage travel journal with paper texture and stamps",
        isSystem: true,
        typography: ThemeTypography(
            headingFont: "system-serif",
            bodyFont: "system-mono",
            labelFont: "system-mono"
        ),
        colors: ThemeColors(
            primary: "#0038A8",
            secondary: "#FCD116",
            background: "#f5f1e8",
            cardBackground: "#ebe6d9",
            textPrimary: "#1a1a2e",
            textSecondary: "#666666",
            textMuted: "#888888",
            accent: "#CE1126",
            border: "#d4cfc2"
        ),
        blocks: ThemeBlocks(
            moment: MomentBlockStyle(
                cardBackground: "#ebe6d9",
                stampStyle: .rubber,
                stampColor: "#CE1126"
            ),
            recommendation: RecommendationBlockStyle(
                cardBackground: "#ffffff",
                stay: CategoryBadgeStyle(background: "#0038A8", text: "#ffffff"),
                eat: CategoryBadgeStyle(background: "#CE1126", text: "#ffffff"),
                do: CategoryBadgeStyle(background: "#FCD116", text: "#1a1a2e"),
                shop: CategoryBadgeStyle(background: "#27ae60", text: "#ffffff")
            ),
            photo: PhotoBlockStyle(
                borderColor: "#d4cfc2",
                borderRadius: 2
            ),
            tip: TipBlockStyle(
                background: "#FFF8E1",
                borderColor: "#FCD116",
                iconColor: "#FCD116"
            ),
            divider: DividerBlockStyle(
                lineColor: "#d4cfc2",
                lineStyle: .dashed
            )
        ),
        style: ThemeStyle(
            showPaperTexture: true,
            showGridLines: true,
            cardBorderRadius: 4,
            cardShadow: true,
            headerStyle: .passport
        )
    )

    /// Nostalgic Web 1.0 vibes with bold colors.
    static let retro = JournalTheme(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
        name: "Retro",
        slug: "retro",
        description: "Nostalgic Web 1.0 vibes with bold colors",
        isSystem: true,
        typography: ThemeTypography(
            headingFont: "system-rounded",
            bodyFont: "system-mono",
            labelFont: "system"
        ),
        colors: ThemeColors(
            primary: "#0000FF",
            secondary: "#FF00FF",
            background: "#C0C0C0",
            cardBackground: "#FFFFFF",
            textPrimary: "#000000",
            textSecondary: "#000080",
            textMuted: "#808080",
            accent: "#FF0000",
            border: "#808080"
        ),
        blocks: ThemeBlocks(
            moment: MomentBlockStyle(
                cardBackground: "#FFFFFF",
                stampStyle: .vintage,
                stampColor: "#FF0000"
            ),
            recommendation: RecommendationBlockStyle(
                cardBackground: "#FFFFFF",
                stay: CategoryBadgeStyle(background: "#0000FF", text: "#FFFFFF"),
                eat: CategoryBadgeStyle(background: "#FF0000", text: "#FFFFFF"),
                do: CategoryBadgeStyle(background: "#FFFF00", text: "#000000"),
                shop: CategoryBadgeStyle(background: "#00FF00", text: "#000000")
            ),
            photo: PhotoBlockStyle(
                borderColor: "#000000",
                borderRadius: 0
            ),
            tip: TipBlockStyle(
                background: "#FFFF00",
                borderColor: "#000000",
                iconColor: "#FF0000"
            ),
            divider: DividerBlockStyle(
                lineColor: "#808080",
                lineStyle: .dotted
            )
        ),
        style: ThemeStyle(
            showPaperTexture: false,
            showGridLines: false,
            cardBorderRadius: 0,
            cardShadow: false,
            headerStyle: .minimal
        )
    )

    /// All built-in system themes.
    static let systemThemes: [JournalTheme] = [.default, .passport, .retro]
}
