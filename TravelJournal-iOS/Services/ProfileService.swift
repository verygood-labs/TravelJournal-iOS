import Foundation

class ProfileService {
    static let shared = ProfileService()
    private let api = APIService.shared
    
    private init() {}
    
    func getProfile() async throws -> UserProfile {
        return try await api.request(endpoint: "/profile")
    }
    
    func updateProfile(displayName: String? = nil, bio: String? = nil) async throws -> UserProfile {
        struct UpdateProfileRequest: Codable {
            let displayName: String?
            let bio: String?
        }
        
        let request = UpdateProfileRequest(displayName: displayName, bio: bio)
        
        return try await api.request(
            endpoint: "/profile",
            method: "PUT",
            body: request
        )
    }
    
    func getStats() async throws -> UserStats {
        return try await api.request(endpoint: "/profile/stats")
    }
}