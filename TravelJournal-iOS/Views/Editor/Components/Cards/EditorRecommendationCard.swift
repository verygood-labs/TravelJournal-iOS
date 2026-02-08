//
//  EditorRecommendationCard.swift
//  TravelJournal-iOS
//

import SwiftUI

struct EditorRecommendationCard: View {
    let block: EditorBlock
    var isDragging: Bool = false
    let onTap: () -> Void

    private var hasImage: Bool {
        block.data.imageUrl != nil && !block.data.imageUrl!.isEmpty
    }

    var body: some View {
        HStack(alignment: .center, spacing: AppTheme.Spacing.sm) {
            // Drag handle (centered vertically on left)
            DragHandle(isActive: isDragging)
                .coordinateSpace(name: EditorBlockCard.dragHandleCoordinateSpace)

            // Main content
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                // Header row with content and thumbnail
                HStack(alignment: .center, spacing: AppTheme.Spacing.sm) {
                    // Header content
                    VStack(alignment: .leading, spacing: 2) {
                        // Name
                        if let name = block.data.name, !name.isEmpty {
                            Text(name)
                                .font(AppTheme.Typography.monoMedium())
                                .foregroundColor(AppTheme.Colors.passportTextPrimary)
                                .lineLimit(1)
                        } else {
                            Text("Tap to add...")
                                .font(AppTheme.Typography.monoSmall())
                                .foregroundColor(AppTheme.Colors.passportTextPlaceholder)
                        }

                        // Category
                        Text("Category: \(block.data.category?.displayName ?? "Recommendation")")
                            .font(AppTheme.Typography.monoCaption())
                            .foregroundColor(AppTheme.Colors.passportTextMuted)
                            .lineLimit(1)

                        // Rating
                        if let rating = block.data.rating {
                            Text("Rating: \(rating.displayName)")
                                .font(AppTheme.Typography.monoCaption())
                                .foregroundColor(AppTheme.Colors.passportTextMuted)
                                .lineLimit(1)
                        }

                        // Location
                        if let location = block.location {
                            Text("Location: \(location.cityAndState)")
                                .font(AppTheme.Typography.monoCaption())
                                .foregroundColor(AppTheme.Colors.passportTextMuted)
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onTap()
                    }

                    // Thumbnail (only if image exists)
                    if hasImage, let imageUrl = block.data.imageUrl {
                        EditorThumbnail(imageUrl: imageUrl)
                            .onTapGesture {
                                onTap()
                            }
                    }
                }

                // Description (full width, no quotes, no italics)
                if let note = block.data.note, !note.isEmpty {
                    Text(note)
                        .font(AppTheme.Typography.monoSmall())
                        .foregroundColor(AppTheme.Colors.passportTextSecondary)
                        .lineLimit(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onTapGesture {
                            onTap()
                        }
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

#Preview("Recommendation Cards") {
    PassportPageBackgroundView {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.md) {
                // With thumbnail, rating, location, and note
                EditorRecommendationCard(
                    block: EditorBlock.newRecommendation(
                        order: 0,
                        name: "South Beach",
                        category: .do,
                        rating: .a,
                        note: "Nice beach!!",
                        imageUrl: "https://picsum.photos/300",
                        location: EditorLocation(
                            osmType: "node",
                            osmId: 123456,
                            name: "South Beach",
                            displayName: "South Beach, Miami Beach, FL, US",
                            latitude: 25.7825,
                            longitude: -80.1340
                        )
                    ),
                    onTap: {}
                )

                // With long description
                EditorRecommendationCard(
                    block: EditorBlock.newRecommendation(
                        order: 1,
                        name: "Versailles Restaurant",
                        category: .eat,
                        rating: .s,
                        note: "The most authentic Cuban food in Miami. Try the ropa vieja and the Cuban sandwich. Get there early because the line gets really long on weekends!",
                        imageUrl: "https://picsum.photos/302",
                        location: EditorLocation(
                            osmType: "node",
                            osmId: 789012,
                            name: "Versailles",
                            displayName: "Versailles, Little Havana, Miami, FL, US",
                            latitude: 25.7650,
                            longitude: -80.3100
                        )
                    ),
                    onTap: {}
                )

                // With rating (no image)
                EditorRecommendationCard(
                    block: EditorBlock.newRecommendation(
                        order: 2,
                        name: "Aristocrat Restaurant",
                        category: .eat,
                        rating: .b,
                        priceLevel: 2
                    ),
                    onTap: {}
                )

                // Stay category with thumbnail
                EditorRecommendationCard(
                    block: EditorBlock.newRecommendation(
                        order: 3,
                        name: "Grand Hyatt",
                        category: .stay,
                        rating: .s,
                        imageUrl: "https://picsum.photos/301"
                    ),
                    onTap: {}
                )

                // Shop category (no rating, no image)
                EditorRecommendationCard(
                    block: EditorBlock.newRecommendation(
                        order: 4,
                        name: "Local Craft Market",
                        category: .shop
                    ),
                    onTap: {}
                )

                // Empty state
                EditorRecommendationCard(
                    block: EditorBlock.newRecommendation(
                        order: 5,
                        name: "",
                        category: .stay
                    ),
                    onTap: {}
                )
            }
            .padding()
        }
    }
}
