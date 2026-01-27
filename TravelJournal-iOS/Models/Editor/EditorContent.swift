//
//  EditorContent.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/26/26.
//

import Foundation

// MARK: - Editor Content

/// Container for the blocks array with helper methods.
/// Maps to `DraftContentDto` on the backend.
struct EditorContent: Codable, Equatable {
    var blocks: [EditorBlock]
    
    // MARK: - Initializers
    
    init(blocks: [EditorBlock] = []) {
        self.blocks = blocks
    }
    
    // MARK: - Query Helpers
    
    func block(withId id: UUID) -> EditorBlock? {
        blocks.first { $0.id == id }
    }
    
    var nextOrder: Int {
        (blocks.map(\.order).max() ?? -1) + 1
    }
    
    // MARK: - Mutation Helpers
    
    mutating func append(_ block: EditorBlock) {
        var newBlock = block
        newBlock.order = nextOrder
        blocks.append(newBlock)
    }
    
    mutating func insert(_ block: EditorBlock, at index: Int) {
        blocks.insert(block, at: index)
        reindex()
    }
    
    mutating func remove(id: UUID) {
        blocks.removeAll { $0.id == id }
        reindex()
    }
    
    mutating func update(_ block: EditorBlock) {
        guard let index = blocks.firstIndex(where: { $0.id == block.id }) else { return }
        blocks[index] = block
    }
    
    mutating func reorder(ids: [UUID]) {
        var reordered: [EditorBlock] = []
        for (index, id) in ids.enumerated() {
            guard var block = block(withId: id) else { continue }
            block.order = index
            reordered.append(block)
        }
        blocks = reordered
    }
    
    // MARK: - Private Helpers
    
    private mutating func reindex() {
        for index in blocks.indices {
            blocks[index].order = index
        }
    }
}
