//
//  EditorResponse.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/26/26.
//

import Foundation

// MARK: - Editor Response

/// API response wrapper for GET /draft endpoint.
/// Maps to `DraftResponseDto` on the backend.
struct EditorResponse: Codable {
    let tripId: UUID
    let lastUpdatedAt: Date?
    let blocks: [EditorBlock]
    
    // MARK: - Convenience
    
    var content: EditorContent {
        EditorContent(blocks: blocks)
    }
}
