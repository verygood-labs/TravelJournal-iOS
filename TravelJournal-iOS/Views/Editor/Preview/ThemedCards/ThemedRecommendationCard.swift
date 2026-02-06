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
        HStack(alignment: .top, spacing: 12) {
            // Image or icon
            leadingContent

            // Details
            VStack(alignment: .leading, spacing: 6) {
                // Category badge
                categoryBadge

                // Name
                if let name = data.name {
                    Text(name)
                        .font(theme.typography.headingFont(size: 17, weight: .semibold))
                        .foregroundColor(theme.colors.textPrimaryColor)
                }

                // Rating and price
                if data.rating != nil || data.priceLevel != nil {
                    HStack(spacing: 12) {
                        if let rating = data.rating {
                            ratingView(rating)
                        }
                        if let priceLevel = data.priceLevel {
                            priceLevelView(priceLevel)
                        }
                    }
                }

                // Note
                if let note = data.note, !note.isEmpty {
                    Text(note)
                        .font(theme.typography.bodyFont(size: 14))
                        .foregroundColor(theme.colors.textSecondaryColor)
                        .lineLimit(3)
                }

                // Location
                if let location = block.location {
                    locationRow(location)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(14)
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
                .stroke(theme.colors.borderColor.opacity(0.5), lineWidth: 1)
        )
    }

    // MARK: - Leading Content

    @ViewBuilder
    private var leadingContent: some View {
        if hasImage, let imageUrl = data.imageUrl {
            AsyncImage(url: URL(string: imageUrl)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 70, height: 70)
                        .cornerRadius(theme.style.borderRadius / 2)
                        .clipped()
                default:
                    iconPlaceholder
                }
            }
        } else {
            iconPlaceholder
        }
    }

    private var iconPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: theme.style.borderRadius / 2)
                .fill(badgeStyle.backgroundColor.opacity(0.15))
                .frame(width: 70, height: 70)

            Image(systemName: category.icon)
                .font(.system(size: 24))
                .foregroundColor(badgeStyle.backgroundColor)
        }
    }

    // MARK: - Category Badge

    private var categoryBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: category.icon)
                .font(.system(size: 10, weight: .semibold))

            Text(category.displayName.uppercased())
                .font(theme.typography.labelFont(size: 9, weight: .bold))
                .tracking(0.5)
        }
        .foregroundColor(badgeStyle.textColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(badgeStyle.backgroundColor)
        .cornerRadius(4)
    }

    // MARK: - Rating View

    private func ratingView(_ rating: Rating) -> some View {
        Text(rating.displayName)
            .font(theme.typography.labelFont(size: 14, weight: .bold))
            .foregroundColor(.white)
            .frame(width: 24, height: 24)
            .background(rating.color)
            .cornerRadius(4)
    }

    // MARK: - Price Level View

    private func priceLevelView(_ level: Int) -> some View {
        HStack(spacing: 1) {
            ForEach(0..<4) { index in
                Text("$")
                    .font(theme.typography.labelFont(size: 11, weight: .medium))
                    .foregroundColor(
                        index < level
                            ? theme.colors.textPrimaryColor
                            : theme.colors.textMutedColor.opacity(0.4)
                    )
            }
        }
    }

    // MARK: - Location Row

    private func locationRow(_ location: EditorLocation) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "mappin")
                .font(.system(size: 10))
            Text(location.displayName)
                .font(theme.typography.labelFont(size: 11))
        }
        .foregroundColor(theme.colors.textMutedColor)
        .padding(.top, 2)
    }
}

// MARK: - Preview

#Preview("Default Theme") {
    ScrollView {
        VStack(spacing: 16) {
            ThemedRecommendationCard(block: .sampleStay)
            ThemedRecommendationCard(block: .sampleEat)
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
            ThemedRecommendationCard(block: .sampleEat)
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
            ThemedRecommendationCard(block: .sampleEat)
            ThemedRecommendationCard(block: .sampleShop)
        }
        .padding()
    }
    .background(Color(hex: "#C0C0C0"))
    .journalTheme(.retro)
}

// MARK: - Sample Data

private extension EditorBlock {
    static let sampleStay = EditorBlock.newRecommendation(
        order: 0,
        name: "The Peninsula Manila",
        category: .stay,
        rating: .a,
        priceLevel: 4,
        note: "Iconic luxury hotel in Makati. The lobby is stunning and the afternoon tea is a must."
    )

    static let sampleEat = EditorBlock.newRecommendation(
        order: 1,
        name: "Aristocrat Restaurant",
        category: .eat,
        rating: .a,
        priceLevel: 2,
        note: "Best chicken barbecue in Manila! A must-visit institution since 1936."
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
