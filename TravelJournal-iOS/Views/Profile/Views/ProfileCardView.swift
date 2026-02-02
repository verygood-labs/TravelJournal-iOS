//
//  ProfileCardView.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/24/26.
//

import SwiftUI

// MARK: - Profile Card View

/// Passport-style profile card showing user photo, name, and username
/// Tappable to navigate to edit profile screen
struct ProfileCardView: View {
    let name: String
    let username: String
    let profileImageUrl: URL?
    var isLoading: Bool = false

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Profile Photo
            profilePhotoView

            // Profile Info
            profileInfoView

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.Colors.passportTextMuted)
        }
        .padding(AppTheme.Spacing.md)
        .background(
            // Passport page background
            ZStack {
                LinearGradient(
                    colors: [
                        AppTheme.Colors.passportPageLight,
                        AppTheme.Colors.passportPageDark,
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Subtle grid pattern
                PassportCardGridPattern()
            }
        )
        .cornerRadius(AppTheme.CornerRadius.large)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                .stroke(AppTheme.Colors.primary.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Profile Photo

    private var profilePhotoView: some View {
        ZStack {
            if isLoading {
                // Loading placeholder
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .fill(AppTheme.Colors.passportInputBackground)
                    .frame(width: 72, height: 72)
                    .overlay(
                        ProgressView()
                    )
            } else if let url = profileImageUrl {
                // Actual profile image
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholderImage
                            .overlay(ProgressView())
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 72, height: 72)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
                    case .failure:
                        placeholderImage
                    @unknown default:
                        placeholderImage
                    }
                }
            } else {
                // Default placeholder
                placeholderImage
            }

            // Edit badge
            editBadge
        }
        .frame(width: 72, height: 72)
    }

    private var placeholderImage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .fill(AppTheme.Colors.cardBackground)
                .frame(width: 72, height: 72)

            Image(systemName: "person.fill")
                .font(.system(size: 28))
                .foregroundColor(AppTheme.Colors.textMuted)
        }
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .stroke(AppTheme.Colors.primary, lineWidth: 2)
        )
    }

    private var editBadge: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ZStack {
                    Circle()
                        .fill(AppTheme.Colors.primary)
                        .frame(width: 22, height: 22)

                    Image(systemName: "pencil")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(AppTheme.Colors.passportPageLight)
                }
                .offset(x: 4, y: 4)
            }
        }
    }

    // MARK: - Profile Info

    private var profileInfoView: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            // Full Name
            VStack(alignment: .leading, spacing: 2) {
                Text("FULL NAME")
                    .font(AppTheme.Typography.monoTiny())
                    .tracking(1)
                    .foregroundColor(AppTheme.Colors.passportTextMuted)

                if isLoading {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.Colors.passportInputBackground)
                        .frame(width: 120, height: 20)
                } else {
                    Text(name)
                        .font(AppTheme.Typography.serifSmall())
                        .foregroundColor(AppTheme.Colors.passportTextPrimary)
                        .lineLimit(1)
                }
            }

            // Username
            VStack(alignment: .leading, spacing: 2) {
                Text("HANDLE")
                    .font(AppTheme.Typography.monoTiny())
                    .tracking(1)
                    .foregroundColor(AppTheme.Colors.passportTextMuted)

                if isLoading {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.Colors.passportInputBackground)
                        .frame(width: 80, height: 16)
                } else {
                    Text("@\(username)")
                        .font(AppTheme.Typography.monoSmall())
                        .foregroundColor(AppTheme.Colors.passportTextPrimary)
                        .lineLimit(1)
                }
            }
        }
    }
}

// MARK: - Passport Card Grid Pattern

struct PassportCardGridPattern: View {
    var body: some View {
        Canvas(opaque: false, colorMode: .linear, rendersAsynchronously: true) { context, size in
            let gridSpacing: CGFloat = 40
            let lineWidth: CGFloat = 0.5

            // Draw vertical lines
            for x in stride(from: 0, to: size.width, by: gridSpacing) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(
                    path,
                    with: .color(AppTheme.Colors.passportPageGrid.opacity(0.2)),
                    lineWidth: lineWidth
                )
            }

            // Draw horizontal lines
            for y in stride(from: 0, to: size.height, by: gridSpacing) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(
                    path,
                    with: .color(AppTheme.Colors.passportPageGrid.opacity(0.2)),
                    lineWidth: lineWidth
                )
            }
        }
        .drawingGroup()
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()

        VStack(spacing: 20) {
            // With data
            ProfileCardView(
                name: "John Explorer",
                username: "wanderlust",
                profileImageUrl: nil,
                isLoading: false
            )

            // Loading state
            ProfileCardView(
                name: "",
                username: "",
                profileImageUrl: nil,
                isLoading: true
            )
        }
        .padding()
    }
}
