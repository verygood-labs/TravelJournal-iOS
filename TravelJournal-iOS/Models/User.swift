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

struct NationalityInfo: Codable {
    let id: String
    let name: String
    let countryCode: String
}

struct UserProfile: Codable {
    let userId: UUID
    let email: String
    let userName: String
    let name: String
    let bio: String?
    let profilePictureUrl: String?
    let nationality: NationalityInfo?
    let preferredLanguage: String?
    let preferredCurrency: String?
    let createdAt: Date
    let updatedAt: Date?
}

struct UserStats: Codable {
    let totalTrips: Int
    let totalEntries: Int
    let countriesVisited: Int
    let totalPhotos: Int
    let totalDistance: Double?
}

// MARK: - UserProfile Extension

extension UserProfile {
    var memberSince: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: createdAt)
    }
}
