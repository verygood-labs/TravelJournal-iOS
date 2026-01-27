import SwiftUI

/// Routes to the appropriate block sheet based on block type
struct BlockEditorSheet: View {
    let blockType: BlockType
    let existingBlock: EditorBlock?
    let onSave: (EditorBlock) -> Void
    let onDelete: (() -> Void)?
    
    init(
        blockType: BlockType,
        existingBlock: EditorBlock? = nil,
        onSave: @escaping (EditorBlock) -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        self.blockType = blockType
        self.existingBlock = existingBlock
        self.onSave = onSave
        self.onDelete = onDelete
    }
    
    var body: some View {
        switch blockType {
        case .moment:
            MomentBlockSheet(
                existingBlock: existingBlock,
                onSave: onSave,
                onDelete: onDelete
            )
        case .photo:
            PhotoBlockSheet(
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
        case .divider:
            DividerBlockSheet(
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

#Preview("Photo") {
    BlockEditorSheet(blockType: .photo, onSave: { _ in })
}
