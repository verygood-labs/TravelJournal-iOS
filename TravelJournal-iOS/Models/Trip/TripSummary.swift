//
//  TripSummary.swift
//  TravelJournal-iOS
//
//  Summary model for trip list views.
//  Used by GET /api/trips endpoint.
//

import Foundation

struct TripSummary: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String?
    let coverImageUrl: String?
    let status: TripStatus
    let tripMode: TripMode?
    let startDate: Date?
    let endDate: Date?
    let stopCount: Int
    let saveCount: Int
    let viewCount: Int
    let primaryDestination: String?
    let createdAt: Date
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, title, description, coverImageUrl, status, tripMode
        case startDate, endDate, stopCount, saveCount, viewCount
        case primaryDestination, createdAt, updatedAt
    }

    // MARK: - Decoder (handles DateOnly format for startDate/endDate)

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        coverImageUrl = try container.decodeIfPresent(String.self, forKey: .coverImageUrl)
        status = try container.decode(TripStatus.self, forKey: .status)
        tripMode = try container.decodeIfPresent(TripMode.self, forKey: .tripMode)
        stopCount = try container.decodeIfPresent(Int.self, forKey: .stopCount) ?? 0
        saveCount = try container.decodeIfPresent(Int.self, forKey: .saveCount) ?? 0
        viewCount = try container.decodeIfPresent(Int.self, forKey: .viewCount) ?? 0
        primaryDestination = try container.decodeIfPresent(String.self, forKey: .primaryDestination)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)

        // Handle DateOnly format (yyyy-MM-dd)
        let dateOnlyFormatter = DateFormatter()
        dateOnlyFormatter.dateFormat = "yyyy-MM-dd"
        dateOnlyFormatter.timeZone = TimeZone(identifier: "UTC")

        if let startDateString = try container.decodeIfPresent(String.self, forKey: .startDate) {
            startDate = dateOnlyFormatter.date(from: startDateString)
        } else {
            startDate = nil
        }

        if let endDateString = try container.decodeIfPresent(String.self, forKey: .endDate) {
            endDate = dateOnlyFormatter.date(from: endDateString)
        } else {
            endDate = nil
        }
    }

    // MARK: - Memberwise Initializer (for previews)

    init(
        id: UUID,
        title: String,
        description: String? = nil,
        coverImageUrl: String? = nil,
        status: TripStatus,
        tripMode: TripMode? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        stopCount: Int = 0,
        saveCount: Int = 0,
        viewCount: Int = 0,
        primaryDestination: String? = nil,
        createdAt: Date,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.coverImageUrl = coverImageUrl
        self.status = status
        self.tripMode = tripMode
        self.startDate = startDate
        self.endDate = endDate
        self.stopCount = stopCount
        self.saveCount = saveCount
        self.viewCount = viewCount
        self.primaryDestination = primaryDestination
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Computed Properties

extension TripSummary {
    var dateRange: String {
        guard let start = startDate, let end = endDate else {
            return "No dates set"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"

        let startString = formatter.string(from: start)
        let endString = formatter.string(from: end)

        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        let year = yearFormatter.string(from: end)

        return "\(startString) - \(endString), \(year)"
    }
}
