//
//  CreateTripRequest.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/25/26.
//


import Foundation

// MARK: - Create Trip

struct CreateTripRequest: Codable {
    let title: String
    let description: String?
    let tripMode: Int
    let startDate: String?
    let endDate: String?
    let initialStops: [CreateTripStopRequest]?
    
    init(
        title: String,
        description: String?,
        startDate: Date?,
        endDate: Date?,
        initialStops: [CreateTripStopRequest]? = nil
    ) {
        self.title = title
        self.description = description
        self.tripMode = 0
        self.initialStops = initialStops
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        self.startDate = startDate.map { formatter.string(from: $0) }
        self.endDate = endDate.map { formatter.string(from: $0) }
    }
}

struct CreateTripStopRequest: Codable {
    let osmType: String
    let osmId: Int64
    let arrivalDate: String?
    
    init(osmType: String, osmId: Int64, arrivalDate: Date? = nil) {
        self.osmType = osmType
        self.osmId = osmId
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.arrivalDate = arrivalDate.map { formatter.string(from: $0) }
    }
}
