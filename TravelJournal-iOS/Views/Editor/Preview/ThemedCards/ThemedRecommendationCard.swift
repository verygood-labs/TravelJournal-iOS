//
//  ThemedRecommendationCard.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 2/5/26.
//

import SwiftUI

// MARK: - Themed Recommendation Card

/// A themed card for displaying recommendation blocks in preview mode.
struct ThemedRecommendationCard: View {
    let block: EditorBlock
    @Environment(\.journalTheme) private var theme

    // MARK: - Computed Properties

    private var recStyle: RecommendationBlockStyle {
        theme.blocks.recommendation
    }

    private var data: EditorBlockData {
        block.data
    }

    private var category: RecommendationCategory {
        data.category ?? .do
    }

    private var badgeStyle: CategoryBadgeStyle {
        recStyle.badgeStyle(for: category)
    }

    private var hasImage: Bool {
        data.imageUrl != nil && !data.imageUrl!.isEmpty
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Category header (full width)
            categoryHeader

            // Image section (if present)
            if hasImage {
                imageSection
            }

            // Content section
            VStack(alignment: .leading, spacing: 12) {
                // Name row with rating badge
                HStack(alignment: .top) {
                    if let name = data.name {
                        Text(name)
                            .font(theme.typography.headingFont(size: 18, weight: .semibold))
                            .foregroundColor(theme.colors.textPrimaryColor)
                    }

                    Spacer()

                    if let rating = data.rating {
                        ratingBadge(rating)
                    }
                }

                // Location and price row
                if block.location != nil || data.priceLevel != nil {
                    HStack(spacing: 8) {
                        if let location = block.location {
                            locationLabel(location)
                        }

                        if block.location != nil && data.priceLevel != nil {
                            Text("·")
                                .font(theme.typography.labelFont(size: 12))
                                .foregroundColor(theme.colors.textMutedColor)
                        }

                        if let priceLevel = data.priceLevel {
                            priceLevelLabel(priceLevel)
                        }
                    }
                }

                // Note as blockquote
                if let note = data.note, !note.isEmpty {
                    noteBlockquote(note)
                }
            }
            .padding(16)
        }
        .background(recStyle.cardBackgroundColor)
        .cornerRadius(theme.style.borderRadius)
        .shadow(
            color: theme.style.cardShadow ? Color.black.opacity(0.08) : .clear,
            radius: theme.style.cardShadow ? 8 : 0,
            x: 0,
            y: theme.style.cardShadow ? 2 : 0
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.style.borderRadius)
                .stroke(
                    theme.style.borderRadius == 0 ? theme.colors.borderColor : theme.colors.borderColor.opacity(0.5),
                    lineWidth: theme.style.borderRadius == 0 ? 2 : 1
                )
        )
    }

    // MARK: - Category Header

    private var categoryHeader: some View {
        HStack(spacing: 6) {
            Image(systemName: category.icon)
                .font(.system(size: 12, weight: .semibold))

            Text(category.displayName.uppercased())
                .font(theme.typography.labelFont(size: 10, weight: .bold))
                .tracking(0.5)
        }
        .foregroundColor(badgeStyle.textColor)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(badgeStyle.backgroundColor)
    }

    // MARK: - Image Section

    @ViewBuilder
    private var imageSection: some View {
        if let imageUrl = data.imageUrl {
            AsyncImage(url: APIService.shared.fullMediaURL(for: imageUrl)) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(theme.colors.borderColor.opacity(0.3))
                        .aspectRatio(16 / 9, contentMode: .fit)
                        .overlay(
                            ProgressView()
                                .tint(theme.colors.textMutedColor)
                        )
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxHeight: 180)
                        .clipped()
                case .failure:
                    Rectangle()
                        .fill(theme.colors.borderColor.opacity(0.3))
                        .aspectRatio(16 / 9, contentMode: .fit)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.title)
                                .foregroundColor(theme.colors.textMutedColor)
                        )
                @unknown default:
                    EmptyView()
                }
            }
        }
    }

    // MARK: - Rating Badge

    private func ratingBadge(_ rating: Rating) -> some View {
        Text(rating.displayName)
            .font(theme.typography.labelFont(size: 16, weight: .bold))
            .foregroundColor(.white)
            .frame(width: 36, height: 36)
            .background(rating.color)
            .cornerRadius(6)
    }

    // MARK: - Location Label

    private func locationLabel(_ location: EditorLocation) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 12))
            Text(location.displayName.uppercased())
                .font(theme.typography.labelFont(size: 11, weight: .medium))
                .tracking(0.3)
        }
        .foregroundColor(theme.colors.textMutedColor)
    }

    // MARK: - Price Level Label

    private func priceLevelLabel(_ level: Int) -> some View {
        Text(String(repeating: "₱", count: level))
            .font(theme.typography.labelFont(size: 12, weight: .medium))
            .foregroundColor(theme.colors.textMutedColor)
    }

    // MARK: - Note Blockquote

    private func noteBlockquote(_ note: String) -> some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(theme.colors.borderColor)
                .frame(width: 3)

            Text("\u{201C}\(note)\u{201D}")
                .font(theme.typography.bodyFont(size: 14))
                .foregroundColor(theme.colors.textSecondaryColor)
                .italic()
                .padding(.leading, 12)
                .padding(.vertical, 8)
        }
        .background(theme.colors.borderColor.opacity(0.08))
    }
}

