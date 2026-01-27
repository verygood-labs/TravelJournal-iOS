//
//  BlockType.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/26/26.
//


import Foundation

// MARK: - Block Type

/// Defines all supported block types in the journal editor.
/// Values are lowercase to match backend JSON serialization.
enum BlockType: String, Codable, CaseIterable {
    case moment
    case recommendation
    case photo
    case tip
    case divider
    
    // MARK: - Display Properties
    
    var icon: String {
        switch self {
        case .moment: return "sparkles"
        case .recommendation: return "star.fill"
        case .photo: return "camera.fill"
        case .tip: return "lightbulb.fill"
        case .divider: return "minus"
        }
    }
}
