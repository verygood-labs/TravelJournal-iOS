//
//  ThemeEnums.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 2/5/26.
//

import Foundation

// MARK: - Stamp Style

/// Visual style for moment block stamps.
enum StampStyle: String, Codable, CaseIterable {
    case rubber      // Classic passport stamp (default)
    case minimal     // Simple text badge
    case vintage     // Aged/distressed look
}

// MARK: - Divider Line Style

/// Line style for divider blocks.
enum DividerLineStyle: String, Codable, CaseIterable {
    case solid
    case dashed
    case dotted
}

// MARK: - Header Style

/// Visual style for journal headers.
enum HeaderStyle: String, Codable, CaseIterable {
    case standard    // Simple header
    case passport    // With country illustration
    case minimal     // Just title
}
