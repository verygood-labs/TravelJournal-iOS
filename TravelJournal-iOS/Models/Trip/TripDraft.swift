//
//  TripDraft.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/26/26.
//

import Foundation

// MARK: - Draft Models

struct TripDraft: Codable {
    let tripId: UUID
    let blocks: [JournalBlock]
    let lastUpdatedAt: Date?
}

struct JournalBlock: Codable, Identifiable {
    let id: UUID
    let type: BlockType
    let content: String?
    let imageUrl: String?
    let order: Int
    let createdAt: Date
}

struct CreateBlockRequest: Codable {
    let type: BlockType
    let content: String?
    let imageUrl: String?
}
