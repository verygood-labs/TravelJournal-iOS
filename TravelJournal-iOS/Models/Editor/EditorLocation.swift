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
}
