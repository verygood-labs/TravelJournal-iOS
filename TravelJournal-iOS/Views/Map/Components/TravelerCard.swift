//
//  TravelerCard.swift
//  TravelJournal-iOS
//
//  Card view for displaying a traveler in search results
//

import SwiftUI

struct TravelerCard: View {
    let traveler: Traveler
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppTheme.Spacing.sm) {
                // Profile photo
                profilePhoto

                // Info
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xxxs) {
                    // Name
                    Text(traveler.name)
                        .font(AppTheme.Typography.monoMedium())
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    // Username
                    Text(traveler.displayUsername)
                        .font(AppTheme.Typography.monoSmall())
                        .foregroundColor(AppTheme.Colors.textSecondary)

                    // Stats
                    Text(traveler.statsText)
                        .font(AppTheme.Typography.monoSmall())
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            .padding(AppTheme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .fill(AppTheme.Colors.cardBackground)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder
    private var profilePhoto: some View {
        if let urlString = traveler.profilePictureUrl, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 56, height: 56)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(AppTheme.Colors.primary, lineWidth: 2)
                        )
                default:
                    placeholderAvatar
                }
            }
        } else {
            placeholderAvatar
        }
    }

    private var placeholderAvatar: some View {
        Circle()
            .fill(AppTheme.Colors.primaryOverlay)
            .frame(width: 56, height: 56)
            .overlay(
                Text(traveler.name.prefix(1).uppercased())
                    .font(AppTheme.Typography.serifSmall())
                    .foregroundColor(AppTheme.Colors.primary)
            )
            .overlay(
                Circle()
                    .stroke(AppTheme.Colors.primary, lineWidth: 2)
            )
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()

        VStack(spacing: 12) {
            TravelerCard(
                traveler: Traveler(
                    id: UUID(),
                    name: "John Apale",
                    username: "john",
                    profilePictureUrl: nil,
                    countriesVisited: 42,
                    journalsCount: 15,
                    lastActivityAt: Date()
                )
            ) {
                print("Tapped")
            }

            TravelerCard(
                traveler: Traveler(
                    id: UUID(),
                    name: "Sarah Chen",
                    username: "sarahc",
                    profilePictureUrl: nil,
                    countriesVisited: 38,
                    journalsCount: 22,
                    lastActivityAt: nil
                )
            ) {
                print("Tapped")
            }
        }
        .padding()
    }
}
