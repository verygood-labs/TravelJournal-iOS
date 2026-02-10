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
    var actionConfig: CardActionConfig?
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
        VStack(spacing: 0) {
            // Polaroid frame
            VStack(spacing: 0) {
                // Photo area
                photoContent
                    .padding(.top, 12)
                    .padding(.horizontal, 12)

                // Caption area (larger bottom space like a polaroid)
                VStack(spacing: 4) {
                    if let caption = data.caption, !caption.isEmpty {
                        Text(caption)
                            .font(theme.typography.bodyFont(size: 14))
                            .foregroundColor(photoStyle.captionTextSwiftUIColor)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                    }
                }
                .frame(minHeight: 48)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
                .background(photoStyle.captionBackgroundColor)

                // Action bar
                if let config = actionConfig {
                    ThemedCardActionBar(config: config)
                }
            }
            .background(photoStyle.frameSwiftUIColor)
            .cornerRadius(theme.style.borderRadius)
            .overlay(
                RoundedRectangle(cornerRadius: theme.style.borderRadius)
                    .stroke(
                        theme.style.borderRadius == 0 ? theme.colors.borderColor : theme.colors.borderColor.opacity(0.5),
                        lineWidth: theme.style.borderRadius == 0 ? 2 : 1
                    )
            )
            .shadow(
                color: theme.style.cardShadow ? Color.black.opacity(0.15) : .clear,
                radius: theme.style.cardShadow ? 8 : 0,
                x: 0,
                y: theme.style.cardShadow ? 4 : 0
            )
        }
        .rotationEffect(.degrees(rotation))
        .padding(.vertical, 8)
    }

    // MARK: - Photo Content

    @ViewBuilder
    private var photoContent: some View {
        if let imageUrl = data.imageUrl, !imageUrl.isEmpty {
            AsyncImage(url: APIService.shared.fullMediaURL(for: imageUrl)) { phase in
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
                        .aspectRatio(contentMode: .fill)
                        .frame(maxHeight: 280)
                        .clipped()
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
        Rectangle()
            .fill(theme.colors.borderColor.opacity(0.2))
            .frame(height: 200)
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
