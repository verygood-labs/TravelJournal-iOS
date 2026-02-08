//
//  PublishSettingsSheet.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 2/8/26.
//

import SwiftUI

// MARK: - Visibility Option

/// Visibility options available when publishing a journal.
enum VisibilityOption: String, CaseIterable, Identifiable {
    case `public` = "Public"
    case unlisted = "Unlisted"
    case `private` = "Private"

    var id: String { rawValue }

    var title: String { rawValue }

    var description: String {
        switch self {
        case .public:
            return "Visible to everyone and appears in public feeds"
        case .unlisted:
            return "Only people with the link can view"
        case .private:
            return "Only you can see this journal"
        }
    }

    var icon: String {
        switch self {
        case .public:
            return "globe"
        case .unlisted:
            return "link"
        case .private:
            return "lock"
        }
    }

    var tripStatus: TripStatus {
        switch self {
        case .public:
            return .public
        case .unlisted:
            return .unlisted
        case .private:
            return .private
        }
    }
}

// MARK: - Publish Settings Sheet

/// Sheet presented when publishing a journal, allowing users to set visibility.
struct PublishSettingsSheet: View {
    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss

    @Binding var selectedVisibility: VisibilityOption
    let isPublishing: Bool
    let onPublish: () -> Void

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                headerSection

                // Visibility options
                visibilityOptions

                Spacer()

                // Publish button
                publishButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 32)
            .background(AppTheme.Colors.backgroundDark)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(AppTheme.Typography.monoMedium())
                    .foregroundColor(AppTheme.Colors.textSecondary)
                }

                ToolbarItem(placement: .principal) {
                    Text("Publish Journal")
                        .font(AppTheme.Typography.monoMedium())
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "paperplane.fill")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.Colors.primary)

            Text("Choose who can see your journal")
                .font(AppTheme.Typography.monoMedium())
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Visibility Options

    private var visibilityOptions: some View {
        VStack(spacing: 12) {
            ForEach(VisibilityOption.allCases) { option in
                VisibilityOptionRow(
                    option: option,
                    isSelected: selectedVisibility == option,
                    onSelect: { selectedVisibility = option }
                )
            }
        }
    }

    // MARK: - Publish Button

    private var publishButton: some View {
        Button {
            onPublish()
        } label: {
            HStack(spacing: 8) {
                if isPublishing {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 14))
                }

                Text(isPublishing ? "Publishing..." : "Publish")
                    .font(AppTheme.Typography.monoMedium())
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppTheme.Colors.primary)
            .cornerRadius(12)
        }
        .disabled(isPublishing)
        .opacity(isPublishing ? 0.7 : 1)
    }
}

// MARK: - Visibility Option Row

private struct VisibilityOptionRow: View {
    let option: VisibilityOption
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: option.icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.textSecondary)
                    .frame(width: 32)

                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.title)
                        .font(AppTheme.Typography.monoMedium())
                        .fontWeight(.medium)
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    Text(option.description)
                        .font(AppTheme.Typography.monoSmall())
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }

                Spacer()

                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.divider)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? AppTheme.Colors.primary.opacity(0.1) : AppTheme.Colors.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.divider, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Publish Settings Sheet") {
    PublishSettingsSheet(
        selectedVisibility: .constant(.public),
        isPublishing: false,
        onPublish: {}
    )
}

#Preview("Publishing State") {
    PublishSettingsSheet(
        selectedVisibility: .constant(.public),
        isPublishing: true,
        onPublish: {}
    )
}
