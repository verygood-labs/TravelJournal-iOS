import Foundation

class ProfileService {
    static let shared = ProfileService()
    private let api = APIService.shared

    private init() {}

    func getProfile() async throws -> UserProfile {
        return try await api.request(endpoint: "/profile")
    }

    func updateProfile(
        name: String? = nil,
        bio: String? = nil,
        profilePictureUrl: String? = nil,
        nationalityId: String? = nil,
        preferredLanguage: String? = nil,
        preferredCurrency: String? = nil
    ) async throws -> UserProfile {
        struct UpdateProfileRequest: Codable {
            let name: String?
            let bio: String?
            let profilePictureUrl: String?
            let nationalityId: String?
            let preferredLanguage: String?
            let preferredCurrency: String?
        }

        let request = UpdateProfileRequest(
            name: name,
            bio: bio,
            profilePictureUrl: profilePictureUrl,
            nationalityId: nationalityId,
            preferredLanguage: preferredLanguage,
            preferredCurrency: preferredCurrency
        )

        return try await api.request(
            endpoint: "/profile",
            method: "PUT",
            body: request
        )
    }

    func getStats() async throws -> UserStats {
        return try await api.request(endpoint: "/profile/stats")
    }

    func getCountryStamps() async throws -> CountryStampsResponse {
        return try await api.request(endpoint: "/profile/country-stamps")
    }
}
