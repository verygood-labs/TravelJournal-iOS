import Foundation

struct Place: Codable, Identifiable {
    let id: String
    let name: String
    let displayName: String
    let latitude: Double
    let longitude: Double
    let type: String?
    let country: String?
    let city: String?
    let address: String?
}

struct PlaceSearchResult: Codable {
    let places: [Place]
}

struct PlaceStats: Codable {
    let totalPlaces: Int
    let countries: [String]
    let cities: [String]
}
