import Foundation

struct Trip: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String?
    let coverImageUrl: String?
    let status: TripStatus
    let startDate: Date?
    let endDate: Date?
    let createdAt: Date
    let updatedAt: Date
    let stops: [TripStop]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case coverImageUrl
        case status
        case startDate
        case endDate
        case createdAt
        case updatedAt
        case stops
    }
}

enum TripStatus: String, Codable {
    case draft = "Draft"
    case `private` = "Private"
    case `public` = "Public"
}

struct TripStop: Codable, Identifiable {
    let id: UUID
    let placeId: String?
    let placeName: String
    let latitude: Double
    let longitude: Double
    let order: Int
    let arrivedAt: Date?
    let departedAt: Date?
}

struct CreateTripRequest: Codable {
    let title: String
    let description: String?
    let startDate: Date?
    let endDate: Date?
}

struct UpdateTripRequest: Codable {
    let title: String?
    let description: String?
    let startDate: Date?
    let endDate: Date?
}
// MARK: - Trip Extension
extension Trip {
    var dateRange: String {
        guard let start = startDate, let end = endDate else {
            return "No dates set"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        let startString = formatter.string(from: start)
        let endString = formatter.string(from: end)
        
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        let year = yearFormatter.string(from: end)
        
        return "\(startString) - \(endString), \(year)"
    }
}
