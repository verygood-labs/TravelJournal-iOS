//
//  JournalEntry+Preview.swift
//  TravelJournal-iOS
//
//  Created on 2/8/26.
//

import Foundation

#if DEBUG
extension JournalEntry {
    // MARK: - Sample Entries

    /// A sample moment entry for previews.
    static func previewMoment(
        id: UUID = UUID(),
        order: Int = 0,
        saveCount: Int = 24,
        isSaved: Bool? = false,
        date: String? = "Jan 15, 2026",
        title: String? = "Arrived in Tokyo",
        content: String? = "Finally landed after a 14-hour flight. The city lights at night are absolutely mesmerizing!",
        imageUrl: String? = nil,
        stampText: String? = "DAY 1",
        stampColor: String? = "#c9a227",
        place: PlaceSummary? = .previewTokyo
    ) -> JournalEntry {
        JournalEntry(
            id: id,
            order: order,
            blockType: .moment,
            saveCount: saveCount,
            isSaved: isSaved,
            moment: JournalMoment(
                id: UUID(),
                date: date,
                title: title,
                content: content,
                imageUrl: imageUrl,
                stampText: stampText,
                stampColor: stampColor,
                place: place
            ),
            recommendation: nil,
            photo: nil,
            tip: nil,
            divider: nil
        )
    }

    /// A sample tip entry for previews.
    static func previewTip(
        id: UUID = UUID(),
        order: Int = 1,
        saveCount: Int = 15,
        isSaved: Bool? = true,
        title: String? = "Getting Around",
        content: String? = "Get a Suica card at the airport - it works on all trains, buses, and even convenience stores!"
    ) -> JournalEntry {
        JournalEntry(
            id: id,
            order: order,
            blockType: .tip,
            saveCount: saveCount,
            isSaved: isSaved,
            moment: nil,
            recommendation: nil,
            photo: nil,
            tip: JournalTip(
                id: UUID(),
                title: title,
                content: content
            ),
            divider: nil
        )
    }

    /// A sample recommendation entry for previews.
    static func previewRecommendation(
        id: UUID = UUID(),
        order: Int = 2,
        saveCount: Int = 38,
        isSaved: Bool? = false,
        name: String = "Ichiran Ramen",
        category: RecommendationCategory = .eat,
        rating: Rating? = .s,
        priceLevel: Int? = 2,
        note: String? = "Best tonkotsu ramen I've ever had. The solo booth experience is unique!",
        imageUrl: String? = nil,
        place: PlaceSummary? = .previewShibuya
    ) -> JournalEntry {
        JournalEntry(
            id: id,
            order: order,
            blockType: .recommendation,
            saveCount: saveCount,
            isSaved: isSaved,
            moment: nil,
            recommendation: JournalRecommendation(
                id: UUID(),
                name: name,
                category: category,
                rating: rating,
                priceLevel: priceLevel,
                note: note,
                imageUrl: imageUrl,
                place: place
            ),
            photo: nil,
            tip: nil,
            divider: nil
        )
    }

    /// A sample photo entry for previews.
    static func previewPhoto(
        id: UUID = UUID(),
        order: Int = 3,
        saveCount: Int = 56,
        isSaved: Bool? = false,
        imageUrl: String? = nil,
        caption: String? = "Sunset over Mount Fuji from our hotel balcony",
        rotation: Int = 0
    ) -> JournalEntry {
        JournalEntry(
            id: id,
            order: order,
            blockType: .photo,
            saveCount: saveCount,
            isSaved: isSaved,
            moment: nil,
            recommendation: nil,
            photo: JournalPhoto(
                id: UUID(),
                imageUrl: imageUrl,
                caption: caption,
                rotation: rotation
            ),
            tip: nil,
            divider: nil
        )
    }

    /// A sample divider entry for previews.
    static func previewDivider(
        id: UUID = UUID(),
        order: Int = 4
    ) -> JournalEntry {
        JournalEntry(
            id: id,
            order: order,
            blockType: .divider,
            saveCount: 0,
            isSaved: nil,
            moment: nil,
            recommendation: nil,
            photo: nil,
            tip: nil,
            divider: JournalDivider(id: UUID())
        )
    }

    // MARK: - Sample Entry Collections

    /// A typical journal with mixed entry types.
    static let previewEntries: [JournalEntry] = [
        .previewMoment(order: 0),
        .previewTip(order: 1),
        .previewMoment(
            order: 2,
            saveCount: 42,
            date: "Jan 16, 2026",
            title: "Exploring Shibuya",
            content: "Crossed the famous Shibuya crossing during rush hour. Pure chaos but unforgettable!",
            stampText: "DAY 2",
            stampColor: "#FF5733",
            place: .previewShibuya
        ),
        .previewRecommendation(order: 3),
        .previewDivider(order: 4),
        .previewMoment(
            order: 5,
            saveCount: 31,
            date: "Jan 17, 2026",
            title: "Day Trip to Kyoto",
            content: "Took the Shinkansen to Kyoto. The temples are even more beautiful than photos suggest.",
            stampText: "DAY 3",
            stampColor: "#28a745",
            place: .previewKyoto
        )
    ]
}

// MARK: - Array Extension for Preview Inference

extension Array where Element == JournalEntry {
    /// Convenience for type inference in previews.
    static var previewEntries: [JournalEntry] {
        JournalEntry.previewEntries
    }
}

// MARK: - PlaceSummary Previews

extension PlaceSummary {
    static let previewTokyo = PlaceSummary(
        id: UUID(),
        name: "Tokyo",
        displayName: "Tokyo, Japan",
        countryCode: "JP"
    )

    static let previewShibuya = PlaceSummary(
        id: UUID(),
        name: "Shibuya",
        displayName: "Shibuya, Tokyo, Japan",
        countryCode: "JP"
    )

    static let previewKyoto = PlaceSummary(
        id: UUID(),
        name: "Kyoto",
        displayName: "Kyoto, Japan",
        countryCode: "JP"
    )
}
#endif
