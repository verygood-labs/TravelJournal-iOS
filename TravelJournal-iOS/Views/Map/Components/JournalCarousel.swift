import CoreLocation
import SwiftUI

struct JournalCarousel: View {
    let location: JournalLocation
    let journals: [JournalPreview]
    let isLoading: Bool
    let onJournalTap: (JournalPreview) -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header with location name and dismiss
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text(location.name)
                        .font(AppTheme.Typography.serifSmall())
                        .foregroundColor(AppTheme.Colors.passportTextPrimary)

                    Text(location.countryName)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(AppTheme.Colors.passportTextSecondary)
                }

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.Colors.passportTextSecondary)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.top, AppTheme.Spacing.sm)
            .padding(.bottom, AppTheme.Spacing.xs)

            if isLoading {
                loadingView
            } else if journals.isEmpty {
                emptyView
            } else {
                carouselContent
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 4)
        )
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.top, AppTheme.Spacing.sm)
    }

    // MARK: - Loading View

    private var loadingView: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            ForEach(0..<2, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppTheme.Colors.passportPageDark.opacity(0.3))
                    .frame(width: 140, height: 100)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.bottom, AppTheme.Spacing.sm)
    }

    // MARK: - Empty View

    private var emptyView: some View {
        Text("No journals at this location")
            .font(AppTheme.Typography.monoSmall())
            .foregroundColor(AppTheme.Colors.passportTextSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .padding(.bottom, AppTheme.Spacing.xs)
    }

    // MARK: - Carousel Content

    private var carouselContent: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(journals) { journal in
                        CarouselCard(journal: journal)
                            .onTapGesture {
                                onJournalTap(journal)
                            }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.sm)
            }

            // Page indicator dots
            if journals.count > 1 {
                HStack(spacing: 4) {
                    ForEach(0..<min(journals.count, 5), id: \.self) { _ in
                        Circle()
                            .fill(AppTheme.Colors.passportTextSecondary.opacity(0.4))
                            .frame(width: 5, height: 5)
                    }
                }
                .padding(.bottom, AppTheme.Spacing.xs)
            }
        }
    }
}

// MARK: - Carousel Card

private struct CarouselCard: View {
    let journal: JournalPreview

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Cover image
            ZStack {
                if let coverUrl = journal.coverImageUrl {
                    AsyncImage(url: URL(string: coverUrl)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            imagePlaceholder
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(AppTheme.Colors.passportPageDark.opacity(0.2))
                        @unknown default:
                            imagePlaceholder
                        }
                    }
                } else {
                    imagePlaceholder
                }
            }
            .frame(width: 140, height: 70)
            .clipped()

            // Journal info
            VStack(alignment: .leading, spacing: 4) {
                Text(journal.title)
                    .font(AppTheme.Typography.monoSmall())
                    .foregroundColor(AppTheme.Colors.passportTextPrimary)
                    .lineLimit(1)

                // Author
                HStack(spacing: 3) {
                    Circle()
                        .fill(AppTheme.Colors.primary.opacity(0.3))
                        .frame(width: 12, height: 12)
                        .overlay(
                            Text(String(journal.authorName.prefix(1)).uppercased())
                                .font(.system(size: 6, weight: .bold))
                                .foregroundColor(AppTheme.Colors.primary)
                        )

                    Text(journal.displayUsername)
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(AppTheme.Colors.passportTextSecondary)
                        .lineLimit(1)
                }

                // View and Save counts
                HStack(spacing: AppTheme.Spacing.sm) {
                    HStack(spacing: 2) {
                        Image(systemName: "eye")
                            .font(.system(size: 9))
                        Text("\(journal.viewCount)")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                    }
                    .foregroundColor(AppTheme.Colors.passportTextSecondary)

                    HStack(spacing: 2) {
                        Image(systemName: "bookmark")
                            .font(.system(size: 9))
                        Text("\(journal.saveCount)")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                    }
                    .foregroundColor(AppTheme.Colors.passportTextSecondary)
                }
            }
            .padding(AppTheme.Spacing.xs)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.Colors.passportPageLight)
        }
        .frame(width: 140)
        .background(AppTheme.Colors.passportPageLight)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.Colors.passportPageGrid, lineWidth: 1)
        )
    }

    private var imagePlaceholder: some View {
        ZStack {
            AppTheme.Colors.passportPageDark
            Image(systemName: "photo")
                .font(.system(size: 20))
                .foregroundColor(AppTheme.Colors.passportTextSecondary.opacity(0.5))
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3)
            .ignoresSafeArea()

        VStack {
            JournalCarousel(
                location: JournalLocation(
                    id: UUID(),
                    name: "Tokyo",
                    countryName: "Japan",
                    countryCode: "JP",
                    coordinate: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503),
                    journalCount: 3
                ),
                journals: [
                    JournalPreview(
                        id: UUID(),
                        tripId: UUID(),
                        title: "Cherry Blossoms in Ueno",
                        coverImageUrl: "https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=400",
                        authorId: UUID(),
                        authorName: "Sarah",
                        authorUsername: "sarahtravels",
                        authorAvatarUrl: nil,
                        viewCount: 1243,
                        saveCount: 89
                    ),
                    JournalPreview(
                        id: UUID(),
                        tripId: UUID(),
                        title: "Shibuya Nights",
                        coverImageUrl: "https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=400",
                        authorId: UUID(),
                        authorName: "Mike",
                        authorUsername: "mikeadventures",
                        authorAvatarUrl: nil,
                        viewCount: 856,
                        saveCount: 42
                    ),
                    JournalPreview(
                        id: UUID(),
                        tripId: UUID(),
                        title: "Senso-ji Temple",
                        coverImageUrl: "https://images.unsplash.com/photo-1545569341-9eb8b30979d9?w=400",
                        authorId: UUID(),
                        authorName: "Emma",
                        authorUsername: "emmawanders",
                        authorAvatarUrl: nil,
                        viewCount: 2105,
                        saveCount: 156
                    )
                ],
                isLoading: false,
                onJournalTap: { _ in },
                onDismiss: {}
            )

            Spacer()
        }
    }
}
