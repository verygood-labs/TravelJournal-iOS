//
//  Trip+Preview.swift
//  TravelJournal-iOS
//
//  Created on 2/8/26.
//

import Foundation

#if DEBUG
extension Author {
    static let preview = Author(
        id: UUID(),
        name: "John Doe",
        profilePictureUrl: nil
    )
}

extension Trip {
    /// Sample public trip for previews
    static func preview(
        id: UUID = UUID(),
        author: Author = .preview,
        title: String = "Paris, France",
        description: String? = "An amazing week exploring the city of lights.",
        coverImageUrl: String? = nil,
        status: TripStatus = .public,
        tripMode: TripMode? = .live,
        startDate: Date? = Date().addingTimeInterval(-86400 * 30),
        endDate: Date? = Date().addingTimeInterval(-86400 * 23),
        createdAt: Date = Date().addingTimeInterval(-86400 * 30),
        updatedAt: Date? = Date().addingTimeInterval(-86400 * 2),
        stops: [TripStop]? = nil,
        primaryDestination: String? = nil,
        saveCount: Int = 0,
        viewCount: Int = 0,
        isSaved: Bool? = nil,
        stopCount: Int = 0,
        themeId: UUID? = nil,
        themeSlug: String? = nil,
        draftThemeSlug: String? = nil
    ) -> Trip {
        Trip(
            id: id,
            author: author,
            title: title,
            description: description,
            coverImageUrl: coverImageUrl,
            status: status,
            tripMode: tripMode,
            startDate: startDate,
            endDate: endDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            stops: stops,
            primaryDestination: primaryDestination,
            saveCount: saveCount,
            viewCount: viewCount,
            isSaved: isSaved,
            stopCount: stopCount,
            themeId: themeId,
            themeSlug: themeSlug,
            draftThemeSlug: draftThemeSlug
        )
    }
    
    /// Draft trip for previews
    static var previewDraft: Trip {
        .preview(
            title: "Tokyo, Japan",
            description: nil,
            status: .draft,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 7),
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    /// Private trip with long title for previews
    static var previewPrivateLongTitle: Trip {
        .preview(
            title: "Road Trip Across the United States of America",
            description: "From New York to Los Angeles, experiencing the diverse landscapes and cultures along the way.",
            status: .private,
            startDate: Date().addingTimeInterval(-86400 * 90),
            endDate: Date().addingTimeInterval(-86400 * 60),
            createdAt: Date().addingTimeInterval(-86400 * 90),
            updatedAt: Date().addingTimeInterval(-86400 * 30)
        )
    }
    
    /// Trip with stops for editor previews
    static var previewWithStops: Trip {
        .preview(
            title: "Two Weeks in the Philippines",
            description: "Island hopping adventure",
            status: .draft,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 14),
            createdAt: Date(),
            updatedAt: Date(),
            stops: [
                TripStop(id: UUID(), order: 0, arrivalDate: nil, place: TripStopPlace(id: UUID(), name: "Manila", displayName: "Manila, Philippines", placeType: .city, countryCode: "PH", latitude: 14.5995, longitude: 120.9842)),
                TripStop(id: UUID(), order: 1, arrivalDate: nil, place: TripStopPlace(id: UUID(), name: "Palawan", displayName: "Palawan, Philippines", placeType: .city, countryCode: "PH", latitude: 9.8349, longitude: 118.7384)),
                TripStop(id: UUID(), order: 2, arrivalDate: nil, place: TripStopPlace(id: UUID(), name: "Cebu", displayName: "Cebu, Philippines", placeType: .city, countryCode: "PH", latitude: 10.3157, longitude: 123.8854)),
                TripStop(id: UUID(), order: 3, arrivalDate: nil, place: TripStopPlace(id: UUID(), name: "Siargao", displayName: "Siargao, Philippines", placeType: .city, countryCode: "PH", latitude: 9.8482, longitude: 126.0458)),
            ]
        )
    }
}
#endif
