//
//  Author.swift
//  TravelJournal-iOS
//
//  Created on 2/8/26.
//

import Foundation

/// Author information for trip and journal content
struct Author: Codable, Identifiable {
    let id: UUID
    let name: String
    let profilePictureUrl: String?
}
