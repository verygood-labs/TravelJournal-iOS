//
//  BlockType.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/26/26.
//

import Foundation

// MARK: - Block Type

/// Defines all supported block types in the journal editor.
/// Handles both PascalCase (journal API) and lowercase (draft API) values.
enum BlockType: String, CaseIterable {
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
        case .photo: return "photo.fill"
        case .tip: return "lightbulb.fill"
        case .divider: return "minus"
        }
    }

    var label: String {
        switch self {
        case .moment: return "Moment"
        case .recommendation: return "Rec"
        case .photo: return "Photo"
        case .tip: return "Tip"
        case .divider: return "Divider"
        }
    }

    /// Block types available in the editor toolbar
    static var toolbarItems: [BlockType] {
        [.moment, .photo, .recommendation, .tip, .divider]
    }
}

// MARK: - Codable

extension BlockType: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        // Handle both lowercase (draft API) and PascalCase (journal API)
        switch rawValue.lowercased() {
        case "moment": self = .moment
        case "recommendation": self = .recommendation
        case "photo": self = .photo
        case "tip": self = .tip
        case "divider": self = .divider
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Cannot initialize BlockType from invalid String value \(rawValue)"
                )
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        // Encode as lowercase for draft API compatibility
        try container.encode(rawValue)
    }
}
