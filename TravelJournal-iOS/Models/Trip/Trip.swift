//
//  Trip.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/25/26.
//

import Foundation

struct Trip: Codable, Identifiable {
    let id: UUID
    let author: Author
    let title: String
    let description: String?
    let coverImageUrl: String?
    let status: TripStatus
    let tripMode: TripMode?
    let startDate: Date?
    let endDate: Date?
    let createdAt: Date
    let updatedAt: Date?
    let stops: [TripStop]?
    let primaryDestination: String?
    let saveCount: Int
    let viewCount: Int
    let isSaved: Bool?
    let stopCount: Int
    let themeId: UUID?
    let themeSlug: String?
    let draftThemeSlug: String?

    enum CodingKeys: String, CodingKey {
        case id, author, title, description, coverImageUrl, status, tripMode
        case startDate, endDate, createdAt, updatedAt, stops
        case primaryDestination, saveCount, viewCount, isSaved, stopCount
        case themeId, themeSlug, draftThemeSlug
    }

    // MARK: - Decoder (handles DateOnly format for startDate/endDate)

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        author = try container.decode(Author.self, forKey: .author)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        coverImageUrl = try container.decodeIfPresent(String.self, forKey: .coverImageUrl)
        status = try container.decode(TripStatus.self, forKey: .status)
        tripMode = try container.decodeIfPresent(TripMode.self, forKey: .tripMode)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        stops = try container.decodeIfPresent([TripStop].self, forKey: .stops)
        primaryDestination = try container.decodeIfPresent(String.self, forKey: .primaryDestination)
        saveCount = try container.decodeIfPresent(Int.self, forKey: .saveCount) ?? 0
        viewCount = try container.decodeIfPresent(Int.self, forKey: .viewCount) ?? 0
        isSaved = try container.decodeIfPresent(Bool.self, forKey: .isSaved)
        stopCount = try container.decodeIfPresent(Int.self, forKey: .stopCount) ?? 0
        themeId = try container.decodeIfPresent(UUID.self, forKey: .themeId)
        themeSlug = try container.decodeIfPresent(String.self, forKey: .themeSlug)
        draftThemeSlug = try container.decodeIfPresent(String.self, forKey: .draftThemeSlug)

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
        author: Author,
        title: String,
        description: String? = nil,
        coverImageUrl: String? = nil,
        status: TripStatus,
        tripMode: TripMode? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        createdAt: Date,
        updatedAt: Date? = nil,
        stops: [TripStop]? = nil,
        primaryDestination: String? = nil,
        saveCount: Int = 0,
        viewCount: Int = 0,
        isSaved: Bool? = nil,
        stopCount: Int = 0,
        themeId: UUID? = nil,
        themeSlug: String? = nil,
        draftThemeSlug: String? = nil
    ) {
        self.id = id
        self.author = author
        self.title = title
        self.description = description
        self.coverImageUrl = coverImageUrl
        self.status = status
        self.tripMode = tripMode
        self.startDate = startDate
        self.endDate = endDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.stops = stops
        self.primaryDestination = primaryDestination
        self.saveCount = saveCount
        self.viewCount = viewCount
        self.isSaved = isSaved
        self.stopCount = stopCount
        self.themeId = themeId
        self.themeSlug = themeSlug
        self.draftThemeSlug = draftThemeSlug
    }
}

// MARK: - Computed Properties

extension Trip {
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
