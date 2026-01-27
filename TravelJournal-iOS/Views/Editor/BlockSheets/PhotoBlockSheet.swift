//
//  PhotoBlockSheet.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/26/26.
//


//
//  PhotoBlockSheet.swift
//  TravelJournal-iOS
//

import SwiftUI

struct PhotoBlockSheet: View {
    let existingBlock: EditorBlock?
    let onSave: (EditorBlock) -> Void
    let onDelete: (() -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var caption: String = ""
    @State private var imageUrl: String = ""
    
    init(
        existingBlock: EditorBlock? = nil,
        onSave: @escaping (EditorBlock) -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        self.existingBlock = existingBlock
        self.onSave = onSave
        self.onDelete = onDelete
        
        if let block = existingBlock {
            _caption = State(initialValue: block.data.caption ?? "")
            _imageUrl = State(initialValue: block.data.imageUrl ?? "")
        }
    }
    
    private var isValid: Bool {
        // For now, allow saving without image (will add picker later)
        true
    }
    
    private var sheetTitle: String {
        existingBlock != nil ? "Edit Photo" : "Add Photo"
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
                    // TODO: Add image picker
                    BlockFormSection(label: "PHOTO") {
                        imagePlaceholder
                    }
                    
                    BlockFormSection(label: "CAPTION (OPTIONAL)") {
                        BlockTextEditor(
                            text: $caption,
                            placeholder: "Add a caption for this photo...",
                            minHeight: 80
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
    
    // MARK: - Image Placeholder
    
    private var imagePlaceholder: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 32))
                .foregroundColor(AppTheme.Colors.passportTextMuted)
            
            Text("Tap to add photo")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.passportTextMuted)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .background(AppTheme.Colors.passportInputBackground)
        .cornerRadius(AppTheme.CornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .stroke(AppTheme.Colors.passportInputBorder, style: StrokeStyle(lineWidth: 1, dash: [5]))
        )
    }
    
    private func saveAndDismiss() {
        let block = EditorBlock.newPhoto(
            order: existingBlock?.order ?? 0,
            imageUrl: imageUrl.isEmpty ? nil : imageUrl,
            caption: caption.isEmpty ? nil : caption
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
    PhotoBlockSheet(onSave: { _ in })
}
