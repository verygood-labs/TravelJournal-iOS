import Foundation

class PlaceService {
    static let shared = PlaceService()
    private let api = APIService.shared
    
    private init() {}
    
    func search(query: String) async throws -> [Place] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        return try await api.request(endpoint: "/places/search?query=\(encodedQuery)")
    }
    
    func getPlace(id: String) async throws -> Place {
        return try await api.request(endpoint: "/places/\(id)")
    }
    
    func reverseGeocode(latitude: Double, longitude: Double) async throws -> Place {
        return try await api.request(
            endpoint: "/places/reverse?latitude=\(latitude)&longitude=\(longitude)"
        )
    }
    
    func getStats() async throws -> PlaceStats {
        return try await api.request(endpoint: "/places/stats")
    }
}