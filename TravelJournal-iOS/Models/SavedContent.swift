//
//  SavedContent.swift
//  TravelJournal-iOS
//
//  Created on 2/8/26.
//

import Foundation

// MARK: - Toggle Save Response

/// Response from toggle save endpoints.
/// Maps to `ToggleSaveResponse` on the backend.
struct ToggleSaveResponse: Codable {
    let isSaved: Bool
    let newSaveCount: Int
}

// MARK: - Save Status

/// Response from save status check endpoints.
/// Maps to `SaveStatusDto` on the backend.
struct SaveStatus: Codable {
    let isSaved: Bool
    let savedAt: Date?
}
