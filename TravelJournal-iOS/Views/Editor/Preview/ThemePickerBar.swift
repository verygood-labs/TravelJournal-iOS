//
//  ThemePickerBar.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 2/5/26.
//

import SwiftUI

// MARK: - Theme Picker Bar

/// A horizontal scrolling theme picker for the preview mode.
struct ThemePickerBar: View {
    let themes: [JournalTheme]
    @Binding var selectedTheme: JournalTheme
    let isLoading: Bool

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label
            Text("THEME")
                .font(AppTheme.Typography.monoCaption())
                .foregroundColor(AppTheme.Colors.passportTextMuted)
                .tracking(1)
                .padding(.horizontal, 16)

            if isLoading {
                loadingView
            } else {
                themesScrollView
            }
        }
        .padding(.vertical, 12)
    }

    // MARK: - Loading View

    private var loadingView: some View {
        HStack {
            Spacer()
            ProgressView()
                .tint(AppTheme.Colors.primary)
            Spacer()
        }
        .frame(height: 80)
    }

    // MARK: - Themes Scroll View

    private var themesScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(themes) { theme in
                    ThemePickerItem(
                        theme: theme,
                        isSelected: selectedTheme.id == theme.id,
                        onSelect: { selectedTheme = theme }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Theme Picker Item

private struct ThemePickerItem: View {
    let theme: JournalTheme
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                // Theme preview thumbnail
                themeThumbnail
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                isSelected ? AppTheme.Colors.primary : Color.clear,
                                lineWidth: 2
                            )
                    )

                // Theme name
                Text(theme.name)
                    .font(AppTheme.Typography.monoSmall())
                    .foregroundColor(
                        isSelected
                            ? AppTheme.Colors.primary
                            : AppTheme.Colors.textSecondary
                    )
            }
        }
        .buttonStyle(.plain)
    }

    private var themeThumbnail: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: theme.colors.background))
                .frame(width: 80, height: 60)

            // Preview elements
            VStack(spacing: 4) {
                // Card preview
                RoundedRectangle(cornerRadius: CGFloat(theme.style.cardBorderRadius) / 3)
                    .fill(Color(hex: theme.colors.cardBackground))
                    .frame(width: 60, height: 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: CGFloat(theme.style.cardBorderRadius) / 3)
                            .stroke(Color(hex: theme.colors.border), lineWidth: 0.5)
                    )

                // Divider preview
                dividerPreview
                    .frame(width: 50, height: 1)

                // Accent dot
                Circle()
                    .fill(Color(hex: theme.colors.accent))
                    .frame(width: 8, height: 8)
            }
        }
        .frame(width: 80, height: 60)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }

    @ViewBuilder
    private var dividerPreview: some View {
        let dividerStyle = theme.blocks.divider
        GeometryReader { geometry in
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: geometry.size.width, y: 0))
            }
            .stroke(
                Color(hex: dividerStyle.lineColor),
                style: strokeStyle(for: dividerStyle.lineStyle)
            )
        }
    }

    private func strokeStyle(for lineStyle: DividerLineStyle) -> StrokeStyle {
        switch lineStyle {
        case .solid:
            return StrokeStyle(lineWidth: 1)
        case .dashed:
            return StrokeStyle(lineWidth: 1, dash: [4, 2])
        case .dotted:
            return StrokeStyle(lineWidth: 1, lineCap: .round, dash: [1, 2])
        }
    }
}

// MARK: - Preview

#Preview("Theme Picker") {
    VStack {
        Spacer()

        ThemePickerBar(
            themes: JournalTheme.systemThemes,
            selectedTheme: .constant(.default),
            isLoading: false
        )

        Spacer()
    }
    .background(AppTheme.Colors.passportPageDark)
}

#Preview("Loading State") {
    VStack {
        Spacer()

        ThemePickerBar(
            themes: [],
            selectedTheme: .constant(.default),
            isLoading: true
        )

        Spacer()
    }
    .background(AppTheme.Colors.passportPageDark)
}

#Preview("Passport Selected") {
    VStack {
        Spacer()

        ThemePickerBar(
            themes: JournalTheme.systemThemes,
            selectedTheme: .constant(.passport),
            isLoading: false
        )

        Spacer()
    }
    .background(AppTheme.Colors.passportPageDark)
}
