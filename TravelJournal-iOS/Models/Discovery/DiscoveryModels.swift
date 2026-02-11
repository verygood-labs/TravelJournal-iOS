//
//  DiscoveryModels.swift
//  TravelJournal-iOS
//
//  Models for the Discover feature (Map + Travelers)
//

import CoreLocation
import Foundation

// MARK: - Discovery Mode

/// The two modes available in the Discover tab
enum DiscoveryMode: String, CaseIterable {
    case journals = "Journals"
    case travelers = "Travelers"
}

// MARK: - Journal Location

/// A location on the map with public journals
struct JournalLocation: Identifiable, Equatable {
    let id: UUID
    let name: String
    let countryName: String
    let countryCode: String
    let coordinate: CLLocationCoordinate2D
    let journalCount: Int

    var displayName: String {
        "\(name.uppercased()), \(countryName.uppercased())"
    }

    var countSubtitle: String {
        "\(journalCount) Public Journal\(journalCount == 1 ? "" : "s")"
    }

    static func == (lhs: JournalLocation, rhs: JournalLocation) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Journal Preview

/// Preview card data for a journal at a location
struct JournalPreview: Identifiable, Codable {
    let id: UUID
    let tripId: UUID
    let title: String
    let coverImageUrl: String?
    let authorId: UUID
    let authorName: String
    let authorUsername: String
    let authorAvatarUrl: String?

    var displayUsername: String {
        "@\(authorUsername)"
    }
}

// MARK: - Traveler

/// A traveler in the search results
struct Traveler: Identifiable, Codable {
    let id: UUID
    let name: String
    let username: String
    let profilePictureUrl: String?
    let countriesVisited: Int
    let journalsCount: Int
    let lastActivityAt: Date?

    var displayUsername: String {
        "@\(username)"
    }

    var statsText: String {
        "🌍 \(countriesVisited) countries  📝 \(journalsCount) journals"
    }
}

// MARK: - Traveler Sort Option

/// Sort options for traveler search
enum TravelerSortOption: String, CaseIterable {
    case mostTraveled = "MOST TRAVELED"
    case recentActivity = "RECENT ACTIVITY"

    var apiValue: String {
        switch self {
        case .mostTraveled: return "countries_desc"
        case .recentActivity: return "activity_desc"
        }
    }
}

// MARK: - API Response Models

/// Response from the journal locations endpoint
struct JournalLocationsResponse: Codable {
    let locations: [JournalLocationDto]
}

struct JournalLocationDto: Codable {
    let id: UUID
    let name: String
    let countryName: String
    let countryCode: String
    let latitude: Double
    let longitude: Double
    let journalCount: Int

    func toModel() -> JournalLocation {
        JournalLocation(
            id: id,
            name: name,
            countryName: countryName,
            countryCode: countryCode,
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            journalCount: journalCount
        )
    }
}

/// Response from journals at location endpoint
struct JournalsAtLocationResponse: Codable {
    let journals: [JournalPreview]
}

/// Response from traveler search endpoint  
struct TravelerSearchResponse: Codable {
    let travelers: [Traveler]
    let totalCount: Int
}
