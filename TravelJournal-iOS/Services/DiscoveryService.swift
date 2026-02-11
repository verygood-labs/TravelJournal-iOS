//
//  DiscoveryService.swift
//  TravelJournal-iOS
//
//  Service for the Discover feature (journal locations & traveler search)
//

import Foundation

final class DiscoveryService {
    static let shared = DiscoveryService()
    private let api = APIService.shared

    private init() {}

    // MARK: - Journal Discovery

    /// Get all locations that have public journals
    func getJournalLocations() async throws -> [JournalLocation] {
        let response: JournalLocationsResponse = try await api.request(
            endpoint: "/discover/locations"
        )
        return response.locations.map { $0.toModel() }
    }

    /// Get public journals at a specific location
    func getJournalsAtLocation(locationId: UUID) async throws -> [JournalPreview] {
        let response: JournalsAtLocationResponse = try await api.request(
            endpoint: "/discover/locations/\(locationId)/journals"
        )
        return response.journals
    }

    // MARK: - Traveler Search

    /// Search for travelers by query
    func searchTravelers(
        query: String,
        sortBy: TravelerSortOption = .mostTraveled,
        page: Int = 1,
        pageSize: Int = 20
    ) async throws -> TravelerSearchResponse {
        // Build query string
        var components = URLComponents()
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "sortBy", value: sortBy.apiValue),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]

        if !query.isEmpty {
            queryItems.append(URLQueryItem(name: "q", value: query))
        }

        components.queryItems = queryItems
        let queryString = components.percentEncodedQuery ?? ""

        return try await api.request(
            endpoint: "/discover/travelers?\(queryString)"
        )
    }

    /// Get top travelers (for initial view without search query)
    func getTopTravelers(
        sortBy: TravelerSortOption = .mostTraveled,
        limit: Int = 20
    ) async throws -> [Traveler] {
        let response = try await searchTravelers(
            query: "",
            sortBy: sortBy,
            page: 1,
            pageSize: limit
        )
        return response.travelers
    }
}
