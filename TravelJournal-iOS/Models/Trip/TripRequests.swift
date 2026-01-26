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
    
    init(title: String, description: String?, startDate: Date?, endDate: Date?) {
        self.title = title
        self.description = description
        self.tripMode = 0
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        self.startDate = startDate.map { formatter.string(from: $0) }
        self.endDate = endDate.map { formatter.string(from: $0) }
    }
}

// MARK: - Update Trip

struct UpdateTripRequest: Codable {
    let title: String?
    let description: String?
    let startDate: Date?
    let endDate: Date?
}