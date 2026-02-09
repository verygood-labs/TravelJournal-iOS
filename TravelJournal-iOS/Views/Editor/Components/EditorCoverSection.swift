//
//  EditorCoverSection.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/22/26.
//

import SwiftUI

struct EditorCoverSection: View {
    @ObservedObject var viewModel: JournalEditorViewModel

    var body: some View {
        ZStack {
            // Background
            if let image = viewModel.selectedCoverImage {
                // Show selected image
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                    .overlay(
                        // Gradient overlay for better text visibility
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.3),
                                Color.clear,
                                Color.black.opacity(0.3),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            } else if let urlString = viewModel.coverImageUrl,
                      let url = APIService.shared.fullMediaURL(for: urlString)
            {
                // Show existing cover from URL
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholderBackground
                            .overlay(ProgressView())
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    colors: [
                                        Color.black.opacity(0.3),
                                        Color.clear,
                                        Color.black.opacity(0.3),
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    case .failure:
                        placeholderBackground
                    @unknown default:
                        placeholderBackground
                    }
                }
            } else {
                // Show placeholder
                placeholderBackground
            }

            // Cover actions
            coverActions
        }
        .frame(height: 200)
        .sheet(isPresented: $viewModel.showingCoverImagePicker) {
            ImagePicker(image: $viewModel.selectedCoverImage, sourceType: .photoLibrary)
        }
        .fullScreenCover(isPresented: $viewModel.showingCoverCamera) {
            ImagePicker(image: $viewModel.selectedCoverImage, sourceType: .camera)
        }
    }

    // MARK: - Placeholder Background

    private var placeholderBackground: some View {
        LinearGradient(
            colors: [
                AppTheme.Colors.backgroundMedium,
                AppTheme.Colors.backgroundDark,
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(height: 200)
    }

    // MARK: - Cover Actions

    private var coverActions: some View {
        VStack {
            if viewModel.selectedCoverImage != nil || viewModel.coverImageUrl != nil {
                // Show edit/remove buttons
                HStack {
                    Spacer()

                    Menu {
                        Button {
                            viewModel.selectCoverFromCamera()
                        } label: {
                            Label("Take Photo", systemImage: "camera")
                        }

                        Button {
                            viewModel.selectCoverFromLibrary()
                        } label: {
                            Label("Choose from Library", systemImage: "photo")
                        }

                        Divider()

                        Button(role: .destructive) {
                            viewModel.removeCoverImage()
                        } label: {
                            Label("Remove Cover", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                    }
                    .padding(AppTheme.Spacing.md)
                }

                Spacer()
            } else {
                // Show add cover button
                VStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 32))
                        .foregroundColor(AppTheme.Colors.primary.opacity(0.5))

                    Text("ADD COVER")
                        .font(AppTheme.Typography.monoSmall())
                        .tracking(1)
                        .foregroundColor(AppTheme.Colors.primary.opacity(0.6))

                    HStack(spacing: AppTheme.Spacing.md) {
                        Button {
                            viewModel.selectCoverFromCamera()
                        } label: {
                            HStack(spacing: AppTheme.Spacing.xxxs) {
                                Image(systemName: "camera")
                                    .font(.system(size: 12))
                                Text("Camera")
                                    .font(AppTheme.Typography.monoCaption())
                            }
                            .foregroundColor(AppTheme.Colors.primary)
                            .padding(.horizontal, AppTheme.Spacing.sm)
                            .padding(.vertical, AppTheme.Spacing.xxs)
                            .background(AppTheme.Colors.primary.opacity(0.15))
                            .cornerRadius(AppTheme.CornerRadius.pill)
                        }

                        Button {
                            viewModel.selectCoverFromLibrary()
                        } label: {
                            HStack(spacing: AppTheme.Spacing.xxxs) {
                                Image(systemName: "photo")
                                    .font(.system(size: 12))
                                Text("Library")
                                    .font(AppTheme.Typography.monoCaption())
                            }
                            .foregroundColor(AppTheme.Colors.primary)
                            .padding(.horizontal, AppTheme.Spacing.sm)
                            .padding(.vertical, AppTheme.Spacing.xxs)
                            .background(AppTheme.Colors.primary.opacity(0.15))
                            .cornerRadius(AppTheme.CornerRadius.pill)
                        }
                    }
                    .padding(.top, AppTheme.Spacing.xxs)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("No Cover") {
    EditorCoverSection(viewModel: JournalEditorViewModel(trip: .previewDraft, toastManager: ToastManager()))
}
