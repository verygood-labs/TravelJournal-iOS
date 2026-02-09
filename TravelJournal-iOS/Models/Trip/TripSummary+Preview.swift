//
//  TripSummary+Preview.swift
//  TravelJournal-iOS
//
//  Preview helpers for TripSummary.
//

import Foundation

#if DEBUG
extension TripSummary {
    /// Sample public trip summary for previews
    static func preview(
        id: UUID = UUID(),
        title: String = "Paris, France",
        description: String? = "An amazing week exploring the city of lights.",
        coverImageUrl: String? = nil,
        status: TripStatus = .public,
        tripMode: TripMode? = .live,
        startDate: Date? = Date().addingTimeInterval(-86400 * 30),
        endDate: Date? = Date().addingTimeInterval(-86400 * 23),
        stopCount: Int = 3,
        saveCount: Int = 12,
        viewCount: Int = 156,
        primaryDestination: String? = "Paris, France",
        createdAt: Date = Date().addingTimeInterval(-86400 * 30),
        updatedAt: Date? = Date().addingTimeInterval(-86400 * 2)
    ) -> TripSummary {
        TripSummary(
            id: id,
            title: title,
            description: description,
            coverImageUrl: coverImageUrl,
            status: status,
            tripMode: tripMode,
            startDate: startDate,
            endDate: endDate,
            stopCount: stopCount,
            saveCount: saveCount,
            viewCount: viewCount,
            primaryDestination: primaryDestination,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    /// Draft trip summary for previews
    static var previewDraft: TripSummary {
        .preview(
            title: "Tokyo, Japan",
            description: nil,
            status: .draft,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 7),
            stopCount: 0,
            saveCount: 0,
            viewCount: 0,
            primaryDestination: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    /// Private trip with long title for previews
    static var previewPrivateLongTitle: TripSummary {
        .preview(
            title: "My Amazing European Backpacking Adventure Across Multiple Countries",
            description: "A journey through France, Italy, Spain, and Portugal exploring historic cities and beautiful coastlines.",
            status: .private,
            stopCount: 8,
            saveCount: 5,
            viewCount: 42,
            primaryDestination: "Barcelona, Spain"
        )
    }

    /// Unlisted trip for previews
    static var previewUnlisted: TripSummary {
        .preview(
            title: "Weekend in Barcelona",
            description: "Quick getaway to enjoy some sun and tapas",
            status: .unlisted,
            stopCount: 2,
            saveCount: 3,
            viewCount: 28,
            primaryDestination: "Barcelona, Spain"
        )
    }

    /// Trip with cover image for previews
    static var previewWithCover: TripSummary {
        .preview(
            title: "Santorini Escape",
            description: "Blue domes and stunning sunsets",
            coverImageUrl: "https://example.com/santorini.jpg",
            stopCount: 4,
            saveCount: 45,
            viewCount: 892,
            primaryDestination: "Santorini, Greece"
        )
    }
}
#endif
