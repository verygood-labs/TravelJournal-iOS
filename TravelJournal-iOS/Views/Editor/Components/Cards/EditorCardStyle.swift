//
//  EditorCardStyle.swift
//  TravelJournal-iOS
//

import SwiftUI

/// Shared styling for editor block cards
enum EditorCardStyle {
    /// Thumbnail size for editor cards
    static let thumbnailSize: CGFloat = 68

    /// Background gradient for editor cards
    static var backgroundGradient: some View {
        LinearGradient(
            colors: [
                AppTheme.Colors.passportPageLight,
                AppTheme.Colors.passportPageDark,
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// Border overlay for editor cards
    static var borderOverlay: some View {
        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
            .stroke(AppTheme.Colors.passportInputBorder, lineWidth: 1)
    }

    /// Image placeholder view
    static var imagePlaceholder: some View {
        Rectangle()
            .fill(AppTheme.Colors.passportInputBackground)
    }

    /// Block type icon view
    static func blockTypeIcon(_ systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 16))
            .foregroundColor(AppTheme.Colors.primary)
            .frame(width: 32, height: 32)
            .background(AppTheme.Colors.primary.opacity(0.1))
            .cornerRadius(AppTheme.CornerRadius.small)
    }

    /// Rating badge view
    static func ratingBadge(_ rating: Rating) -> some View {
        Text(rating.displayName)
            .font(.system(size: 16, weight: .bold, design: .monospaced))
            .foregroundColor(.white)
            .frame(width: 32, height: 32)
            .background(rating.color)
            .cornerRadius(AppTheme.CornerRadius.small)
    }
}

// MARK: - Thumbnail View

struct EditorThumbnail: View {
    let imageUrl: String
    var size: CGFloat = EditorCardStyle.thumbnailSize

    var body: some View {
        AsyncImage(url: APIService.shared.fullMediaURL(for: imageUrl)) { phase in
            switch phase {
            case .empty:
                EditorCardStyle.imagePlaceholder
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.7)
                    )
            case let .success(image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                EditorCardStyle.imagePlaceholder
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.Colors.passportTextMuted)
                    )
            @unknown default:
                EditorCardStyle.imagePlaceholder
            }
        }
        .frame(width: size, height: size)
        .clipped()
        .cornerRadius(AppTheme.CornerRadius.small)
    }
}
