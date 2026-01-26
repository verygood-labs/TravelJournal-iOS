import Foundation

class TripService {
    static let shared = TripService()
    private let api = APIService.shared
    
    private init() {}
    
    func getTrips(page: Int = 1, pageSize: Int = 20, status: TripStatus? = nil) async throws -> PaginatedResponse<Trip> {
        var endpoint = "/trips?page=\(page)&pageSize=\(pageSize)"
        if let status = status {
            endpoint += "&status=\(status.rawValue)"
        }
        return try await api.request(endpoint: endpoint)
    }
    
    func getTrip(id: UUID) async throws -> Trip {
        return try await api.request(endpoint: "/trips/\(id)")
    }
    
    func createTrip(
        title: String,
        description: String? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        initialStops: [CreateTripStopRequest]? = nil
    ) async throws -> Trip {
        let request = CreateTripRequest(
            title: title,
            description: description,
            startDate: startDate,
            endDate: endDate,
            initialStops: initialStops
        )
        
        return try await api.request(
            endpoint: "/trips",
            method: "POST",
            body: request
        )
    }
    
    func updateTrip(id: UUID, title: String? = nil, description: String? = nil, startDate: Date? = nil, endDate: Date? = nil) async throws -> Trip {
        let request = UpdateTripRequest(
            title: title,
            description: description,
            startDate: startDate,
            endDate: endDate
        )
        
        return try await api.request(
            endpoint: "/trips/\(id)",
            method: "PUT",
            body: request
        )
    }
    
    func deleteTrip(id: UUID) async throws {
        try await api.requestVoid(
            endpoint: "/trips/\(id)",
            method: "DELETE"
        )
    }
    
    func updateTripStatus(id: UUID, status: TripStatus) async throws -> Trip {
        struct StatusRequest: Codable {
            let status: String
        }
        
        return try await api.request(
            endpoint: "/trips/\(id)/status",
            method: "PUT",
            body: StatusRequest(status: status.rawValue)
        )
    }
    
    // MARK: - Trip Stops
    
    func addStop(
        tripId: UUID,
        placeName: String,
        latitude: Double,
        longitude: Double,
        placeId: String? = nil
    ) async throws -> TripStop {
        struct AddStopRequest: Codable {
            let placeName: String
            let latitude: Double
            let longitude: Double
            let placeId: String?
        }
        
        let request = AddStopRequest(
            placeName: placeName,
            latitude: latitude,
            longitude: longitude,
            placeId: placeId
        )
        
        return try await api.request(
            endpoint: "/trips/\(tripId)/stops",
            method: "POST",
            body: request
        )
    }
    
    func removeStop(tripId: UUID, stopId: UUID) async throws {
        try await api.requestVoid(
            endpoint: "/trips/\(tripId)/stops/\(stopId)",
            method: "DELETE"
        )
    }
    
    func reorderStops(tripId: UUID, stopIds: [UUID]) async throws {
        struct ReorderRequest: Codable {
            let stopIds: [UUID]
        }
        
        try await api.requestVoid(
            endpoint: "/trips/\(tripId)/stops/reorder",
            method: "PUT",
            body: ReorderRequest(stopIds: stopIds)
        )
    }
    
    // MARK: - Trip Draft/Journal
    
    func getDraft(tripId: UUID) async throws -> TripDraft {
        return try await api.request(endpoint: "/trips/\(tripId)/draft")
    }
    
    func addBlock(tripId: UUID, block: CreateBlockRequest) async throws -> JournalBlock {
        return try await api.request(
            endpoint: "/trips/\(tripId)/draft/blocks",
            method: "POST",
            body: block
        )
    }
    
    func updateBlock(tripId: UUID, blockId: UUID, block: UpdateBlockRequest) async throws -> JournalBlock {
        return try await api.request(
            endpoint: "/trips/\(tripId)/draft/blocks/\(blockId)",
            method: "PUT",
            body: block
        )
    }
    
    func deleteBlock(tripId: UUID, blockId: UUID) async throws {
        try await api.requestVoid(
            endpoint: "/trips/\(tripId)/draft/blocks/\(blockId)",
            method: "DELETE"
        )
    }
    
    func publishDraft(tripId: UUID) async throws -> Trip {
        return try await api.request(
            endpoint: "/trips/\(tripId)/publish",
            method: "POST"
        )
    }
}

// MARK: - Draft Models

struct TripDraft: Codable {
    let tripId: UUID
    let blocks: [JournalBlock]
    let updatedAt: Date
}

struct JournalBlock: Codable, Identifiable {
    let id: UUID
    let type: BlockType
    let content: String?
    let imageUrl: String?
    let order: Int
    let createdAt: Date
}

enum BlockType: String, Codable {
    case text = "Text"
    case image = "Image"
    case moment = "Moment"
    case recommendation = "Recommendation"
    case tip = "Tip"
}

struct CreateBlockRequest: Codable {
    let type: BlockType
    let content: String?
    let imageUrl: String?
}

struct UpdateBlockRequest: Codable {
    let content: String?
    let imageUrl: String?
}
