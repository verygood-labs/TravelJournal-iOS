//
//  EditorBlockCard.swift
//  TravelJournal-iOS
//

import SwiftUI

struct EditorBlockCard: View {
    let block: EditorBlock
    var isDragging: Bool = false
    let onTap: () -> Void

    /// Coordinate space name for hit testing
    static let dragHandleCoordinateSpace = "dragHandle"

    var body: some View {
        VStack(spacing: 0) {
            // Polaroid-style image for photo blocks
            if block.type == .photo, let imageUrl = block.data.imageUrl, !imageUrl.isEmpty {
                photoImageSection(imageUrl: imageUrl)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.top, AppTheme.Spacing.md)
            }

            // Standard card content
            HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                // Drag handle with named coordinate space
                DragHandle(isActive: isDragging)
                    .coordinateSpace(name: EditorBlockCard.dragHandleCoordinateSpace)

                // Content area
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xxxs) {
                    Text(block.type.rawValue.uppercased())
                        .font(AppTheme.Typography.monoCaption())
                        .tracking(1)
                        .foregroundColor(AppTheme.Colors.passportTextMuted)

                    if let preview = blockPreviewText, !preview.isEmpty {
                        Text(preview)
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

                blockTypeIcon
                    .onTapGesture {
                        onTap()
                    }
            }
            .padding(AppTheme.Spacing.md)
        }
        .background(
            LinearGradient(
                colors: [
                    AppTheme.Colors.passportPageLight,
                    AppTheme.Colors.passportPageDark,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .stroke(AppTheme.Colors.passportInputBorder, lineWidth: 1)
        )
        .cornerRadius(AppTheme.CornerRadius.medium)
    }

    // MARK: - Photo Image Section

    private func photoImageSection(imageUrl: String) -> some View {
        GeometryReader { geometry in
            AsyncImage(url: APIService.shared.fullMediaURL(for: imageUrl)) { phase in
                switch phase {
                case .empty:
                    imagePlaceholder
                        .overlay(ProgressView())
                case let .success(image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .clipped()
                case .failure:
                    imagePlaceholder
                        .overlay(
                            VStack(spacing: AppTheme.Spacing.xs) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 24))
                                Text("Failed to load")
                                    .font(AppTheme.Typography.monoCaption())
                            }
                            .foregroundColor(AppTheme.Colors.passportTextMuted)
                        )
                @unknown default:
                    imagePlaceholder
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .cornerRadius(AppTheme.CornerRadius.small)
        .onTapGesture {
            onTap()
        }
    }

    // MARK: - Image Placeholder

    private var imagePlaceholder: some View {
        Rectangle()
            .fill(AppTheme.Colors.passportInputBackground)
    }

    // MARK: - Block Preview Text

    private var blockPreviewText: String? {
        switch block.type {
        case .moment:
            return block.data.title ?? block.data.content
        case .recommendation:
            return block.data.name
        case .photo:
            return block.data.caption
        case .tip:
            return block.data.title ?? block.data.content
        case .divider:
            return "───"
        }
    }

    // MARK: - Block Type Icon

    private var blockTypeIcon: some View {
        Image(systemName: block.type.icon)
            .font(.system(size: 16))
            .foregroundColor(AppTheme.Colors.primary)
            .frame(width: 32, height: 32)
            .background(AppTheme.Colors.primary.opacity(0.1))
            .cornerRadius(AppTheme.CornerRadius.small)
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
                    name: "Aristocrat Restaurant",
                    category: .eat
                ),
                onTap: {}
            )
        }
        .padding()
    }
}
