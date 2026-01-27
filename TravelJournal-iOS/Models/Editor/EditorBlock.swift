//
//  EditorBlock.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/26/26.
//

import Foundation

// MARK: - Editor Block

/// Main block model representing a single journal entry in the editor.
/// Maps to `DraftBlockDto` on the backend.
struct EditorBlock: Codable, Identifiable, Equatable {
    let id: UUID
    var order: Int
    let type: BlockType
    var location: EditorLocation?
    var data: EditorBlockData
    
    // MARK: - Initializers
    
    init(
        id: UUID = UUID(),
        order: Int,
        type: BlockType,
        location: EditorLocation? = nil,
        data: EditorBlockData
    ) {
        self.id = id
        self.order = order
        self.type = type
        self.location = location
        self.data = data
    }
    
    // MARK: - Factory Methods
    
    static func newMoment(
        order: Int,
        date: String? = nil,
        title: String? = nil,
        content: String? = nil,
        imageUrl: String? = nil,
        stampText: String? = nil,
        stampColor: String? = nil,
        location: EditorLocation? = nil
    ) -> EditorBlock {
        EditorBlock(
            order: order,
            type: .moment,
            location: location,
            data: .moment(
                date: date,
                title: title,
                content: content,
                imageUrl: imageUrl,
                stampText: stampText,
                stampColor: stampColor
            )
        )
    }
    
    static func newRecommendation(
        order: Int,
        name: String,
        category: RecommendationCategory,
        rating: Rating? = nil,
        priceLevel: Int? = nil,
        note: String? = nil,
        imageUrl: String? = nil,
        location: EditorLocation? = nil
    ) -> EditorBlock {
        EditorBlock(
            order: order,
            type: .recommendation,
            location: location,
            data: .recommendation(
                name: name,
                category: category,
                rating: rating,
                priceLevel: priceLevel,
                note: note,
                imageUrl: imageUrl
            )
        )
    }
    
    static func newPhoto(
        order: Int,
        imageUrl: String? = nil,
        caption: String? = nil,
        rotation: Int? = nil
    ) -> EditorBlock {
        EditorBlock(
            order: order,
            type: .photo,
            data: .photo(
                imageUrl: imageUrl,
                caption: caption,
                rotation: rotation
            )
        )
    }
    
    static func newTip(
        order: Int,
        title: String? = nil,
        content: String? = nil
    ) -> EditorBlock {
        EditorBlock(
            order: order,
            type: .tip,
            data: .tip(
                title: title,
                content: content
            )
        )
    }
    
    static func newDivider(order: Int) -> EditorBlock {
        EditorBlock(
            order: order,
            type: .divider,
            data: .divider()
        )
    }
}
