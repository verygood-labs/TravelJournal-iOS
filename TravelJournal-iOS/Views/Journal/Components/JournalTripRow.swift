//
//  JournalTripRow.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/21/26.
//

import Foundation
import SwiftUI

struct JournalTripRow: View {
    let trip: TripSummary
    var onView: () -> Void = {}
    var onEdit: () -> Void = {}
    var onChangeVisibility: () -> Void = {}
    var onDelete: () -> Void = {}

    private var isDraft: Bool {
        trip.status == .draft
    }

    var body: some View {
        Button {
            // Tap behavior: drafts open editor, published opens view
            if isDraft {
                onEdit()
            } else {
                onView()
            }
        } label: {
            rowContent
        }
        .buttonStyle(.plain)
        .tripContextMenu(
            trip: trip,
            onView: onView,
            onEdit: onEdit,
            onChangeVisibility: onChangeVisibility,
            onDelete: onDelete
        )
    }

    // MARK: - Row Content

    private var rowContent: some View {
        HStack(alignment: .center, spacing: AppTheme.Spacing.xxs) {
            // Left: Title, date, and stats
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxxs) {
                // Title
                Text(trip.title)
                    .font(AppTheme.Typography.monoMedium())
                    .foregroundColor(AppTheme.Colors.passportTextPrimary)
                    .lineLimit(1)

                // Date range
                HStack(spacing: AppTheme.Spacing.xxxs) {
                    Image(systemName: "calendar")
                        .font(.system(size: 10))
                    Text(trip.dateRange)
                        .font(AppTheme.Typography.monoCaption())
                }
                .foregroundColor(AppTheme.Colors.passportTextMuted)

                // Stats row: locations, notes, last updated
                HStack(spacing: AppTheme.Spacing.sm) {
                    // Locations
                    statItem(icon: "mappin", value: "\(trip.stopCount)")

                    // Notes/Entries
                    statItem(icon: "doc.text", value: "0")

                    // Last updated
                    Text("Updated \(formatRelativeDate(trip.updatedAt ?? trip.createdAt))")
                        .font(AppTheme.Typography.monoCaption())
                        .foregroundColor(AppTheme.Colors.passportTextMuted)
                }
            }

            Spacer()

            // Right: Status badge
            statusBadge
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .fill(AppTheme.Colors.passportPageLight)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .stroke(AppTheme.Colors.passportInputBorder, lineWidth: 1)
        )
    }

    // MARK: - Stat Item

    private func statItem(icon: String, value: String) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(AppTheme.Colors.primary)

            Text(value)
                .font(AppTheme.Typography.monoCaption())
                .foregroundColor(AppTheme.Colors.passportTextSecondary)
        }
    }

    // MARK: - Format Relative Date

    private func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    // MARK: - Status Badge

    private var statusBadge: some View {
        HStack(spacing: 3) {
            Circle()
                .fill(trip.status.color)
                .frame(width: 5, height: 5)

            Text(trip.status.rawValue.uppercased())
                .font(AppTheme.Typography.monoCaption())
                .tracking(0.5)
        }
        .foregroundColor(trip.status.color)
        .padding(.horizontal, AppTheme.Spacing.xxs)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(trip.status.color.opacity(0.1))
        )
    }
}

// MARK: - Preview

#Preview("Single Row") {
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()

        JournalTripRow(
            trip: .preview(),
            onView: { print("View tapped") },
            onEdit: { print("Edit tapped") }
        )
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
}

#Preview("Multiple Rows") {
    let trips: [TripSummary] = [
        .preview(),
        .previewDraft,
        .preview(title: "Road Trip Across America", status: .private)
    ]

    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()

        VStack(spacing: AppTheme.Spacing.xs) {
            ForEach(trips) { trip in
                JournalTripRow(
                    trip: trip,
                    onView: { print("View: \(trip.title)") },
                    onEdit: { print("Edit: \(trip.title)") }
                )
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
}
