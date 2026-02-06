//
//  ThemedPhotoCard.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 2/5/26.
//

import SwiftUI

// MARK: - Themed Photo Card

/// A themed card for displaying photo blocks in preview mode.
struct ThemedPhotoCard: View {
    let block: EditorBlock
    @Environment(\.journalTheme) private var theme

    // MARK: - Computed Properties

    private var photoStyle: PhotoBlockStyle {
        theme.blocks.photo
    }

    private var data: EditorBlockData {
        block.data
    }

    private var rotation: Double {
        Double(data.rotation ?? 0)
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            // Photo
            photoContent
                .rotationEffect(.degrees(rotation))

            // Caption
            if let caption = data.caption, !caption.isEmpty {
                Text(caption)
                    .font(theme.typography.bodyFont(size: 13))
                    .foregroundColor(theme.colors.textSecondaryColor)
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Photo Content

    @ViewBuilder
    private var photoContent: some View {
        if let imageUrl = data.imageUrl, !imageUrl.isEmpty {
            AsyncImage(url: URL(string: imageUrl)) { phase in
                switch phase {
                case .empty:
                    photoPlaceholder
                        .overlay(
                            ProgressView()
                                .tint(theme.colors.textMutedColor)
                        )
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .cornerRadius(photoStyle.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: photoStyle.cornerRadius)
                                .stroke(photoStyle.borderSwiftUIColor, lineWidth: 1)
                        )
                        .shadow(
                            color: theme.style.cardShadow ? Color.black.opacity(0.1) : .clear,
                            radius: theme.style.cardShadow ? 6 : 0,
                            x: 0,
                            y: theme.style.cardShadow ? 3 : 0
                        )
                case .failure:
                    photoPlaceholder
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.title2)
                                Text("Failed to load")
                                    .font(theme.typography.labelFont(size: 12))
                            }
                            .foregroundColor(theme.colors.textMutedColor)
                        )
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            photoPlaceholder
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                        Text("No photo")
                            .font(theme.typography.labelFont(size: 12))
                    }
                    .foregroundColor(theme.colors.textMutedColor)
                )
        }
    }

    private var photoPlaceholder: some View {
        RoundedRectangle(cornerRadius: photoStyle.cornerRadius)
            .fill(theme.colors.borderColor.opacity(0.2))
            .frame(height: 200)
            .overlay(
                RoundedRectangle(cornerRadius: photoStyle.cornerRadius)
                    .stroke(photoStyle.borderSwiftUIColor, lineWidth: 1)
            )
    }
}

// MARK: - Preview

#Preview("Default Theme") {
    ScrollView {
        VStack(spacing: 24) {
            ThemedPhotoCard(block: .samplePhoto)
            ThemedPhotoCard(block: .samplePhotoRotated)
            ThemedPhotoCard(block: .samplePhotoNoCaption)
        }
        .padding()
    }
    .background(Color(hex: "#f5f5f5"))
    .journalTheme(.default)
}

#Preview("Passport Theme") {
    ScrollView {
        VStack(spacing: 24) {
            ThemedPhotoCard(block: .samplePhoto)
            ThemedPhotoCard(block: .samplePhotoRotated)
        }
        .padding()
    }
    .background(Color(hex: "#f5f1e8"))
    .journalTheme(.passport)
}

#Preview("Retro Theme") {
    ScrollView {
        VStack(spacing: 24) {
            ThemedPhotoCard(block: .samplePhoto)
            ThemedPhotoCard(block: .samplePhotoRotated)
        }
        .padding()
    }
    .background(Color(hex: "#C0C0C0"))
    .journalTheme(.retro)
}

// MARK: - Sample Data

private extension EditorBlock {
    static let samplePhoto = EditorBlock.newPhoto(
        order: 0,
        imageUrl: "https://images.unsplash.com/photo-1518509562904-e7ef99cdcc86?w=800",
        caption: "Sunset over Manila Bay"
    )

    static let samplePhotoRotated = EditorBlock.newPhoto(
        order: 1,
        imageUrl: "https://images.unsplash.com/photo-1552733407-5d5c46c3bb3b?w=800",
        caption: "My travel buddy enjoying the view",
        rotation: 3
    )

    static let samplePhotoNoCaption = EditorBlock.newPhoto(
        order: 2,
        imageUrl: "https://images.unsplash.com/photo-1506929562872-bb421503ef21?w=800"
    )
}
