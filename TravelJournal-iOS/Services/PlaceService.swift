import Foundation

class PlaceService {
    static let shared = PlaceService()
    private let api = APIService.shared
    
    private init() {}
    
    // MARK: - Search (External - Nominatim)
    
    /// Search for places using OpenStreetMap Nominatim
    /// Results are NOT saved to the database until you call getOrCreate
    func search(
        query: String,
        placeType: PlaceType? = nil,
        limit: Int = 10,
        language: String = "en"
    ) async throws -> [LocationSearchResult] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        
        var endpoint = "/places/search?query=\(encodedQuery)&limit=\(limit)&language=\(language)"
        if let placeType = placeType {
            endpoint += "&placeType=\(placeType.rawValue)"
        }
        
        return try await api.request(endpoint: endpoint, authenticated: false)
    }
    
    /// Search for countries only
    func searchCountries(query: String, limit: Int = 10) async throws -> [LocationSearchResult] {
        return try await search(query: query, placeType: .country, limit: limit)
    }
    
    /// Search for cities only
    func searchCities(query: String, limit: Int = 10) async throws -> [LocationSearchResult] {
        return try await search(query: query, placeType: .city, limit: limit)
    }
    
    // MARK: - Get or Create
    
    /// Get an existing place or create it from OSM data
    /// Use this after search to save a place and get its UUID
    func getOrCreate(osmType: String, osmId: Int64, language: String = "en") async throws -> PlaceDTO {
        let request = GetOrCreatePlaceRequest(osmType: osmType, osmId: osmId, language: language)
        return try await api.request(
            endpoint: "/places/get-or-create",
            method: "POST",
            body: request,
            authenticated: false
        )
    }
    
    /// Convenience method to get or create from a search result
    func getOrCreate(from searchResult: LocationSearchResult) async throws -> PlaceDTO {
        return try await getOrCreate(osmType: searchResult.osmType, osmId: searchResult.osmId)
    }
    
    // MARK: - Get Place
    
    func getPlace(id: String) async throws -> PlaceDTO {
        return try await api.request(endpoint: "/places/\(id)")
    }
    
    func getPlaceByOSM(osmType: String, osmId: Int64) async throws -> PlaceDTO {
        return try await api.request(endpoint: "/places/osm/\(osmType)/\(osmId)")
    }
    
    // MARK: - Countries
    
    func getAllCountries() async throws -> [PlaceSummaryDTO] {
        return try await api.request(endpoint: "/places/countries")
    }
    
    func getCountryByCode(_ countryCode: String) async throws -> PlaceDTO {
        return try await api.request(endpoint: "/places/countries/\(countryCode)")
    }
    
    // MARK: - Hierarchy
    
    func getCountryForPlace(id: String) async throws -> PlaceDTO {
        return try await api.request(endpoint: "/places/\(id)/country")
    }
    
    func getAncestors(id: String) async throws -> [PlaceDTO] {
        return try await api.request(endpoint: "/places/\(id)/ancestors")
    }
    
    func getChildren(id: String, childType: PlaceType? = nil) async throws -> [PlaceDTO] {
        var endpoint = "/places/\(id)/children"
        if let childType = childType {
            endpoint += "?childType=\(childType.rawValue)"
        }
        return try await api.request(endpoint: endpoint)
    }
}