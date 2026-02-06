//
//  PassportTheme.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 2/5/26.
//

import Foundation

// MARK: - Passport Theme

extension JournalTheme {
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
                borderRadius: 2,
                frameColor: "#f5f1e8",
                captionBackground: "#f5f1e8",
                captionTextColor: "#4a4a4a"
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
}
