//
//  JournalEntry.swift
//  TravelJournal-iOS
//
//  Created on 2/8/26.
//

import Foundation

// MARK: - Journal Entry

/// Published journal entry from the API.
/// Maps to `JournalEntryDto` on the backend.
struct JournalEntry: Codable, Identifiable {
    let id: UUID
    let order: Int
    let blockType: BlockType
    let saveCount: Int
    let isSaved: Bool?
    let moment: JournalMoment?
    let recommendation: JournalRecommendation?
    let photo: JournalPhoto?
    let tip: JournalTip?
    let divider: JournalDivider?
}

// MARK: - Moment

struct JournalMoment: Codable, Identifiable {
    let id: UUID
    let date: String?
    let title: String?
    let content: String?
    let imageUrl: String?
    let stampText: String?
    let stampColor: String?
    let place: PlaceSummary?
}

// MARK: - Recommendation

struct JournalRecommendation: Codable, Identifiable {
    let id: UUID
    let name: String
    let category: RecommendationCategory
    let rating: Rating?
    let priceLevel: Int?
    let note: String?
    let imageUrl: String?
    let place: PlaceSummary?
}

// MARK: - Photo

struct JournalPhoto: Codable, Identifiable {
    let id: UUID
    let imageUrl: String?
    let caption: String?
    let rotation: Int
}

// MARK: - Tip

struct JournalTip: Codable, Identifiable {
    let id: UUID
    let title: String?
    let content: String?
}

// MARK: - Divider

struct JournalDivider: Codable, Identifiable {
    let id: UUID
}

// MARK: - Place Summary

struct PlaceSummary: Codable {
    let id: UUID
    let name: String
    let displayName: String
    let countryCode: String
}
