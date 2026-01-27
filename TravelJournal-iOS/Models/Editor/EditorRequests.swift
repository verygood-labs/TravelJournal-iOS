//
//  AddBlockRequest.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/26/26.
//

import Foundation

// MARK: - Add Block Request

/// Request body for POST /trips/{tripId}/draft/blocks
struct AddBlockRequest: Codable {
    let type: BlockType
    let location: EditorLocation?
    let data: EditorBlockData
    let insertAtOrder: Int?
    
    init(block: EditorBlock, insertAtOrder: Int? = nil) {
        self.type = block.type
        self.location = block.location
        self.data = block.data
        self.insertAtOrder = insertAtOrder
    }
}

// MARK: - Update Block Request

/// Request body for PUT /trips/{tripId}/draft/blocks/{blockId}
struct UpdateBlockRequest: Codable {
    let location: EditorLocation?
    let data: EditorBlockData
    
    init(block: EditorBlock) {
        self.location = block.location
        self.data = block.data
    }
}

// MARK: - Save Draft Request

/// Request body for PUT /trips/{tripId}/draft (full save)
struct SaveDraftRequest: Codable {
    let blocks: [EditorBlock]
    
    init(content: EditorContent) {
        self.blocks = content.blocks
    }
}

// MARK: - Reorder Blocks Request

/// Request body for PUT /trips/{tripId}/draft/blocks/reorder
struct ReorderBlocksRequest: Codable {
    let blockIds: [UUID]
}
