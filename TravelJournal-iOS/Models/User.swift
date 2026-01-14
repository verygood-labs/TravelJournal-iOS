import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    let email: String
    let name: String
    let userName: String
    let profilePictureUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case userName
        case profilePictureUrl
    }
}

struct UserProfile: Codable {
    let id: UUID
    let email: String
    let displayName: String
    let avatarUrl: String?
    let bio: String?
}

struct UserStats: Codable {
    let totalTrips: Int
    let totalCountries: Int
    let totalCities: Int
    let totalDistance: Double?
}