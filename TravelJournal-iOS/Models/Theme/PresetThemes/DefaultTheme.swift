//
//  DefaultTheme.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 2/5/26.
//

import Foundation

// MARK: - Default Theme

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
                borderRadius: 8,
                frameColor: "#ffffff",
                captionBackground: "#ffffff",
                captionTextColor: "#333333"
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
}
