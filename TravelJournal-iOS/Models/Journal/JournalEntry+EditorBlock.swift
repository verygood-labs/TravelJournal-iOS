//
//  JournalEntry+EditorBlock.swift
//  TravelJournal-iOS
//
//  Created on 2/8/26.
//

import Foundation

// MARK: - JournalEntry to EditorBlock Conversion

extension JournalEntry {
    /// Converts this published journal entry to an EditorBlock for themed rendering.
    func toEditorBlock() -> EditorBlock {
        switch blockType {
        case .moment:
            return EditorBlock(
                id: id,
                order: order,
                type: .moment,
                location: moment?.place?.toEditorLocation(),
                data: .moment(
                    date: moment?.date,
                    title: moment?.title,
                    content: moment?.content,
                    imageUrl: moment?.imageUrl,
                    stampText: moment?.stampText,
                    stampColor: moment?.stampColor
                )
            )

        case .recommendation:
            return EditorBlock(
                id: id,
                order: order,
                type: .recommendation,
                location: recommendation?.place?.toEditorLocation(),
                data: .recommendation(
                    name: recommendation?.name ?? "",
                    category: recommendation?.category ?? .eat,
                    rating: recommendation?.rating,
                    priceLevel: recommendation?.priceLevel,
                    note: recommendation?.note,
                    imageUrl: recommendation?.imageUrl
                )
            )

        case .photo:
            return EditorBlock(
                id: id,
                order: order,
                type: .photo,
                location: nil,
                data: .photo(
                    imageUrl: photo?.imageUrl,
                    caption: photo?.caption,
                    rotation: photo?.rotation
                )
            )

        case .tip:
            return EditorBlock(
                id: id,
                order: order,
                type: .tip,
                location: nil,
                data: .tip(title: tip?.title, content: tip?.content)
            )

        case .divider:
            return EditorBlock(
                id: id,
                order: order,
                type: .divider,
                location: nil,
                data: EditorBlockData()
            )
        }
    }
}

// MARK: - PlaceSummary to EditorLocation Conversion

extension PlaceSummary {
    /// Converts this place summary to an EditorLocation for themed rendering.
    /// Note: OSM fields are placeholders since published data uses resolved place IDs.
    func toEditorLocation() -> EditorLocation {
        EditorLocation(
            osmType: "N",
            osmId: 0,
            name: name,
            displayName: displayName,
            latitude: 0,
            longitude: 0
        )
    }
}
