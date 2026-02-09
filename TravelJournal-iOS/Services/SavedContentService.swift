//
//  SavedContentService.swift
//  TravelJournal-iOS
//
//  Created on 2/8/26.
//

import Foundation

class SavedContentService {
    static let shared = SavedContentService()
    private let api = APIService.shared

    private init() {}

    // MARK: - Saved Trips

    /// Toggle save status for a trip (pin button)
    func toggleSaveTrip(tripId: UUID) async throws -> ToggleSaveResponse {
        return try await api.request(
            endpoint: "/saved-trips/\(tripId)/toggle",
            method: "POST"
        )
    }

    /// Get save status for a trip
    func getTripSaveStatus(tripId: UUID) async throws -> SaveStatus {
        return try await api.request(endpoint: "/saved-trips/\(tripId)/status")
    }

    // MARK: - Saved Items (Journal Entries)

    /// Toggle save status for a journal entry (heart button)
    func toggleSaveItem(entryId: UUID) async throws -> ToggleSaveResponse {
        return try await api.request(
            endpoint: "/saved-items/\(entryId)/toggle",
            method: "POST"
        )
    }

    /// Get save status for a journal entry
    func getItemSaveStatus(entryId: UUID) async throws -> SaveStatus {
        return try await api.request(endpoint: "/saved-items/\(entryId)/status")
    }
}
