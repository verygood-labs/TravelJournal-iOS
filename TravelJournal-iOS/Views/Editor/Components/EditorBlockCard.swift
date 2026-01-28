//
//  EditorBlockCard.swift
//  TravelJournal-iOS
//

import SwiftUI

struct EditorBlockCard: View {
    let block: EditorBlock
    let onTap: () -> Void
    
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
                blockNumberBadge
                
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
                
                Spacer()
                
                blockTypeIcon
            }
            .padding(AppTheme.Spacing.md)
        }
        .background(
            LinearGradient(
                colors: [
                    AppTheme.Colors.passportPageLight,
                    AppTheme.Colors.passportPageDark
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
        .onTapGesture {
            onTap()
        }
    }
    
    // MARK: - Photo Image Section

    private func photoImageSection(imageUrl: String) -> some View {
        GeometryReader { geometry in
            AsyncImage(url: APIService.shared.fullMediaURL(for: imageUrl)) { phase in
                switch phase {
                case .empty:
                    imagePlaceholder
                        .overlay(ProgressView())
                case .success(let image):
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
    
    // MARK: - Block Number Badge

    private var blockNumberBadge: some View {
        Text("\(block.order + 1)")
            .font(AppTheme.Typography.monoSmall())
            .fontWeight(.semibold)
            .foregroundColor(AppTheme.Colors.backgroundDark)
            .frame(width: 28, height: 28)
            .background(AppTheme.Colors.primary)
            .clipShape(Circle())
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
                onTap: {}
            )
            
            EditorBlockCard(
                block: EditorBlock.newPhoto(
                    order: 1,
                    imageUrl: "/media/sample.jpg",
                    caption: "First glimpse of Manila skyline"
                ),
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
