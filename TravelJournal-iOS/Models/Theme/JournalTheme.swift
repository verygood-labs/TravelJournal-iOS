//
//  JournalTheme.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 2/5/26.
//

import Foundation

// MARK: - Journal Theme

/// Complete theme configuration for a journal.
/// Matches the ThemeDto from the backend API.
struct JournalTheme: Codable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let slug: String
    let description: String?
    let isSystem: Bool
    let typography: ThemeTypography
    let colors: ThemeColors
    let blocks: ThemeBlocks
    let style: ThemeStyle
}

