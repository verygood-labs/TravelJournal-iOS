//
//  CountryStamp.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/20/26.
//

import Foundation

struct CountryStamp: Codable, Identifiable {
    let countryCode: String
    let countryName: String
    let visitCount: Int
    let stampImageUrl: String?

    var id: String {
        countryCode
    }
}

struct CountryStampsResponse: Codable {
    let totalCountries: Int
    let countryStamps: [CountryStamp]
}
