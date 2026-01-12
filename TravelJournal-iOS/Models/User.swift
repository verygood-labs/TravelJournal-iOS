import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    let email: String
    let displayName: String
    let avatarUrl: String?
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case displayName
        case avatarUrl
        case createdAt
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