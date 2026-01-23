//
//  TextBlockSheet.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/22/26.
//

import Foundation
import SwiftUI

struct TextBlockSheet: View {
    let existingBlock: JournalBlock?
    let onSave: (JournalBlock) -> Void
    let onDelete: (() -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var content: String = ""
    
    init(existingBlock: JournalBlock? = nil, onSave: @escaping (JournalBlock) -> Void, onDelete: (() -> Void)? = nil) {
        self.existingBlock = existingBlock
        self.onSave = onSave
        self.onDelete = onDelete
        
        if let block = existingBlock {
            _content = State(initialValue: block.content ?? "")
        }
    }
    
    private var isValid: Bool {
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var sheetTitle: String {
        existingBlock != nil ? "Edit Text" : "Add Text"
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
                    BlockFormSection(label: "CONTENT") {
                        BlockTextEditor(
                            text: $content,
                            placeholder: "Write your thoughts...",
                            minHeight: 150
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
        let block = JournalBlock(
            id: existingBlock?.id ?? UUID(),
            type: .text,
            content: content.isEmpty ? nil : content,
            imageUrl: nil,
            order: existingBlock?.order ?? 0,
            createdAt: existingBlock?.createdAt ?? Date()
        )
        
        onSave(block)
        dismiss()
    }
}

// MARK: - Preview
#Preview {
    TextBlockSheet(onSave: { _ in })
}
