//
//  ThemedMomentCard.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 2/5/26.
//

import SwiftUI

// MARK: - Themed Moment Card

/// A themed card for displaying moment blocks in preview mode.
struct ThemedMomentCard: View {
    let block: EditorBlock
    @Environment(\.journalTheme) private var theme

    // MARK: - Computed Properties

    private var momentStyle: MomentBlockStyle {
        theme.blocks.moment
    }

    private var data: EditorBlockData {
        block.data
    }

    private var hasImage: Bool {
        data.imageUrl != nil && !data.imageUrl!.isEmpty
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image section (if present)
            if hasImage {
                imageSection
            }

            // Content section
            VStack(alignment: .leading, spacing: theme.style.borderRadius > 8 ? 12 : 8) {
                // Date and stamp row
                if data.date != nil || data.stampText != nil {
                    HStack {
                        if let date = data.date {
                            Text(date.uppercased())
                                .font(theme.typography.labelFont(size: 10, weight: .medium))
                                .foregroundColor(theme.colors.textMutedColor)
                                .tracking(1)
                        }

                        Spacer()

                        if let stampText = data.stampText {
                            stampView(text: stampText)
                        }
                    }
                }

                // Title
                if let title = data.title, !title.isEmpty {
                    Text(title)
                        .font(theme.typography.headingFont(size: 20, weight: .semibold))
                        .foregroundColor(theme.colors.textPrimaryColor)
                }

                // Content
                if let content = data.content, !content.isEmpty {
                    Text(content)
                        .font(theme.typography.bodyFont(size: 15))
                        .foregroundColor(theme.colors.textSecondaryColor)
                        .lineSpacing(4)
                }

                // Location
                if let location = block.location {
                    locationRow(location)
                }
            }
            .padding(16)
        }
        .background(momentStyle.cardBackgroundColor)
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

    // MARK: - Image Section

    @ViewBuilder
    private var imageSection: some View {
        if let imageUrl = data.imageUrl {
            AsyncImage(url: URL(string: imageUrl)) { phase in
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
                        .frame(maxHeight: 200)
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

    // MARK: - Stamp View

    @ViewBuilder
    private func stampView(text: String) -> some View {
        switch momentStyle.stampStyle {
        case .minimal:
            Text(text.uppercased())
                .font(theme.typography.labelFont(size: 9, weight: .bold))
                .foregroundColor(momentStyle.stampSwiftUIColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(momentStyle.stampSwiftUIColor.opacity(0.1))
                .cornerRadius(4)

        case .rubber:
            Text(text.uppercased())
                .font(theme.typography.labelFont(size: 10, weight: .bold))
                .foregroundColor(momentStyle.stampSwiftUIColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(momentStyle.stampSwiftUIColor, lineWidth: 2)
                )
                .rotationEffect(.degrees(-5))

        case .vintage:
            Text(text.uppercased())
                .font(theme.typography.labelFont(size: 10, weight: .bold))
                .foregroundColor(momentStyle.stampSwiftUIColor.opacity(0.8))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 2)
                        .fill(momentStyle.stampSwiftUIColor.opacity(0.15))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(momentStyle.stampSwiftUIColor.opacity(0.5), lineWidth: 1)
                )
                .rotationEffect(.degrees(-3))
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
    }
}

// MARK: - Preview

#Preview("Default Theme") {
    ScrollView {
        VStack(spacing: 16) {
            ThemedMomentCard(block: .sampleMoment)
            ThemedMomentCard(block: .sampleMomentWithImage)
            ThemedMomentCard(block: .sampleMomentMinimal)
        }
        .padding()
    }
    .background(Color(hex: "#f5f5f5"))
    .journalTheme(.default)
}

#Preview("Passport Theme") {
    ScrollView {
        VStack(spacing: 16) {
            ThemedMomentCard(block: .sampleMoment)
            ThemedMomentCard(block: .sampleMomentWithImage)
        }
        .padding()
    }
    .background(Color(hex: "#f5f1e8"))
    .journalTheme(.passport)
}

#Preview("Retro Theme") {
    ScrollView {
        VStack(spacing: 16) {
            ThemedMomentCard(block: .sampleMoment)
            ThemedMomentCard(block: .sampleMomentWithImage)
        }
        .padding()
    }
    .background(Color(hex: "#C0C0C0"))
    .journalTheme(.retro)
}

// MARK: - Sample Data

private extension EditorBlock {
    static let sampleMoment = EditorBlock.newMoment(
        order: 0,
        date: "Jan 15, 2026",
        title: "Arrival in Manila",
        content: "Landed at NAIA around 6am, groggy but excited. The humidity hit immediately. Grabbed a Grab to Makati and checked into the hotel.",
        stampText: "PH",
        stampColor: "#CE1126"
    )

    static let sampleMomentWithImage = EditorBlock.newMoment(
        order: 1,
        date: "Jan 16, 2026",
        title: "Exploring Intramuros",
        content: "Spent the morning walking through the old walled city. The Spanish colonial architecture is stunning.",
        imageUrl: "https://images.unsplash.com/photo-1518509562904-e7ef99cdcc86?w=800",
        stampText: "Manila"
    )

    static let sampleMomentMinimal = EditorBlock.newMoment(
        order: 2,
        content: "Quick coffee stop before heading to the airport. Already missing the food here."
    )
}
