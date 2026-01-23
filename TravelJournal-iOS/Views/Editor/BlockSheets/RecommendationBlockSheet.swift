//
//  RecommendationBlockSheet.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/22/26.
//


import SwiftUI

struct RecommendationBlockSheet: View {
    let existingBlock: JournalBlock?
    let onSave: (JournalBlock) -> Void
    let onDelete: (() -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var placeName: String = ""
    @State private var recommendation: String = ""
    
    init(existingBlock: JournalBlock? = nil, onSave: @escaping (JournalBlock) -> Void, onDelete: (() -> Void)? = nil) {
        self.existingBlock = existingBlock
        self.onSave = onSave
        self.onDelete = onDelete
        
        if let block = existingBlock, let content = block.content {
            let parts = content.components(separatedBy: "\n\n")
            _placeName = State(initialValue: parts.first ?? "")
            _recommendation = State(initialValue: parts.count > 1 ? parts.dropFirst().joined(separator: "\n\n") : "")
        }
    }
    
    private var isValid: Bool {
        !placeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !recommendation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var sheetTitle: String {
        existingBlock != nil ? "Edit Recommendation" : "Add Recommendation"
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
                    BlockFormSection(label: "PLACE NAME") {
                        TextField("e.g., Cafe de Flore", text: $placeName)
                            .textFieldStyle(BlockTextFieldStyle())
                    }
                    
                    BlockFormSection(label: "WHY YOU RECOMMEND IT") {
                        BlockTextEditor(
                            text: $recommendation,
                            placeholder: "Share why others should visit...",
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
        var finalContent = placeName
        if !recommendation.isEmpty {
            finalContent += finalContent.isEmpty ? recommendation : "\n\n" + recommendation
        }
        
        let block = JournalBlock(
            id: existingBlock?.id ?? UUID(),
            type: .recommendation,
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
    RecommendationBlockSheet(onSave: { _ in })
}