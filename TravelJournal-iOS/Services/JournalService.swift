//
//  JournalService.swift
//  TravelJournal-iOS
//
//  Created on 2/8/26.
//

import Foundation

class JournalService {
    static let shared = JournalService()
    private let api = APIService.shared

    private init() {}

    /// Get published journal entries for a trip
    /// Works for public/unlisted trips without auth, or private trips for owner
    func getJournalEntries(tripId: UUID) async throws -> [JournalEntry] {
        return try await api.request(endpoint: "/trips/\(tripId)/journal")
    }
}
