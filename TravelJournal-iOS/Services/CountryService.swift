import Foundation

class CountryService {
    static let shared = CountryService()
    private let placeService = PlaceService.shared
    
    private init() {}
    
    // MARK: - Search Countries
    
    /// Search for countries by name
    /// Returns LocationSearchResult[] - call getOrCreate after selection to get UUID
    func searchCountries(query: String) async throws -> [LocationSearchResult] {
        return try await placeService.searchCountries(query: query)
    }
    
    /// Get or create a country from a search result
    /// Returns PlaceDTO with UUID for registration
    func getOrCreate(from searchResult: LocationSearchResult) async throws -> PlaceDTO {
        return try await placeService.getOrCreate(from: searchResult)
    }
}
