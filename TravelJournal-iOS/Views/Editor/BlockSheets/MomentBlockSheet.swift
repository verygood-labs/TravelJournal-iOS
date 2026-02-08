//
//  MomentBlockSheet.swift
//  TravelJournal-iOS
//

import SwiftUI

struct MomentBlockSheet: View {
    let existingBlock: EditorBlock?
    let tripId: UUID
    let onSave: (EditorBlock) -> Void
    let onDelete: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var content: String = ""
    @State private var date: String = ""

    // Image picker state
    @State private var imageUrl: String = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCamera = false

    // Upload state
    @State private var isUploading = false
    @State private var uploadError: String?

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
            _title = State(initialValue: block.data.title ?? "")
            _content = State(initialValue: block.data.content ?? "")
            _date = State(initialValue: block.data.date ?? "")
            _imageUrl = State(initialValue: block.data.imageUrl ?? "")
        }
    }

    private var isValid: Bool {
        !isUploading && (
            !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        )
    }

    private var hasImage: Bool {
        !imageUrl.isEmpty || selectedImage != nil
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
                            text: $content,
                            placeholder: "Describe this moment...",
                            minHeight: 100
                        )
                    }

                    // Photo section
                    BlockFormSection(label: "PHOTO (OPTIONAL)") {
                        photoContent
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
            uploadingView
        } else if !imageUrl.isEmpty {
            imagePreview
        } else {
            imagePlaceholder
        }
    }

    private var uploadingView: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Uploading...")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.passportTextMuted)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .background(AppTheme.Colors.passportInputBackground)
        .cornerRadius(AppTheme.CornerRadius.medium)
    }

    private var imagePreview: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            AsyncImage(url: APIService.shared.fullMediaURL(for: imageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(height: 150)
                case let .success(image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .cornerRadius(AppTheme.CornerRadius.small)
                case .failure:
                    failedImageView
                @unknown default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity)

            HStack(spacing: AppTheme.Spacing.sm) {
                Button {
                    showingImagePicker = true
                } label: {
                    HStack(spacing: AppTheme.Spacing.xxxs) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 12))
                        Text("REPLACE")
                            .font(AppTheme.Typography.monoCaption())
                            .tracking(1)
                    }
                    .foregroundColor(AppTheme.Colors.primary)
                }

                Button {
                    imageUrl = ""
                } label: {
                    HStack(spacing: AppTheme.Spacing.xxxs) {
                        Image(systemName: "trash")
                            .font(.system(size: 12))
                        Text("REMOVE")
                            .font(AppTheme.Typography.monoCaption())
                            .tracking(1)
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }

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

    private var imagePlaceholder: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            VStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 32))
                    .foregroundColor(AppTheme.Colors.passportTextMuted.opacity(0.6))
                Text("Add a photo")
                    .font(AppTheme.Typography.monoSmall())
                    .foregroundColor(AppTheme.Colors.passportTextMuted)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(AppTheme.Colors.passportInputBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(AppTheme.Colors.passportInputBorder, style: StrokeStyle(lineWidth: 1, dash: [5]))
            )

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

    // MARK: - Upload

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
                    selectedImage = nil
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
        let block = EditorBlock.newMoment(
            order: existingBlock?.order ?? 0,
            date: date.isEmpty ? nil : date,
            title: title.isEmpty ? nil : title,
            content: content.isEmpty ? nil : content,
            imageUrl: imageUrl.isEmpty ? nil : imageUrl
        )

        // Preserve the ID if editing
        let finalBlock = EditorBlock(
            id: existingBlock?.id ?? block.id,
            order: block.order,
            type: block.type,
            location: existingBlock?.location,
            data: block.data
        )

        onSave(finalBlock)
        dismiss()
    }
}

// MARK: - Preview

#Preview("New Moment") {
    MomentBlockSheet(tripId: UUID(), onSave: { _ in })
}

#Preview("Edit Moment with Photo") {
    let sampleBlock = EditorBlock.newMoment(
        order: 0,
        date: "Jan 15, 2026",
        title: "Exploring Intramuros",
        content: "Spent the morning walking through the old walled city.",
        imageUrl: "https://images.unsplash.com/photo-1518509562904-e7ef99cdcc86?w=400"
    )
    MomentBlockSheet(
        existingBlock: sampleBlock,
        tripId: UUID(),
        onSave: { _ in },
        onDelete: { }
    )
}