// MARK: - Preview

#Preview("Default Theme") {
    ScrollView {
        VStack(spacing: 16) {
            ThemedRecommendationCard(block: .sampleStay)
            ThemedRecommendationCard(block: .sampleEatWithPhoto)
            ThemedRecommendationCard(block: .sampleDo)
            ThemedRecommendationCard(block: .sampleShop)
        }
        .padding()
    }
    .background(Color(hex: "#f5f5f5"))
    .journalTheme(.default)
}

#Preview("Passport Theme") {
    ScrollView {
        VStack(spacing: 16) {
            ThemedRecommendationCard(block: .sampleStay)
            ThemedRecommendationCard(block: .sampleEatWithPhoto)
            ThemedRecommendationCard(block: .sampleDo)
        }
        .padding()
    }
    .background(Color(hex: "#f5f1e8"))
    .journalTheme(.passport)
}

#Preview("Retro Theme") {
    ScrollView {
        VStack(spacing: 16) {
            ThemedRecommendationCard(block: .sampleEatWithPhoto)
            ThemedRecommendationCard(block: .sampleShop)
        }
        .padding()
    }
    .background(Color(hex: "#C0C0C0"))
    .journalTheme(.retro)
}

// MARK: - Sample Data

private extension EditorBlock {
    static let sampleStay: EditorBlock = {
        var block = EditorBlock.newRecommendation(
            order: 0,
            name: "Kawili Resort",
            category: .stay,
            rating: .a,
            priceLevel: 2,
            note: "Bamboo cottages with AC that actually works. Pool, good wifi, and walking distance to everything. The staff remembers your name by day 2.",
            location: EditorLocation(
                osmType: "node",
                osmId: 123456,
                name: "General Luna",
                displayName: "General Luna",
                latitude: 9.7894,
                longitude: 126.1169
            )
        )
        return block
    }()

    static let sampleEatWithPhoto = EditorBlock.newRecommendation(
        order: 1,
        name: "Aristocrat Restaurant",
        category: .eat,
        rating: .a,
        priceLevel: 2,
        note: "Best chicken barbecue in Manila! A must-visit institution since 1936.",
        imageUrl: "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400"
    )

    static let sampleDo = EditorBlock.newRecommendation(
        order: 2,
        name: "Intramuros Walking Tour",
        category: .do,
        rating: .s,
        note: "Carlos was an amazing guide. Learned so much about Philippine history."
    )

    static let sampleShop = EditorBlock.newRecommendation(
        order: 3,
        name: "Greenhills Shopping Center",
        category: .shop,
        priceLevel: 2,
        note: "Great for pearls and souvenirs. Bargaining is expected!"
    )
}
