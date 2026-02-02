//
//  EditorBlockData.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/26/26.
//

import Foundation

// MARK: - Editor Block Data

/// Union type containing all possible block fields.
/// Maps to `DraftBlockDataDto` on the backend.
///
/// Field usage by block type:
/// - **Moment**: date, title, content, imageUrl, stampText, stampColor
/// - **Recommendation**: name, category, rating, priceLevel, note, imageUrl
/// - **Photo**: imageUrl, caption, rotation
/// - **Tip**: title, content
/// - **Divider**: (none)
struct EditorBlockData: Codable, Equatable {
    // MARK: - Moment Fields

    var date: String?
    var title: String?
    var content: String?
    var stampText: String?
    var stampColor: String?

    // MARK: - Recommendation Fields

    var name: String?
    var category: RecommendationCategory?
    var rating: Rating?
    var priceLevel: Int?
    var note: String?

    // MARK: - Photo Fields

    var caption: String?
    var rotation: Int?

    // MARK: - Shared Fields

    var imageUrl: String?

    // MARK: - Initializers

    init() {}

    // MARK: - Factory Methods

    static func moment(
        date: String? = nil,
        title: String? = nil,
        content: String? = nil,
        imageUrl: String? = nil,
        stampText: String? = nil,
        stampColor: String? = nil
    ) -> EditorBlockData {
        var data = EditorBlockData()
        data.date = date
        data.title = title
        data.content = content
        data.imageUrl = imageUrl
        data.stampText = stampText
        data.stampColor = stampColor
        return data
    }

    static func recommendation(
        name: String,
        category: RecommendationCategory,
        rating: Rating? = nil,
        priceLevel: Int? = nil,
        note: String? = nil,
        imageUrl: String? = nil
    ) -> EditorBlockData {
        var data = EditorBlockData()
        data.name = name
        data.category = category
        data.rating = rating
        data.priceLevel = priceLevel
        data.note = note
        data.imageUrl = imageUrl
        return data
    }

    static func photo(
        imageUrl: String? = nil,
        caption: String? = nil,
        rotation: Int? = nil
    ) -> EditorBlockData {
        var data = EditorBlockData()
        data.imageUrl = imageUrl
        data.caption = caption
        data.rotation = rotation
        return data
    }

    static func tip(
        title: String? = nil,
        content: String? = nil
    ) -> EditorBlockData {
        var data = EditorBlockData()
        data.title = title
        data.content = content
        return data
    }

    static func divider() -> EditorBlockData {
        EditorBlockData()
    }
}
