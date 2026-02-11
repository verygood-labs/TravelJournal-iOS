//
//  JournalPreviewView.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 2/5/26.
//

import SwiftUI

// MARK: - Journal Preview View

/// Main preview container that renders the journal with the selected theme.
struct JournalPreviewView: View {
    // MARK: - Properties

    let title: String
    let description: String?
    let coverImageUrl: String?
    let startDate: Date?
    let endDate: Date?
    let stops: [TripStop]
    let blocks: [EditorBlock]

    @Environment(\.journalTheme) private var theme

    // MARK: - Body

    var body: some View {
        // Journal content
        ScrollView {
            VStack(spacing: 0) {
                // Background with optional texture
                ZStack {
                    // Base background
                    theme.colors.backgroundColor
                        .ignoresSafeArea()

                    // Optional paper texture
                    if theme.style.showPaperTexture {
                        paperTextureOverlay
                    }

                    // Optional grid lines
                    if theme.style.showGridLines {
                        gridLinesOverlay
                    }

                    // Content
                    journalContent
                }
            }
        }
        .background(theme.colors.backgroundColor)
    }

    // MARK: - Journal Content

    private var journalContent: some View {
        VStack(spacing: 0) {
            // Header
            ThemedJournalHeader(
                title: title,
                description: description,
                coverImageUrl: coverImageUrl,
                startDate: startDate,
                endDate: endDate,
                stops: stops,
                statsConfig: .preview
            )

            // Blocks
            LazyVStack(spacing: 16) {
                ForEach(blocks.sorted(by: { $0.order < $1.order })) { block in
                    blockView(for: block)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Block Views

    @ViewBuilder
    private func blockView(for block: EditorBlock) -> some View {
        switch block.type {
        case .moment:
            ThemedMomentCard(block: block, actionConfig: .preview)

        case .recommendation:
            ThemedRecommendationCard(block: block, actionConfig: .preview)

        case .photo:
            ThemedPhotoCard(block: block, actionConfig: .preview)

        case .tip:
            ThemedTipCard(block: block, actionConfig: .preview)

        case .divider:
            ThemedDividerView()
        }
    }

    // MARK: - Paper Texture Overlay

    private var paperTextureOverlay: some View {
        GeometryReader { geometry in
            // Simple noise pattern to simulate paper texture
            Canvas { context, size in
                for _ in 0..<500 {
                    let x = CGFloat.random(in: 0...size.width)
                    let y = CGFloat.random(in: 0...size.height)
                    let opacity = Double.random(in: 0.02...0.06)

                    context.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: 1, height: 1)),
                        with: .color(.black.opacity(opacity))
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Grid Lines Overlay

    private var gridLinesOverlay: some View {
        GeometryReader { geometry in
            Path { path in
                let spacing: CGFloat = 24

                // Horizontal lines
                for y in stride(from: 0, to: geometry.size.height, by: spacing) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                }

                // Vertical lines
                for x in stride(from: 0, to: geometry.size.width, by: spacing) {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                }
            }
            .stroke(theme.colors.borderColor.opacity(0.3), lineWidth: 0.5)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Preview

#Preview("Default Theme") {
    JournalPreviewView(
        title: "Two Weeks in the Philippines",
        description: "Island hopping adventure through paradise",
        coverImageUrl: nil,
        startDate: Date(),
        endDate: Date().addingTimeInterval(86400 * 14),
        stops: [
            TripStop(id: UUID(), order: 0, arrivalDate: nil, place: TripStopPlace(id: UUID(), name: "Manila", displayName: "Manila, Philippines", placeType: .city, countryCode: "PH", latitude: 14.5995, longitude: 120.9842)),
            TripStop(id: UUID(), order: 1, arrivalDate: nil, place: TripStopPlace(id: UUID(), name: "Palawan", displayName: "Palawan, Philippines", placeType: .city, countryCode: "PH", latitude: 9.8349, longitude: 118.7384)),
        ],
        blocks: sampleBlocks
    )
    .journalTheme(.default)
}

#Preview("Passport Theme") {
    JournalPreviewView(
        title: "Two Weeks in the Philippines",
        description: "Island hopping adventure through paradise",
        coverImageUrl: nil,
        startDate: Date(),
        endDate: Date().addingTimeInterval(86400 * 14),
        stops: [
            TripStop(id: UUID(), order: 0, arrivalDate: nil, place: TripStopPlace(id: UUID(), name: "Manila", displayName: "Manila, Philippines", placeType: .city, countryCode: "PH", latitude: 14.5995, longitude: 120.9842)),
        ],
        blocks: sampleBlocks
    )
    .journalTheme(.passport)
}

#Preview("Retro Theme") {
    JournalPreviewView(
        title: "Two Weeks in the Philippines",
        description: "Island hopping adventure through paradise",
        coverImageUrl: nil,
        startDate: Date(),
        endDate: Date().addingTimeInterval(86400 * 14),
        stops: [
            TripStop(id: UUID(), order: 0, arrivalDate: nil, place: TripStopPlace(id: UUID(), name: "Manila", displayName: "Manila, Philippines", placeType: .city, countryCode: "PH", latitude: 14.5995, longitude: 120.9842)),
        ],
        blocks: sampleBlocks
    )
    .journalTheme(.retro)
}

// MARK: - Sample Data

private let sampleBlocks: [EditorBlock] = [
    EditorBlock.newMoment(
        order: 0,
        date: "Jan 15, 2026",
        title: "Arrival in Manila",
        content: "Landed at NAIA around 6am, groggy but excited. The humidity hit immediately.",
        stampText: "PH"
    ),
    EditorBlock.newPhoto(
        order: 1,
        imageUrl: "https://images.unsplash.com/photo-1518509562904-e7ef99cdcc86?w=800",
        caption: "Sunset over Manila Bay"
    ),
    EditorBlock.newTip(
        order: 2,
        title: "Getting Around",
        content: "Use Grab for affordable transportation. Much cheaper and safer than regular taxis."
    ),
    EditorBlock.newRecommendation(
        order: 3,
        name: "Aristocrat Restaurant",
        category: .eat,
        rating: .a,
        priceLevel: 2,
        note: "Best chicken barbecue in Manila! A must-visit institution since 1936."
    ),
    EditorBlock.newDivider(order: 4),
    EditorBlock.newMoment(
        order: 5,
        date: "Jan 16, 2026",
        title: "Exploring Intramuros",
        content: "Spent the morning walking through the old walled city. The Spanish colonial architecture is stunning."
    ),
]
