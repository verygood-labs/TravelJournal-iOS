//
//  EditorBlockCard.swift
//  TravelJournal-iOS
//

import SwiftUI

/// Dispatcher view that routes to the appropriate block-specific card
struct EditorBlockCard: View {
    let block: EditorBlock
    var isDragging: Bool = false
    let onTap: () -> Void

    /// Coordinate space name for hit testing (shared across all card types)
    static let dragHandleCoordinateSpace = "dragHandle"

    var body: some View {
        switch block.type {
        case .moment:
            EditorMomentCard(block: block, isDragging: isDragging, onTap: onTap)
        case .recommendation:
            EditorRecommendationCard(block: block, isDragging: isDragging, onTap: onTap)
        case .photo:
            EditorPhotoCard(block: block, isDragging: isDragging, onTap: onTap)
        case .tip:
            EditorTipCard(block: block, isDragging: isDragging, onTap: onTap)
        case .divider:
            // Dividers are handled by EditorDividerRow
            EmptyView()
        }
    }
}

// MARK: - Preview

#Preview {
    PassportPageBackgroundView {
        VStack(spacing: AppTheme.Spacing.md) {
            EditorBlockCard(
                block: EditorBlock.newMoment(
                    order: 0,
                    title: "Arrival Day",
                    content: "Landed at NAIA around 6am, groggy but excited."
                ),
                isDragging: false,
                onTap: {}
            )

            EditorBlockCard(
                block: EditorBlock.newMoment(
                    order: 1,
                    title: "Dragging State",
                    content: "This card is being dragged"
                ),
                isDragging: true,
                onTap: {}
            )

            EditorBlockCard(
                block: EditorBlock.newPhoto(
                    order: 2,
                    imageUrl: nil,
                    caption: nil
                ),
                onTap: {}
            )

            EditorBlockCard(
                block: EditorBlock.newRecommendation(
                    order: 3,
                    name: "South Beach",
                    category: .do,
                    rating: .a,
                    note: "Nice beach!!",
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

            EditorBlockCard(
                block: EditorBlock.newTip(
                    order: 4,
                    title: "Pro Tip",
                    content: "Book early for better prices!"
                ),
                onTap: {}
            )
        }
        .padding()
    }
}
