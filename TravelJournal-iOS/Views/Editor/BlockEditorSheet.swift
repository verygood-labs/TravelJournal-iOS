import SwiftUI

/// Routes to the appropriate block sheet based on block type
struct BlockEditorSheet: View {
    let blockType: BlockType
    let existingBlock: EditorBlock?
    let tripId: UUID?
    let onSave: (EditorBlock) -> Void
    let onDelete: (() -> Void)?

    init(
        blockType: BlockType,
        existingBlock: EditorBlock? = nil,
        tripId: UUID? = nil,
        onSave: @escaping (EditorBlock) -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        self.blockType = blockType
        self.existingBlock = existingBlock
        self.tripId = tripId
        self.onSave = onSave
        self.onDelete = onDelete
    }

    var body: some View {
        switch blockType {
        case .moment:
            MomentBlockSheet(
                existingBlock: existingBlock,
                tripId: tripId ?? UUID(), // Fallback for preview
                onSave: onSave,
                onDelete: onDelete
            )
        case .photo:
            PhotoBlockSheet(
                existingBlock: existingBlock,
                tripId: tripId ?? UUID(), // Fallback for preview
                onSave: onSave,
                onDelete: onDelete
            )
        case .recommendation:
            RecommendationBlockSheet(
                existingBlock: existingBlock,
                tripId: tripId ?? UUID(), // Fallback for preview
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
    BlockEditorSheet(blockType: .moment, tripId: UUID(), onSave: { _ in })
}

#Preview("Photo") {
    BlockEditorSheet(blockType: .photo, tripId: UUID(), onSave: { _ in })
}

#Preview("Recommendation") {
    BlockEditorSheet(blockType: .recommendation, tripId: UUID(), onSave: { _ in })
}
