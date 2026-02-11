//
//  JournalPreviewCard.swift
//  TravelJournal-iOS
//
//  Compact journal preview card for the location bottom sheet
//

import SwiftUI

struct JournalPreviewCard: View {
    let journal: JournalPreview
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                // Cover image
                coverImage

                // Title
                Text(journal.title)
                    .font(AppTheme.Typography.monoMedium())
                    .foregroundColor(AppTheme.Colors.passportTextPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                // Author
                Text(journal.displayUsername)
                    .font(AppTheme.Typography.monoSmall())
                    .foregroundColor(AppTheme.Colors.primary)
            }
            .frame(width: 140)
            .padding(AppTheme.Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .fill(Color.white.opacity(0.6))
                    .shadow(color: Color.black.opacity(0.08), radius: 4, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder
    private var coverImage: some View {
        if let urlString = journal.coverImageUrl, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 116, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small))
                default:
                    placeholderImage
                }
            }
        } else {
            placeholderImage
        }
    }

    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
            .fill(AppTheme.Colors.backgroundDark.opacity(0.1))
            .frame(width: 116, height: 80)
            .overlay {
                Image(systemName: "book.pages")
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.Colors.primary.opacity(0.6))
            }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        LinearGradient(
            colors: [
                AppTheme.Colors.passportPageLight,
                AppTheme.Colors.passportPageDark
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        HStack(spacing: 16) {
            JournalPreviewCard(
                journal: JournalPreview(
                    id: UUID(),
                    tripId: UUID(),
                    title: "A Week in the City of Lights",
                    coverImageUrl: nil,
                    authorId: UUID(),
                    authorName: "Sarah Chen",
                    authorUsername: "sarahc",
                    authorAvatarUrl: nil,
                    viewCount: 1243,
                    saveCount: 89
                )
            ) {
                print("Tapped journal")
            }

            JournalPreviewCard(
                journal: JournalPreview(
                    id: UUID(),
                    tripId: UUID(),
                    title: "Paris Trip",
                    coverImageUrl: nil,
                    authorId: UUID(),
                    authorName: "John Doe",
                    authorUsername: "johnd",
                    authorAvatarUrl: nil,
                    viewCount: 856,
                    saveCount: 42
                )
            ) {
                print("Tapped journal")
            }
        }
        .padding()
    }
}
