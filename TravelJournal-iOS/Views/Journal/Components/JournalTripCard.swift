//
//  JournalTripCard.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/21/26.
//



import SwiftUI

struct JournalTripCard: View {
    let trip: Trip
    var onView: () -> Void = {}
    var onEdit: () -> Void = {}

    var body: some View {
        // Whole card is tappable for view
        Button {
            onView()
        } label: {
            cardContent
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Card Content
    private var cardContent: some View {
        VStack(spacing: 0) {
            // Cover Image Section with edit button
            coverImageSection
            
            // Details Section
            PassportPageBackgroundView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    // Title and Status Row
                    titleRow
                    
                    // Date Range
                    dateRangeRow
                    
                    // Description (if available)
                    if let description = trip.description, !description.isEmpty {
                        Text(description)
                            .font(AppTheme.Typography.monoCaption())
                            .foregroundColor(AppTheme.Colors.passportTextSecondary)
                            .lineLimit(2)
                    }
                    
                    // Divider
                    Rectangle()
                        .fill(AppTheme.Colors.passportInputBorder)
                        .frame(height: 1)
                        .padding(.vertical, AppTheme.Spacing.xxs)
                    
                    // Stats and Metadata Row
                    bottomRow
                }
                .padding(AppTheme.Spacing.md)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                .stroke(AppTheme.Colors.primary.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
    }
    
    // MARK: - Cover Image Section
    private var coverImageSection: some View {
        ZStack(alignment: .topTrailing) {
            // Cover image or placeholder
            if let coverUrl = trip.coverImageUrl,
               let url = APIService.shared.fullMediaURL(for: coverUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        coverPlaceholder
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 160)  // ← Changed from 120
                            .clipped()
                    case .failure:
                        coverPlaceholder
                    @unknown default:
                        coverPlaceholder
                    }
                }
            } else {
                coverPlaceholder
            }
            
            // Action buttons overlay
            actionButtons
                .padding(AppTheme.Spacing.xs)
        }
        .frame(height: 160)  // ← Changed from 120
    }
    
    private var coverPlaceholder: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppTheme.Colors.backgroundMedium,
                    AppTheme.Colors.backgroundDark
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 32, weight: .light))
                .foregroundColor(AppTheme.Colors.primary.opacity(0.3))
        }
        .frame(height: 160)  // ← Changed from 120
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: AppTheme.Spacing.xxs) {
            // Edit Button
            Button {
                onEdit()
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.primary)
                    .frame(width: 32, height: 32)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
        }
    }
    
    // MARK: - Title Row
    private var titleRow: some View {
        HStack(alignment: .center) {
            Text(trip.title)
                .font(AppTheme.Typography.serifSmall())
                .foregroundColor(AppTheme.Colors.passportTextPrimary)
                .lineLimit(1)
            
            Spacer()
            
            // Status Badge
            statusBadge
        }
    }
    
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
    
    // MARK: - Date Range Row
    private var dateRangeRow: some View {
        HStack(spacing: AppTheme.Spacing.xxxs) {
            Image(systemName: "calendar")
                .font(.system(size: 10))
                .foregroundColor(AppTheme.Colors.passportTextMuted)
            
            Text(trip.dateRange)
                .font(AppTheme.Typography.monoCaption())
                .foregroundColor(AppTheme.Colors.passportTextSecondary)
        }
    }
    
    // MARK: - Bottom Row (Stats + Metadata combined)
    private var bottomRow: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            // Locations
            statItem(icon: "mappin", value: "\(trip.stops?.count ?? 0)")
            
            // Entries
            statItem(icon: "doc.text", value: "0")
            
            Spacer()
            
            // Updated date
            Text("Updated \(formatRelativeDate(trip.updatedAt))")
                .font(AppTheme.Typography.monoCaption())
                .foregroundColor(AppTheme.Colors.passportTextMuted)
        }
    }
    
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
    
    private func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Preview
#Preview("Public Trip") {
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
        
        JournalTripCard(
            trip: sampleTrip,
            onView: { print("View tapped") },
            onEdit: { print("Edit tapped") }
        )
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
}

#Preview("Draft Trip") {
    let draftTrip = Trip(
        id: UUID(),
        title: "Tokyo, Japan",
        description: nil,
        coverImageUrl: nil,
        status: .draft,
        startDate: Date(),
        endDate: Date().addingTimeInterval(86400 * 7),
        createdAt: Date(),
        updatedAt: Date(),
        stops: nil
    )
    
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()
        
        JournalTripCard(
            trip: draftTrip,
            onView: { print("View tapped") },
            onEdit: { print("Edit tapped") }
        )
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
}

#Preview("Private Trip - Long Title") {
    let privateTrip = Trip(
        id: UUID(),
        title: "Road Trip Across the United States of America",
        description: "From New York to Los Angeles, experiencing the diverse landscapes and cultures along the way. Stopped at countless diners and motels.",
        coverImageUrl: nil,
        status: .private,
        startDate: Date().addingTimeInterval(-86400 * 90),
        endDate: Date().addingTimeInterval(-86400 * 60),
        createdAt: Date().addingTimeInterval(-86400 * 90),
        updatedAt: Date().addingTimeInterval(-86400 * 30),
        stops: nil
    )
    
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()
        
        JournalTripCard(
            trip: privateTrip,
            onView: { print("View tapped") },
            onEdit: { print("Edit tapped") }
        )
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
}

#Preview("Multiple Cards") {
    let trips = [
        Trip(
            id: UUID(),
            title: "Paris, France",
            description: "City of lights adventure.",
            coverImageUrl: nil,
            status: .public,
            startDate: Date().addingTimeInterval(-86400 * 30),
            endDate: Date().addingTimeInterval(-86400 * 23),
            createdAt: Date().addingTimeInterval(-86400 * 30),
            updatedAt: Date().addingTimeInterval(-86400 * 2),
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
            title: "Barcelona, Spain",
            description: "Gaudi architecture and beach vibes.",
            coverImageUrl: nil,
            status: .private,
            startDate: Date().addingTimeInterval(-86400 * 60),
            endDate: Date().addingTimeInterval(-86400 * 55),
            createdAt: Date().addingTimeInterval(-86400 * 60),
            updatedAt: Date().addingTimeInterval(-86400 * 10),
            stops: nil
        )
    ]
    
    ScrollView {
        LazyVStack(spacing: AppTheme.Spacing.lg) {
            ForEach(trips) { trip in
                JournalTripCard(
                    trip: trip,
                    onView: { print("View: \(trip.title)") },
                    onEdit: { print("Edit: \(trip.title)") }
                )
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.md)
    }
    .background(AppTheme.Colors.backgroundDark)
}
