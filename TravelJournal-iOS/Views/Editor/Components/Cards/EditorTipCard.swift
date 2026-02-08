//
//  EditorTipCard.swift
//  TravelJournal-iOS
//

import SwiftUI

struct EditorTipCard: View {
    let block: EditorBlock
    var isDragging: Bool = false
    let onTap: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: AppTheme.Spacing.sm) {
            // Drag handle
            DragHandle(isActive: isDragging)
                .coordinateSpace(name: EditorBlockCard.dragHandleCoordinateSpace)

            // Content area
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxxs) {
                Text("TIP")
                    .font(AppTheme.Typography.monoCaption())
                    .tracking(1)
                    .foregroundColor(AppTheme.Colors.passportTextMuted)

                if let title = block.data.title, !title.isEmpty {
                    Text(title)
                        .font(AppTheme.Typography.monoMedium())
                        .foregroundColor(AppTheme.Colors.passportTextPrimary)
                        .lineLimit(2)

                    if let content = block.data.content, !content.isEmpty {
                        Text(content)
                            .font(AppTheme.Typography.monoSmall())
                            .foregroundColor(AppTheme.Colors.passportTextSecondary)
                            .lineLimit(2)
                    }
                } else if let content = block.data.content, !content.isEmpty {
                    Text(content)
                        .font(AppTheme.Typography.monoMedium())
                        .foregroundColor(AppTheme.Colors.passportTextPrimary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                } else {
                    Text("Tap to add a tip...")
                        .font(AppTheme.Typography.monoSmall())
                        .foregroundColor(AppTheme.Colors.passportTextPlaceholder)
                        .italic()
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }

            Spacer()
        }
        .padding(AppTheme.Spacing.md)
        .background(EditorCardStyle.backgroundGradient)
        .overlay(EditorCardStyle.borderOverlay)
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
}

// MARK: - Preview

#Preview("Tip Cards") {
    PassportPageBackgroundView {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.md) {
                // With title and content
                EditorTipCard(
                    block: EditorBlock.newTip(
                        order: 0,
                        title: "Pro Tip",
                        content: "Book your flights early for better prices!"
                    ),
                    onTap: {}
                )

                // Content only (no title)
                EditorTipCard(
                    block: EditorBlock.newTip(
                        order: 1,
                        content: "Always carry a power bank when traveling."
                    ),
                    onTap: {}
                )

                // Dragging state
                EditorTipCard(
                    block: EditorBlock.newTip(
                        order: 2,
                        title: "Money Saver",
                        content: "Use local SIM cards instead of roaming."
                    ),
                    isDragging: true,
                    onTap: {}
                )

                // Empty state
                EditorTipCard(
                    block: EditorBlock.newTip(order: 3),
                    onTap: {}
                )
            }
            .padding()
        }
    }
}
