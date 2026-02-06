//
//  RetroTheme.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 2/5/26.
//

import Foundation

// MARK: - Retro Theme

extension JournalTheme {
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
            border: "#000000"
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
                borderRadius: 0,
                frameColor: "#FFFFFF",
                captionBackground: "#FFFFFF",
                captionTextColor: "#000000"
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
}
