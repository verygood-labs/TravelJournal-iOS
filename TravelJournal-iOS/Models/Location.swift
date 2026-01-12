import Foundation

// MARK: - Location Search Result
/// Search result from Nominatim (external, not yet saved to DB)
struct LocationSearchResult: Codable, Identifiable, Equatable {
    let displayName: String
    let name: String
    let osmType: String
    let osmId: Int64
    let latitude: Double
    let longitude: Double
    let placeType: Int
    let countryCode: String?
    let boundingBox: BoundingBox?
    
    // Use osmType + osmId as the unique identifier
    var id: String { "\(osmType)/\(osmId)" }
    
    // Display name with flag emoji based on country code
    var displayNameWithFlag: String {
        if let code = countryCode {
            return "\(flag(for: code)) \(name)"
        }
        return name
    }
    
    // Convert country code to flag emoji
    private func flag(for countryCode: String) -> String {
        let base: UInt32 = 127397
        var flag = ""
        for scalar in countryCode.uppercased().unicodeScalars {
            if let unicode = UnicodeScalar(base + scalar.value) {
                flag.append(String(unicode))
            }
        }
        return flag
    }
}

// MARK: - Bounding Box
struct BoundingBox: Codable, Equatable {
    let minLatitude: Double
    let maxLatitude: Double
    let minLongitude: Double
    let maxLongitude: Double
}

// MARK: - Place Types
enum PlaceType: Int, Codable {
    case country = 0
    case region = 1
    case city = 2
    case district = 3
    case venue = 4
}

// MARK: - Get or Create Request
struct GetOrCreatePlaceRequest: Codable {
    let osmType: String
    let osmId: Int64
    let language: String?
    
    init(osmType: String, osmId: Int64, language: String = "en") {
        self.osmType = osmType
        self.osmId = osmId
        self.language = language
    }
}

// MARK: - Place DTO (saved in DB)
struct PlaceDTO: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let displayName: String
    let placeType: Int
    let countryCode: String?
    let latitude: Double
    let longitude: Double
    let osmType: String
    let osmId: Int64
    let parentId: String?
    let createdAt: Date?
    
    // Display name with flag emoji
    var displayNameWithFlag: String {
        if let code = countryCode {
            return "\(flag(for: code)) \(name)"
        }
        return name
    }
    
    private func flag(for countryCode: String) -> String {
        let base: UInt32 = 127397
        var flag = ""
        for scalar in countryCode.uppercased().unicodeScalars {
            if let unicode = UnicodeScalar(base + scalar.value) {
                flag.append(String(unicode))
            }
        }
        return flag
    }
}

// MARK: - Place Summary DTO
struct PlaceSummaryDTO: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let countryCode: String?
}

