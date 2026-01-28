//
//  PhotoBlockSheet.swift
//  TravelJournal-iOS
//

import SwiftUI

struct PhotoBlockSheet: View {
    let existingBlock: EditorBlock?
    let tripId: UUID
    let onSave: (EditorBlock) -> Void
    let onDelete: (() -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    
    @State private var caption: String = ""
    @State private var imageUrl: String = ""
    @State private var rotation: Int = 0
    
    // Image picker state
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    
    // Upload state
    @State private var isUploading = false
    @State private var uploadError: String?
    
    // MARK: - Init
    
    init(
        existingBlock: EditorBlock? = nil,
        tripId: UUID,
        onSave: @escaping (EditorBlock) -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        self.existingBlock = existingBlock
        self.tripId = tripId
        self.onSave = onSave
        self.onDelete = onDelete
        
        if let block = existingBlock {
            _caption = State(initialValue: block.data.caption ?? "")
            _imageUrl = State(initialValue: block.data.imageUrl ?? "")
            _rotation = State(initialValue: block.data.rotation ?? 0)
        }
    }
    
    // MARK: - Computed
    
    private var hasImage: Bool {
        !imageUrl.isEmpty || selectedImage != nil
    }
    
    private var isValid: Bool {
        hasImage && !isUploading
    }
    
    private var sheetTitle: String {
        existingBlock != nil ? "Edit Photo" : "Add Photo"
    }
    
    // MARK: - Body
    
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
                    // Photo section
                    BlockFormSection(label: "PHOTO") {
                        photoContent
                    }
                    
                    // Rotation slider
                    BlockFormSection(label: "ROTATION") {
                        rotationSlider
                    }
                    
                    // Caption
                    BlockFormSection(label: "CAPTION (OPTIONAL)") {
                        BlockTextEditor(
                            text: $caption,
                            placeholder: "Add a caption for this photo...",
                            minHeight: 80
                        )
                    }
                    
                    // Error message
                    if let error = uploadError {
                        Text(error)
                            .font(AppTheme.Typography.monoSmall())
                            .foregroundColor(.red)
                            .padding(.horizontal, AppTheme.Spacing.xs)
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
        .onChange(of: selectedImage) { _, newImage in
            if let image = newImage {
                uploadImage(image)
            }
        }
    }
    
    // MARK: - Photo Content
    
    @ViewBuilder
    private var photoContent: some View {
        if isUploading {
            // Uploading state
            uploadingView
        } else if let url = URL(string: imageUrl), !imageUrl.isEmpty {
            // Show uploaded image
            imagePreview(url: url)
        } else {
            // Show placeholder with action buttons
            imagePlaceholder
        }
    }
    
    // MARK: - Uploading View
    
    private var uploadingView: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Uploading...")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.passportTextMuted)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(AppTheme.Colors.passportInputBackground)
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
    
    // MARK: - Image Preview
    
    private func imagePreview(url: URL) -> some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            AsyncImage(url: APIService.shared.fullMediaURL(for: imageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(height: 200)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 250)
                        .rotationEffect(.degrees(Double(rotation)))
                        .cornerRadius(AppTheme.CornerRadius.small)
                case .failure:
                    failedImageView
                @unknown default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity)
            
            // Replace button
            Button {
                showImageSourceOptions()
            } label: {
                HStack(spacing: AppTheme.Spacing.xxxs) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 12))
                    Text("REPLACE PHOTO")
                        .font(AppTheme.Typography.monoCaption())
                        .tracking(1)
                }
                .foregroundColor(AppTheme.Colors.primary)
                .padding(.vertical, AppTheme.Spacing.xs)
            }
        }
    }
    
    // MARK: - Failed Image View
    
    private var failedImageView: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundColor(AppTheme.Colors.passportTextMuted)
            
            Text("Failed to load image")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.passportTextMuted)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .background(AppTheme.Colors.passportInputBackground)
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
    
    // MARK: - Image Placeholder
    
    private var imagePlaceholder: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Placeholder icon
            VStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 40))
                    .foregroundColor(AppTheme.Colors.passportTextMuted.opacity(0.6))
                
                Text("Add a photo")
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
            
            // Action buttons
            HStack(spacing: AppTheme.Spacing.sm) {
                Button {
                    showingCamera = true
                } label: {
                    HStack(spacing: AppTheme.Spacing.xxxs) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 12))
                        Text("CAMERA")
                            .font(AppTheme.Typography.monoCaption())
                            .tracking(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(AppTheme.Colors.primary)
                    .foregroundColor(AppTheme.Colors.passportPageLight)
                    .cornerRadius(AppTheme.CornerRadius.medium)
                }
                
                Button {
                    showingImagePicker = true
                } label: {
                    HStack(spacing: AppTheme.Spacing.xxxs) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 12))
                        Text("LIBRARY")
                            .font(AppTheme.Typography.monoCaption())
                            .tracking(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(AppTheme.Colors.passportInputBackground)
                    .foregroundColor(AppTheme.Colors.primary)
                    .cornerRadius(AppTheme.CornerRadius.medium)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                            .stroke(AppTheme.Colors.primary, lineWidth: 1)
                    )
                }
            }
        }
    }
    
    // MARK: - Rotation Slider
    
    private var rotationSlider: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            HStack {
                Text("-180°")
                    .font(AppTheme.Typography.monoCaption())
                    .foregroundColor(AppTheme.Colors.passportTextMuted)
                
                Slider(value: Binding(
                    get: { Double(rotation) },
                    set: { rotation = Int($0) }
                ), in: -180...180, step: 1)
                .tint(AppTheme.Colors.primary)
                
                Text("+180°")
                    .font(AppTheme.Typography.monoCaption())
                    .foregroundColor(AppTheme.Colors.passportTextMuted)
            }
            
            Text("\(rotation)°")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.passportTextSecondary)
        }
        .padding(AppTheme.Spacing.sm)
        .background(AppTheme.Colors.passportInputBackground)
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
    
    // MARK: - Actions
    
    private func showImageSourceOptions() {
        // For simplicity, just show library.
        // Could use ActionSheet for camera/library choice
        showingImagePicker = true
    }
    
    private func uploadImage(_ image: UIImage) {
        isUploading = true
        uploadError = nil
        
        Task {
            do {
                let result = try await MediaService.shared.upload(
                    image: image,
                    type: .block,
                    tripId: tripId
                )
                
                await MainActor.run {
                    imageUrl = result.url
                    selectedImage = nil // Clear local image
                    isUploading = false
                }
            } catch {
                await MainActor.run {
                    uploadError = "Upload failed. Please try again."
                    selectedImage = nil
                    isUploading = false
                }
                print("Image upload error: \(error)")
            }
        }
    }
    
    private func saveAndDismiss() {
        let block = EditorBlock.newPhoto(
            order: existingBlock?.order ?? 0,
            imageUrl: imageUrl.isEmpty ? nil : imageUrl,
            caption: caption.isEmpty ? nil : caption,
            rotation: rotation == 0 ? nil : rotation
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
    PhotoBlockSheet(tripId: UUID(), onSave: { _ in })
}
