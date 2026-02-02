//
//  Rating.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/26/26.
//

//
//  Rating.swift
//  TravelJournal-iOS
//

import SwiftUI

// MARK: - Rating

/// Letter-grade rating system for recommendation blocks.
/// Raw values match backend integer encoding.
enum Rating: Int, Codable, CaseIterable {
    case s = 0
    case a = 1
    case b = 2
    case c = 3
    case d = 4
    case f = 5

    // MARK: - Display Properties

    var displayName: String {
        switch self {
        case .s: return "S"
        case .a: return "A"
        case .b: return "B"
        case .c: return "C"
        case .d: return "D"
        case .f: return "F"
        }
    }

    var description: String {
        switch self {
        case .s: return "Exceptional"
        case .a: return "Excellent"
        case .b: return "Good"
        case .c: return "Average"
        case .d: return "Below Average"
        case .f: return "Poor"
        }
    }

    var color: Color {
        switch self {
        case .s: return Color(hex: "FFD700") // Gold
        case .a: return Color(hex: "4CAF50") // Green
        case .b: return Color(hex: "8BC34A") // Light Green
        case .c: return Color(hex: "FFC107") // Amber
        case .d: return Color(hex: "FF9800") // Orange
        case .f: return Color(hex: "F44336") // Red
        }
    }
}
