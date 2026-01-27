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

    func getDraft(tripId: UUID) async throws -> EditorResponse {
        return try await api.request(endpoint: "/trips/\(tripId)/draft")
    }

    func addBlock(tripId: UUID, block: AddBlockRequest) async throws -> EditorBlock {
        return try await api.request(
            endpoint: "/trips/\(tripId)/draft/blocks",
            method: "POST",
            body: block
        )
    }

    func updateBlock(tripId: UUID, blockId: UUID, request: UpdateBlockRequest) async throws -> EditorBlock {
        return try await api.request(
            endpoint: "/trips/\(tripId)/draft/blocks/\(blockId)",
            method: "PUT",
            body: request
        )
    }

    func deleteBlock(tripId: UUID, blockId: UUID) async throws {
        try await api.requestVoid(
            endpoint: "/trips/\(tripId)/draft/blocks/\(blockId)",
            method: "DELETE"
        )
    }

    func saveDraft(tripId: UUID, content: EditorContent) async throws {
        let request = SaveDraftRequest(content: content)
        try await api.requestVoid(
            endpoint: "/trips/\(tripId)/draft",
            method: "PUT",
            body: request
        )
    }

    func reorderBlocks(tripId: UUID, blockIds: [UUID]) async throws {
        let request = ReorderBlocksRequest(blockIds: blockIds)
        try await api.requestVoid(
            endpoint: "/trips/\(tripId)/draft/blocks/reorder",
            method: "PUT",
            body: request
        )
    }

    func publishDraft(tripId: UUID) async throws -> Trip {
        return try await api.request(
            endpoint: "/trips/\(tripId)/publish",
            method: "POST"
        )
    }
}
