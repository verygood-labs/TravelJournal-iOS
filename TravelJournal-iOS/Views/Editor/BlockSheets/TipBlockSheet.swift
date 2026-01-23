//
//  TipBlockSheet.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/22/26.
//

import Foundation
import SwiftUI

struct TipBlockSheet: View {
    let existingBlock: JournalBlock?
    let onSave: (JournalBlock) -> Void
    let onDelete: (() -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var advice: String = ""
    
    init(existingBlock: JournalBlock? = nil, onSave: @escaping (JournalBlock) -> Void, onDelete: (() -> Void)? = nil) {
        self.existingBlock = existingBlock
        self.onSave = onSave
        self.onDelete = onDelete
        
        if let block = existingBlock, let content = block.content {
            // Parse title and advice from content if editing
            let parts = content.components(separatedBy: "\n\n")
            _title = State(initialValue: parts.first ?? "")
            _advice = State(initialValue: parts.count > 1 ? parts.dropFirst().joined(separator: "\n\n") : "")
        }
    }
    
    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !advice.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
                            text: $advice,
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
        var finalContent = title
        if !advice.isEmpty {
            finalContent += finalContent.isEmpty ? advice : "\n\n" + advice
        }
        
        let block = JournalBlock(
            id: existingBlock?.id ?? UUID(),
            type: .tip,
            content: finalContent.isEmpty ? nil : finalContent,
            imageUrl: nil,
            order: existingBlock?.order ?? 0,
            createdAt: existingBlock?.createdAt ?? Date()
        )
        
        onSave(block)
        dismiss()
    }
}

// MARK: - Preview
#Preview("New Tip") {
    TipBlockSheet(onSave: { _ in })
}

#Preview("Edit Tip") {
    TipBlockSheet(
        existingBlock: JournalBlock(
            id: UUID(),
            type: .tip,
            content: "Getting Around\n\nUse Grab for affordable transportation. Much cheaper than taxis!",
            imageUrl: nil,
            order: 0,
            createdAt: Date()
        ),
        onSave: { _ in },
        onDelete: {}
    )
}
