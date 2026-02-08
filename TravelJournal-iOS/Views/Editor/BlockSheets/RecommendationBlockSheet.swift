//
//  RecommendationBlockSheet.swift
//  TravelJournal-iOS
//

import SwiftUI

struct RecommendationBlockSheet: View {
    let existingBlock: EditorBlock?
    let tripId: UUID
    let tripCountryCode: String?
    let tripLatitude: Double?
    let tripLongitude: Double?
    let onSave: (EditorBlock) -> Void
    let onDelete: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var category: RecommendationCategory = .eat
    @State private var rating: Rating? = nil
    @State private var priceLevel: Int? = nil
    @State private var note: String = ""

    // Location picker state
    @State private var locationSearchText: String = ""
    @State private var selectedLocation: EditorLocation?

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
        tripCountryCode: String? = nil,
        tripLatitude: Double? = nil,
        tripLongitude: Double? = nil,
        onSave: @escaping (EditorBlock) -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        self.existingBlock = existingBlock
        self.tripId = tripId
        self.tripCountryCode = tripCountryCode
        self.tripLatitude = tripLatitude
        self.tripLongitude = tripLongitude
        self.onSave = onSave
        self.onDelete = onDelete

        if let block = existingBlock {
            _name = State(initialValue: block.data.name ?? "")
            _category = State(initialValue: block.data.category ?? .eat)
            _rating = State(initialValue: block.data.rating)
            _priceLevel = State(initialValue: block.data.priceLevel)
            _note = State(initialValue: block.data.note ?? "")
            _imageUrl = State(initialValue: block.data.imageUrl ?? "")
            _selectedLocation = State(initialValue: block.location)
        }
    }

    private var isValid: Bool {
        !isUploading && !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var hasImage: Bool {
        !imageUrl.isEmpty || selectedImage != nil
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
                    // Location search section
                    BlockFormSection(label: "LOCATION (OPTIONAL)") {
                        PlaceSearchField(
                            searchText: $locationSearchText,
                            selectedLocation: $selectedLocation,
                            onPlaceSelected: { result in
                                handlePlaceSelection(result)
                            },
                            countryCode: tripCountryCode,
                            latitude: tripLatitude,
                            longitude: tripLongitude
                        )
                    }

                    BlockFormSection(label: "PLACE NAME") {
                        TextField("e.g., Cafe de Flore", text: $name)
                            .textFieldStyle(BlockTextFieldStyle())
                    }

                    BlockFormSection(label: "CATEGORY") {
                        CategoryPicker(selection: $category)
                    }

                    BlockFormSection(label: "RATING (OPTIONAL)") {
                        RatingPicker(selection: $rating)
                    }

                    BlockFormSection(label: "WHY YOU RECOMMEND IT") {
                        BlockTextEditor(
                            text: $note,
                            placeholder: "Share why others should visit...",
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

    // MARK: - Location Selection

    private func handlePlaceSelection(_ result: LocationSearchResult) {
        // Convert LocationSearchResult to EditorLocation
        selectedLocation = EditorLocation(
            osmType: result.osmType,
            osmId: result.osmId,
            name: result.name,
            displayName: result.displayName,
            latitude: Decimal(result.latitude),
            longitude: Decimal(result.longitude)
        )

        // Auto-fill the name field
        name = result.name
    }

    private func saveAndDismiss() {
        let block = EditorBlock.newRecommendation(
            order: existingBlock?.order ?? 0,
            name: name,
            category: category,
            rating: rating,
            priceLevel: priceLevel,
            note: note.isEmpty ? nil : note,
            imageUrl: imageUrl.isEmpty ? nil : imageUrl
        )

        // Preserve the ID if editing, use selected location
        let finalBlock = EditorBlock(
            id: existingBlock?.id ?? block.id,
            order: block.order,
            type: block.type,
            location: selectedLocation,
            data: block.data
        )

        onSave(finalBlock)
        dismiss()
    }
}

// MARK: - Category Picker

private struct CategoryPicker: View {
    @Binding var selection: RecommendationCategory

    var body: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            ForEach(RecommendationCategory.allCases, id: \.self) { category in
                CategoryButton(
                    category: category,
                    isSelected: selection == category
                ) {
                    selection = category
                }
            }
        }
    }
}

private struct CategoryButton: View {
    let category: RecommendationCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.system(size: 16))
                Text(category.displayName)
                    .font(AppTheme.Typography.monoCaption())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(isSelected ? AppTheme.Colors.primary.opacity(0.2) : AppTheme.Colors.passportInputBackground)
            .foregroundColor(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.passportTextSecondary)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.passportInputBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Rating Picker

private struct RatingPicker: View {
    @Binding var selection: Rating?

    var body: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            ForEach(Rating.allCases, id: \.self) { rating in
                RatingButton(
                    rating: rating,
                    isSelected: selection == rating
                ) {
                    if selection == rating {
                        selection = nil
                    } else {
                        selection = rating
                    }
                }
            }
        }
    }
}

private struct RatingButton: View {
    let rating: Rating
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(rating.displayName)
                .font(AppTheme.Typography.monoSmall())
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(isSelected ? rating.color.opacity(0.2) : AppTheme.Colors.passportInputBackground)
                .foregroundColor(isSelected ? rating.color : AppTheme.Colors.passportTextSecondary)
                .cornerRadius(AppTheme.CornerRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .stroke(isSelected ? rating.color : AppTheme.Colors.passportInputBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("New Recommendation") {
    RecommendationBlockSheet(tripId: UUID(), onSave: { _ in })
}

#Preview("Edit Recommendation with Photo") {
    let sampleBlock = EditorBlock.newRecommendation(
        order: 0,
        name: "Aristocrat Restaurant",
        category: .eat,
        rating: .a,
        priceLevel: 2,
        note: "Best chicken barbecue in Manila!",
        imageUrl: "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400"
    )
    RecommendationBlockSheet(
        existingBlock: sampleBlock,
        tripId: UUID(),
        onSave: { _ in },
        onDelete: { }
    )
}
