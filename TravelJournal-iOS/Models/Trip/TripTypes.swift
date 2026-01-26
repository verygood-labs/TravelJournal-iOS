//
//  TripStatus.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/25/26.
//


import Foundation
import SwiftUI

// MARK: - Trip Status

enum TripStatus: String, Codable {
    case draft = "Draft"
    case `private` = "Private"
    case unlisted = "Unlisted"
    case `public` = "Public"
    case archived = "Archived"
}

extension TripStatus {
    var color: Color {
        switch self {
        case .draft:
            return .orange
        case .private:
            return .blue
        case .unlisted:
            return .yellow
        case .public:
            return .green
        case .archived:
            return .red
        }
    }
}

// MARK: - Trip Mode

enum TripMode: String, Codable {
    case past = "Past"
    case live = "Live"
}

// MARK: - Trip Stop

struct TripStop: Codable, Identifiable {
    let id: UUID
    let placeId: String?
    let placeName: String
    let latitude: Double
    let longitude: Double
    let order: Int
    let arrivedAt: Date?
    let departedAt: Date?
}