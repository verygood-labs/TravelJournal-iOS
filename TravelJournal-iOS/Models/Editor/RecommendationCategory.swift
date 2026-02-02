//
//  RecommendationCategory.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/26/26.
//

import Foundation

// MARK: - Recommendation Category

/// Category types for recommendation blocks.
/// Raw values match backend string encoding.
enum RecommendationCategory: String, Codable, CaseIterable {
    case stay = "Stay"
    case eat = "Eat"
    case `do` = "Do"
    case shop = "Shop"

    // MARK: - Display Properties

    var displayName: String {
        switch self {
        case .stay: return "Stay"
        case .eat: return "Eat"
        case .do: return "Do"
        case .shop: return "Shop"
        }
    }

    var icon: String {
        switch self {
        case .stay: return "bed.double.fill"
        case .eat: return "fork.knife"
        case .do: return "figure.walk"
        case .shop: return "bag.fill"
        }
    }
}
