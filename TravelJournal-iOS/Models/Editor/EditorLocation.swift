//
//  EditorLocation.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/26/26.
//

import Foundation

// MARK: - Editor Location

/// Location data for blocks before publish resolves to a PlaceId.
/// Maps to `DraftLocationDto` on the backend.
struct EditorLocation: Codable, Equatable {
    let osmType: String
    let osmId: Int64
    let name: String
    let displayName: String
    let latitude: Decimal
    let longitude: Decimal

    /// Returns a shortened location display with just city and state.
    /// Extracts from displayName format: "Place, City, State, Country" → "City, State"
    var cityAndState: String {
        let components = displayName.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        // Format is typically: Place, City, State, Country
        // We want City, State (index 1 and 2 if we have 4+ components)
        if components.count >= 4 {
            return "\(components[1]), \(components[2])"
        } else if components.count >= 2 {
            // Fallback: return last two components
            return "\(components[components.count - 2]), \(components[components.count - 1])"
        }
        return displayName
    }
}
