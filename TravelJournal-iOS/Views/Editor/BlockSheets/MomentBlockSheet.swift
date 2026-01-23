//
//  MomentBlockSheet.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/22/26.
//

import Foundation
import SwiftUI

struct MomentBlockSheet: View {
    let existingBlock: JournalBlock?
    let onSave: (JournalBlock) -> Void
    let onDelete: (() -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var description: String = ""
    
    init(existingBlock: JournalBlock? = nil, onSave: @escaping (JournalBlock) -> Void, onDelete: (() -> Void)? = nil) {
        self.existingBlock = existingBlock
        self.onSave = onSave
        self.onDelete = onDelete
        
        if let block = existingBlock, let content = block.content {
            let parts = content.components(separatedBy: "\n\n")
            _title = State(initialValue: parts.first ?? "")
            _description = State(initialValue: parts.count > 1 ? parts.dropFirst().joined(separator: "\n\n") : "")
        }
    }
    
    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var sheetTitle: String {
        existingBlock != nil ? "Edit Moment" : "Add Moment"
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
                    BlockFormSection(label: "MOMENT TITLE") {
                        TextField("e.g., Sunrise at the beach", text: $title)
                            .textFieldStyle(BlockTextFieldStyle())
                    }
                    
                    BlockFormSection(label: "DESCRIPTION") {
                        BlockTextEditor(
                            text: $description,
                            placeholder: "Describe this moment...",
                            minHeight: 100
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
        if !description.isEmpty {
            finalContent += finalContent.isEmpty ? description : "\n\n" + description
        }
        
        let block = JournalBlock(
            id: existingBlock?.id ?? UUID(),
            type: .moment,
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
#Preview {
    MomentBlockSheet(onSave: { _ in })
}
