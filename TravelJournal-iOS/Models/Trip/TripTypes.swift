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
    let order: Int
    let arrivalDate: Date?
    let place: TripStopPlace
    
    enum CodingKeys: String, CodingKey {
        case id, order, arrivalDate, place
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        order = try container.decode(Int.self, forKey: .order)
        place = try container.decode(TripStopPlace.self, forKey: .place)
        
        // Handle DateOnly format (yyyy-MM-dd)
        if let arrivalDateString = try container.decodeIfPresent(String.self, forKey: .arrivalDate) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone(identifier: "UTC")
            arrivalDate = formatter.date(from: arrivalDateString)
        } else {
            arrivalDate = nil
        }
    }
    
    // Memberwise init for previews
    init(id: UUID, order: Int, arrivalDate: Date?, place: TripStopPlace) {
        self.id = id
        self.order = order
        self.arrivalDate = arrivalDate
        self.place = place
    }
}

struct TripStopPlace: Codable {
    let id: UUID
    let name: String
    let displayName: String
    let placeType: PlaceType
    let countryCode: String?
}
