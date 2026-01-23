import SwiftUI

/// Routes to the appropriate block sheet based on block type
struct BlockEditorSheet: View {
    let blockType: BlockType
    let existingBlock: JournalBlock?
    let onSave: (JournalBlock) -> Void
    let onDelete: (() -> Void)?
    
    init(
        blockType: BlockType,
        existingBlock: JournalBlock? = nil,
        onSave: @escaping (JournalBlock) -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        self.blockType = blockType
        self.existingBlock = existingBlock
        self.onSave = onSave
        self.onDelete = onDelete
    }
    
    var body: some View {
        switch blockType {
        case .text:
            TextBlockSheet(
                existingBlock: existingBlock,
                onSave: onSave,
                onDelete: onDelete
            )
        case .moment:
            MomentBlockSheet(
                existingBlock: existingBlock,
                onSave: onSave,
                onDelete: onDelete
            )
        case .image:
            ImageBlockSheet(
                existingBlock: existingBlock,
                onSave: onSave,
                onDelete: onDelete
            )
        case .recommendation:
            RecommendationBlockSheet(
                existingBlock: existingBlock,
                onSave: onSave,
                onDelete: onDelete
            )
        case .tip:
            TipBlockSheet(
                existingBlock: existingBlock,
                onSave: onSave,
                onDelete: onDelete
            )
        }
    }
}

// MARK: - Preview
#Preview("Tip") {
    BlockEditorSheet(blockType: .tip, onSave: { _ in })
}

#Preview("Moment") {
    BlockEditorSheet(blockType: .moment, onSave: { _ in })
}

#Preview("Image") {
    BlockEditorSheet(blockType: .image, onSave: { _ in })
}
