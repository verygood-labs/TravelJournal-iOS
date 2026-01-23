//
//  ImageBlockSheet.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/22/26.
//


import SwiftUI

struct ImageBlockSheet: View {
    let existingBlock: JournalBlock?
    let onSave: (JournalBlock) -> Void
    let onDelete: (() -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var caption: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    
    init(existingBlock: JournalBlock? = nil, onSave: @escaping (JournalBlock) -> Void, onDelete: (() -> Void)? = nil) {
        self.existingBlock = existingBlock
        self.onSave = onSave
        self.onDelete = onDelete
        
        if let block = existingBlock {
            _caption = State(initialValue: block.content ?? "")
        }
    }
    
    private var isValid: Bool {
        // For now, allow saving even without image (can add later)
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
                    BlockFormSection(label: "PHOTO") {
                        photoPickerArea
                    }
                    
                    BlockFormSection(label: "CAPTION") {
                        TextField("Describe this photo...", text: $caption)
                            .textFieldStyle(BlockTextFieldStyle())
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
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
        }
        .fullScreenCover(isPresented: $showingCamera) {
            ImagePicker(image: $selectedImage, sourceType: .camera)
        }
    }
    
    // MARK: - Photo Picker Area
    private var photoPickerArea: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            if let image = selectedImage {
                // Show selected image
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(AppTheme.CornerRadius.medium)
                    .overlay(
                        // Remove button
                        Button {
                            selectedImage = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .shadow(radius: 2)
                        }
                        .padding(AppTheme.Spacing.xs),
                        alignment: .topTrailing
                    )
            } else {
                // Show picker buttons
                VStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 40))
                        .foregroundColor(AppTheme.Colors.passportTextMuted)
                    
                    HStack(spacing: AppTheme.Spacing.md) {
                        Button {
                            showingCamera = true
                        } label: {
                            HStack(spacing: AppTheme.Spacing.xxxs) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 14))
                                Text("Camera")
                                    .font(AppTheme.Typography.monoSmall())
                            }
                            .foregroundColor(AppTheme.Colors.primary)
                            .padding(.horizontal, AppTheme.Spacing.md)
                            .padding(.vertical, AppTheme.Spacing.xs)
                            .background(AppTheme.Colors.primary.opacity(0.1))
                            .cornerRadius(AppTheme.CornerRadius.pill)
                        }
                        
                        Button {
                            showingImagePicker = true
                        } label: {
                            HStack(spacing: AppTheme.Spacing.xxxs) {
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 14))
                                Text("Library")
                                    .font(AppTheme.Typography.monoSmall())
                            }
                            .foregroundColor(AppTheme.Colors.primary)
                            .padding(.horizontal, AppTheme.Spacing.md)
                            .padding(.vertical, AppTheme.Spacing.xs)
                            .background(AppTheme.Colors.primary.opacity(0.1))
                            .cornerRadius(AppTheme.CornerRadius.pill)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .background(AppTheme.Colors.passportInputBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .stroke(AppTheme.Colors.passportInputBorder, style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                )
                .cornerRadius(AppTheme.CornerRadius.medium)
            }
        }
    }
    
    private func saveAndDismiss() {
        // TODO: Upload image and get URL
        let block = JournalBlock(
            id: existingBlock?.id ?? UUID(),
            type: .image,
            content: caption.isEmpty ? nil : caption,
            imageUrl: existingBlock?.imageUrl, // Keep existing or set new after upload
            order: existingBlock?.order ?? 0,
            createdAt: existingBlock?.createdAt ?? Date()
        )
        
        onSave(block)
        dismiss()
    }
}

// MARK: - Preview
#Preview {
    ImageBlockSheet(onSave: { _ in })
}
