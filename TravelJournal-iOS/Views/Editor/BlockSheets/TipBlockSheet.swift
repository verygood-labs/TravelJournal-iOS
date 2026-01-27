//
//  TipBlockSheet.swift
//  TravelJournal-iOS
//

import SwiftUI

struct TipBlockSheet: View {
    let existingBlock: EditorBlock?
    let onSave: (EditorBlock) -> Void
    let onDelete: (() -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var content: String = ""
    
    init(
        existingBlock: EditorBlock? = nil,
        onSave: @escaping (EditorBlock) -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        self.existingBlock = existingBlock
        self.onSave = onSave
        self.onDelete = onDelete
        
        if let block = existingBlock {
            _title = State(initialValue: block.data.title ?? "")
            _content = State(initialValue: block.data.content ?? "")
        }
    }
    
    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var sheetTitle: String {
        existingBlock != nil ? "Edit Tip" : "Add Tip"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            BlockSheetNavigationBar(
                title: sheetTitle,
                isValid: isValid,
                onCancel: { dismiss() },
                onDone: { saveAndDismiss() }
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    BlockFormSection(label: "TIP TITLE") {
                        TextField("e.g., Getting Around", text: $title)
                            .textFieldStyle(BlockTextFieldStyle())
                    }
                    
                    BlockFormSection(label: "ADVICE") {
                        BlockTextEditor(
                            text: $content,
                            placeholder: "Share your helpful tip..."
                        )
                    }
                }
                .padding(AppTheme.Spacing.md)
            }
            
            Spacer()
            
            if existingBlock != nil, let onDelete = onDelete {
                BlockDeleteButton(onDelete: onDelete)
                    .padding(.bottom, AppTheme.Spacing.lg)
            }
        }
        .background(AppTheme.Colors.passportPageDark)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private func saveAndDismiss() {
        let block = EditorBlock.newTip(
            order: existingBlock?.order ?? 0,
            title: title.isEmpty ? nil : title,
            content: content.isEmpty ? nil : content
        )
        
        // Preserve the ID if editing
        let finalBlock = EditorBlock(
            id: existingBlock?.id ?? block.id,
            order: block.order,
            type: block.type,
            location: block.location,
            data: block.data
        )
        
        onSave(finalBlock)
        dismiss()
    }
}

// MARK: - Preview
#Preview {
    TipBlockSheet(onSave: { _ in })
}
