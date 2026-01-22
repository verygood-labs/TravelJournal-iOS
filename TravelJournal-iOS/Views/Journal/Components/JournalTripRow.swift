//
//  JournalTripRow.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/21/26.
//

import Foundation
import SwiftUI

struct JournalTripRow: View {
    let trip: Trip
    var onView: () -> Void = {}
    var onEdit: () -> Void = {}
    var onDelete: () -> Void = {}
    
    var body: some View {
        Button {
            onView()
        } label: {
            rowContent
        }
        .buttonStyle(.plain)
        .tripContextMenu(
            onView: onView,
            onEdit: onEdit,
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
                    statItem(icon: "mappin", value: "\(trip.stops?.count ?? 0)")
                    
                    // Notes/Entries
                    statItem(icon: "doc.text", value: "0")
                    
                    // Last updated
                    Text("Updated \(formatRelativeDate(trip.updatedAt))")
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
                .fill(statusColor)
                .frame(width: 5, height: 5)
            
            Text(trip.status.rawValue.uppercased())
                .font(AppTheme.Typography.monoCaption())
                .tracking(0.5)
        }
        .foregroundColor(statusColor)
        .padding(.horizontal, AppTheme.Spacing.xxs)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(statusColor.opacity(0.1))
        )
    }
    
    private var statusColor: Color {
        switch trip.status {
        case .draft:
            return .orange
        case .private:
            return .blue
        case .public:
            return .green
        }
    }
}

// MARK: - Preview
#Preview("Single Row") {
    let sampleTrip = Trip(
        id: UUID(),
        title: "Paris, France",
        description: "An amazing week exploring the city of lights.",
        coverImageUrl: nil,
        status: .public,
        startDate: Date().addingTimeInterval(-86400 * 30),
        endDate: Date().addingTimeInterval(-86400 * 23),
        createdAt: Date().addingTimeInterval(-86400 * 30),
        updatedAt: Date().addingTimeInterval(-86400 * 2),
        stops: nil
    )
    
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()
        
        JournalTripRow(
            trip: sampleTrip,
            onView: { print("View tapped") },
            onEdit: { print("Edit tapped") }
        )
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
}

#Preview("Multiple Rows") {
    let trips = [
        Trip(
            id: UUID(),
            title: "Paris, France",
            description: nil,
            coverImageUrl: nil,
            status: .public,
            startDate: Date().addingTimeInterval(-86400 * 30),
            endDate: Date().addingTimeInterval(-86400 * 23),
            createdAt: Date(),
            updatedAt: Date(),
            stops: nil
        ),
        Trip(
            id: UUID(),
            title: "Tokyo, Japan",
            description: nil,
            coverImageUrl: nil,
            status: .draft,
            startDate: Date(),
            endDate: Date(),
            createdAt: Date(),
            updatedAt: Date(),
            stops: nil
        ),
        Trip(
            id: UUID(),
            title: "Road Trip Across America",
            description: nil,
            coverImageUrl: nil,
            status: .private,
            startDate: Date().addingTimeInterval(-86400 * 60),
            endDate: Date().addingTimeInterval(-86400 * 55),
            createdAt: Date(),
            updatedAt: Date(),
            stops: nil
        )
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
