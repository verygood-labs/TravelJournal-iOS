import Combine
import Foundation
import MapKit

@MainActor
class MapViewModel: ObservableObject {
    // MARK: - Mode Selection

    @Published var selectedMode: DiscoveryMode = .journals

    // MARK: - Map Mode State

    @Published var journalLocations: [JournalLocation] = []
    @Published var selectedLocation: JournalLocation?
    @Published var journalsAtLocation: [JournalPreview] = []
    @Published var isLoadingLocations = false
    @Published var isLoadingJournals = false
    @Published var locationsError: String?

    // MARK: - Search Mode State

    @Published var searchQuery = ""
    @Published var travelers: [Traveler] = []
    @Published var selectedSortOption: TravelerSortOption = .mostTraveled
    @Published var isSearching = false
    @Published var searchError: String?
    @Published var travelersTotalCount = 0

    // MARK: - Dependencies

    private let discoveryService = DiscoveryService.shared
    private var searchTask: Task<Void, Never>?

    // MARK: - Computed Properties

    var isLoading: Bool {
        isLoadingLocations || isSearching
    }

    var error: String? {
        locationsError ?? searchError
    }

    var showBottomSheet: Bool {
        selectedLocation != nil
    }

    var resultsHeaderText: String {
        if travelers.isEmpty {
            return "NO TRAVELERS FOUND"
        }
        return "\(travelersTotalCount) TRAVELER\(travelersTotalCount == 1 ? "" : "S") FOUND"
    }

    // MARK: - Map Mode Methods

    func loadJournalLocations() async {
        isLoadingLocations = true
        locationsError = nil

        do {
            journalLocations = try await discoveryService.getJournalLocations()
            isLoadingLocations = false
        } catch {
            // Use mock data for development
            journalLocations = Self.mockLocations
            locationsError = nil // Don't show error when using mock data
            isLoadingLocations = false
        }
    }

    func selectLocation(_ location: JournalLocation) async {
        selectedLocation = location
        await loadJournalsAtLocation(location.id)
    }

    func dismissLocationSheet() {
        selectedLocation = nil
        journalsAtLocation = []
    }

    private func loadJournalsAtLocation(_ locationId: UUID) async {
        isLoadingJournals = true

        do {
            journalsAtLocation = try await discoveryService.getJournalsAtLocation(locationId: locationId)
            isLoadingJournals = false
        } catch {
            // Use mock data for development
            journalsAtLocation = Self.mockJournals
            isLoadingJournals = false
        }
    }

    // MARK: - Search Mode Methods

    func searchTravelers() {
        // Cancel previous search
        searchTask?.cancel()

        // Debounce search
        searchTask = Task {
            // Small delay for debouncing
            try? await Task.sleep(for: .milliseconds(300))

            guard !Task.isCancelled else { return }

            await performSearch()
        }
    }

    func updateSortOption(_ option: TravelerSortOption) async {
        selectedSortOption = option
        await performSearch()
    }

    func loadInitialTravelers() async {
        await performSearch()
    }

    private func performSearch() async {
        isSearching = true
        searchError = nil

        do {
            let response = try await discoveryService.searchTravelers(
                query: searchQuery,
                sortBy: selectedSortOption
            )
            travelers = response.travelers
            travelersTotalCount = response.totalCount
            isSearching = false
        } catch {
            // Use mock data for development
            travelers = Self.mockTravelers
            travelersTotalCount = travelers.count
            searchError = nil
            isSearching = false
        }
    }

    func clearSearch() {
        searchQuery = ""
        searchTravelers()
    }

    // MARK: - Mock Data for Development

    static let mockLocations: [JournalLocation] = [
        JournalLocation(
            id: UUID(),
            name: "Paris",
            countryName: "France",
            countryCode: "FR",
            coordinate: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
            journalCount: 12
        ),
        JournalLocation(
            id: UUID(),
            name: "Tokyo",
            countryName: "Japan",
            countryCode: "JP",
            coordinate: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503),
            journalCount: 8
        ),
        JournalLocation(
            id: UUID(),
            name: "New York",
            countryName: "United States",
            countryCode: "US",
            coordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
            journalCount: 15
        ),
        JournalLocation(
            id: UUID(),
            name: "Siargao",
            countryName: "Philippines",
            countryCode: "PH",
            coordinate: CLLocationCoordinate2D(latitude: 9.8482, longitude: 126.0458),
            journalCount: 5
        ),
        JournalLocation(
            id: UUID(),
            name: "Bali",
            countryName: "Indonesia",
            countryCode: "ID",
            coordinate: CLLocationCoordinate2D(latitude: -8.4095, longitude: 115.1889),
            journalCount: 23
        ),
    ]

    static let mockJournals: [JournalPreview] = [
        JournalPreview(
            id: UUID(),
            tripId: UUID(),
            title: "A Week in the City of Lights",
            coverImageUrl: nil,
            authorId: UUID(),
            authorName: "Sarah Chen",
            authorUsername: "sarahc",
            authorAvatarUrl: nil,
            viewCount: 1243,
            saveCount: 89
        ),
        JournalPreview(
            id: UUID(),
            tripId: UUID(),
            title: "Parisian Adventures",
            coverImageUrl: nil,
            authorId: UUID(),
            authorName: "John Doe",
            authorUsername: "johnd",
            authorAvatarUrl: nil,
            viewCount: 856,
            saveCount: 42
        ),
        JournalPreview(
            id: UUID(),
            tripId: UUID(),
            title: "My French Journey",
            coverImageUrl: nil,
            authorId: UUID(),
            authorName: "Maria Garcia",
            authorUsername: "mariag",
            authorAvatarUrl: nil,
            viewCount: 2105,
            saveCount: 156
        ),
    ]

    static let mockTravelers: [Traveler] = [
        Traveler(
            id: UUID(),
            name: "John Apale",
            username: "john",
            profilePictureUrl: nil,
            countriesVisited: 42,
            journalsCount: 15,
            lastActivityAt: Date()
        ),
        Traveler(
            id: UUID(),
            name: "Sarah Chen",
            username: "sarahc",
            profilePictureUrl: nil,
            countriesVisited: 38,
            journalsCount: 22,
            lastActivityAt: Date().addingTimeInterval(-86400)
        ),
        Traveler(
            id: UUID(),
            name: "Alex Rivera",
            username: "alexr",
            profilePictureUrl: nil,
            countriesVisited: 31,
            journalsCount: 8,
            lastActivityAt: Date().addingTimeInterval(-172800)
        ),
    ]
}
