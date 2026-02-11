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
                VStack(alignment: .leading, spacing: 2) {
                    Text(location.name)
                        .font(AppTheme.Typography.serifSmall())
                        .foregroundColor(AppTheme.Colors.passportTextPrimary)

                    Text(location.countryName)
                        .font(AppTheme.Typography.monoSmall())
                        .foregroundColor(AppTheme.Colors.passportTextSecondary)
                }

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppTheme.Colors.passportTextSecondary)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.top, AppTheme.Spacing.md)
            .padding(.bottom, AppTheme.Spacing.sm)

            if isLoading {
                loadingView
            } else if journals.isEmpty {
                emptyView
            } else {
                carouselContent
            }
        }
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
        HStack(spacing: AppTheme.Spacing.md) {
            ForEach(0..<2, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.Colors.passportPageDark.opacity(0.3))
                    .frame(width: 200, height: 120)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.bottom, AppTheme.Spacing.md)
    }

    // MARK: - Empty View

    private var emptyView: some View {
        Text("No journals at this location")
            .font(AppTheme.Typography.monoMedium())
            .foregroundColor(AppTheme.Colors.passportTextSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.lg)
            .padding(.bottom, AppTheme.Spacing.sm)
    }

    // MARK: - Carousel Content

    private var carouselContent: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.md) {
                    ForEach(journals) { journal in
                        CarouselCard(journal: journal)
                            .onTapGesture {
                                onJournalTap(journal)
                            }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.md)
            }
            .scrollClipDisabled()

            // Page indicator dots
            if journals.count > 1 {
                HStack(spacing: 6) {
                    ForEach(0..<min(journals.count, 5), id: \.self) { _ in
                        Circle()
                            .fill(AppTheme.Colors.passportTextSecondary.opacity(0.4))
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.bottom, AppTheme.Spacing.sm)
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
            .frame(width: 200, height: 100)
            .clipped()

            // Journal info
            VStack(alignment: .leading, spacing: 4) {
                Text(journal.title)
                    .font(AppTheme.Typography.monoMedium())
                    .foregroundColor(AppTheme.Colors.passportTextPrimary)
                    .lineLimit(1)

                // Author
                HStack(spacing: 4) {
                    Circle()
                        .fill(AppTheme.Colors.primary.opacity(0.3))
                        .frame(width: 16, height: 16)
                        .overlay(
                            Text(String(journal.authorName.prefix(1)).uppercased())
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(AppTheme.Colors.primary)
                        )

                    Text(journal.displayUsername)
                        .font(AppTheme.Typography.monoSmall())
                        .foregroundColor(AppTheme.Colors.passportTextSecondary)
                        .lineLimit(1)
                }
            }
            .padding(AppTheme.Spacing.sm)
            .background(AppTheme.Colors.passportPageDark.opacity(0.3))
        }
        .frame(width: 200)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.Colors.passportPageGrid, lineWidth: 1)
        )
    }

    private var imagePlaceholder: some View {
        ZStack {
            AppTheme.Colors.passportPageDark.opacity(0.2)
            Image(systemName: "photo")
                .font(.system(size: 24))
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
                        coverImageUrl: nil,
                        authorId: UUID(),
                        authorName: "Sarah",
                        authorUsername: "sarahtravels",
                        authorAvatarUrl: nil
                    ),
                    JournalPreview(
                        id: UUID(),
                        tripId: UUID(),
                        title: "Shibuya Nights",
                        coverImageUrl: nil,
                        authorId: UUID(),
                        authorName: "Mike",
                        authorUsername: "mikeadventures",
                        authorAvatarUrl: nil
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
