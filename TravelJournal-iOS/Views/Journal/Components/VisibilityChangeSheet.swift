//
//  VisibilityChangeSheet.swift
//  TravelJournal-iOS
//
//  Created on 2/9/26.
//

import SwiftUI

struct VisibilityChangeSheet: View {
    let trip: TripSummary
    let onVisibilityChanged: (TripStatus) -> Void
    let onCancel: () -> Void

    @State private var selectedStatus: TripStatus

    private let visibilityOptions: [TripStatus] = [.private, .unlisted, .public]

    init(trip: TripSummary, onVisibilityChanged: @escaping (TripStatus) -> Void, onCancel: @escaping () -> Void) {
        self.trip = trip
        self.onVisibilityChanged = onVisibilityChanged
        self.onCancel = onCancel
        // Initialize with current status, defaulting to private if draft
        _selectedStatus = State(initialValue: trip.status == .draft ? .private : trip.status)
    }

    var body: some View {
        NavigationView {
            PassportPageBackgroundView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Header
                    VStack(spacing: AppTheme.Spacing.xs) {
                        Text("Change Visibility")
                            .font(AppTheme.Typography.serifMedium())
                            .foregroundColor(AppTheme.Colors.passportTextPrimary)

                        Text("Select who can view \"\(trip.title)\"")
                            .font(AppTheme.Typography.monoSmall())
                            .foregroundColor(AppTheme.Colors.passportTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, AppTheme.Spacing.lg)

                    // Visibility options
                    VStack(spacing: AppTheme.Spacing.sm) {
                        ForEach(visibilityOptions, id: \.self) { status in
                            VisibilityOptionButton(
                                status: status,
                                isSelected: selectedStatus == status,
                                onSelect: { selectedStatus = status }
                            )
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)

                    Spacer()

                    // Action buttons
                    VStack(spacing: AppTheme.Spacing.sm) {
                        Button {
                            onVisibilityChanged(selectedStatus)
                        } label: {
                            Text("UPDATE VISIBILITY")
                                .font(AppTheme.Typography.button())
                                .tracking(1)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(selectedStatus == trip.status)

                        Button {
                            onCancel()
                        } label: {
                            Text("Cancel")
                                .font(AppTheme.Typography.monoSmall())
                                .foregroundColor(AppTheme.Colors.passportTextSecondary)
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.bottom, AppTheme.Spacing.xl)
                }
            }
            .navigationBarHidden(true)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Visibility Option Button

private struct VisibilityOptionButton: View {
    let status: TripStatus
    let isSelected: Bool
    let onSelect: () -> Void

    private var icon: String {
        switch status {
        case .private:
            return "lock.fill"
        case .unlisted:
            return "link"
        case .public:
            return "globe"
        default:
            return "questionmark"
        }
    }

    private var title: String {
        status.rawValue
    }

    private var description: String {
        switch status {
        case .private:
            return "Only you can view this journal"
        case .unlisted:
            return "Anyone with the link can view"
        case .public:
            return "Visible to everyone"
        default:
            return ""
        }
    }

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: AppTheme.Spacing.md) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.passportTextSecondary)
                    .frame(width: 32)

                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppTheme.Typography.monoMedium())
                        .foregroundColor(AppTheme.Colors.passportTextPrimary)

                    Text(description)
                        .font(AppTheme.Typography.monoCaption())
                        .foregroundColor(AppTheme.Colors.passportTextSecondary)
                }

                Spacer()

                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(AppTheme.Colors.primary)
                } else {
                    Circle()
                        .stroke(AppTheme.Colors.passportInputBorder, lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                }
            }
            .padding(AppTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .fill(isSelected ? AppTheme.Colors.primary.opacity(0.1) : AppTheme.Colors.passportPageLight)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.passportInputBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    VisibilityChangeSheet(
        trip: .preview(),
        onVisibilityChanged: { status in print("Changed to: \(status)") },
        onCancel: { print("Cancelled") }
    )
}
