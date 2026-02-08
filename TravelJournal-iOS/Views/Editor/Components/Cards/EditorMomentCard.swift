//
//  EditorMomentCard.swift
//  TravelJournal-iOS
//

import SwiftUI

struct EditorMomentCard: View {
    let block: EditorBlock
    var isDragging: Bool = false
    let onTap: () -> Void

    private var hasImage: Bool {
        block.data.imageUrl != nil && !block.data.imageUrl!.isEmpty
    }

    var body: some View {
        HStack(alignment: .center, spacing: AppTheme.Spacing.sm) {
            // Drag handle
            DragHandle(isActive: isDragging)
                .coordinateSpace(name: EditorBlockCard.dragHandleCoordinateSpace)

            // Content area
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxxs) {
                Text("MOMENT")
                    .font(AppTheme.Typography.monoCaption())
                    .tracking(1)
                    .foregroundColor(AppTheme.Colors.passportTextMuted)

                if let title = block.data.title, !title.isEmpty {
                    Text(title)
                        .font(AppTheme.Typography.monoMedium())
                        .foregroundColor(AppTheme.Colors.passportTextPrimary)
                        .lineLimit(2)
                } else if let content = block.data.content, !content.isEmpty {
                    Text(content)
                        .font(AppTheme.Typography.monoMedium())
                        .foregroundColor(AppTheme.Colors.passportTextPrimary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                } else {
                    Text("Tap to edit...")
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

            // Thumbnail (only if image exists)
            if hasImage, let imageUrl = block.data.imageUrl {
                EditorThumbnail(imageUrl: imageUrl)
                    .onTapGesture {
                        onTap()
                    }
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(EditorCardStyle.backgroundGradient)
        .overlay(EditorCardStyle.borderOverlay)
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
}

// MARK: - Preview

#Preview("Moment Cards") {
    PassportPageBackgroundView {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.md) {
                // With title and content
                EditorMomentCard(
                    block: EditorBlock.newMoment(
                        order: 0,
                        title: "Arrival Day",
                        content: "Landed at NAIA around 6am, groggy but excited."
                    ),
                    onTap: {}
                )

                // With thumbnail
                EditorMomentCard(
                    block: EditorBlock.newMoment(
                        order: 1,
                        title: "Sunset at the Beach",
                        content: "The most beautiful sunset I've ever seen.",
                        imageUrl: "https://picsum.photos/200"
                    ),
                    onTap: {}
                )

                // Dragging state
                EditorMomentCard(
                    block: EditorBlock.newMoment(
                        order: 2,
                        title: "Dragging State",
                        content: "This card is being dragged"
                    ),
                    isDragging: true,
                    onTap: {}
                )

                // Empty state
                EditorMomentCard(
                    block: EditorBlock.newMoment(order: 3),
                    onTap: {}
                )
            }
            .padding()
        }
    }
}
