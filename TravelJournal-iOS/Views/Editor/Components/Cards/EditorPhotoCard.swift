//
//  EditorPhotoCard.swift
//  TravelJournal-iOS
//

import SwiftUI

struct EditorPhotoCard: View {
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
                Text("PHOTO")
                    .font(AppTheme.Typography.monoCaption())
                    .tracking(1)
                    .foregroundColor(AppTheme.Colors.passportTextMuted)

                if let caption = block.data.caption, !caption.isEmpty {
                    Text(caption)
                        .font(AppTheme.Typography.monoMedium())
                        .foregroundColor(AppTheme.Colors.passportTextPrimary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                } else {
                    Text(hasImage ? "Add a caption..." : "Tap to add photo...")
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

#Preview("Photo Cards") {
    PassportPageBackgroundView {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.md) {
                // With thumbnail and caption
                EditorPhotoCard(
                    block: EditorBlock.newPhoto(
                        order: 0,
                        imageUrl: "https://picsum.photos/400",
                        caption: "Beautiful sunset at the beach"
                    ),
                    onTap: {}
                )

                // With thumbnail, no caption
                EditorPhotoCard(
                    block: EditorBlock.newPhoto(
                        order: 1,
                        imageUrl: "https://picsum.photos/401"
                    ),
                    onTap: {}
                )

                // Caption only, no image
                EditorPhotoCard(
                    block: EditorBlock.newPhoto(
                        order: 2,
                        caption: "A photo I'll add later"
                    ),
                    onTap: {}
                )

                // Empty state
                EditorPhotoCard(
                    block: EditorBlock.newPhoto(order: 3),
                    onTap: {}
                )
            }
            .padding()
        }
    }
}
