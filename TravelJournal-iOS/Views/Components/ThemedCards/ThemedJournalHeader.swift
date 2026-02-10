//
//  ThemedJournalHeader.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 2/5/26.
//

import SwiftUI

// MARK: - Themed Journal Header

/// A themed header for the journal preview, showing trip title, dates, and route.
struct ThemedJournalHeader: View {
    let title: String
    let description: String?
    let coverImageUrl: String?
    let startDate: Date?
    let endDate: Date?
    let stops: [TripStop]
    var statsConfig: HeaderStatsConfig?

    @Environment(\.journalTheme) private var theme

    // MARK: - Computed Properties

    private var dateRangeText: String? {
        guard let start = startDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"

        if let end = endDate {
            return "\(formatter.string(from: start)) — \(formatter.string(from: end))"
        }
        return formatter.string(from: start)
    }

    private var routeText: String? {
        guard !stops.isEmpty else { return nil }
        return stops.map { $0.place.name }.joined(separator: " → ")
    }

    private var primaryCountryCode: String? {
        stops.first?.place.countryCode
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Cover image
            coverSection

            // Content card (overlaps cover)
            contentCard
                .offset(y: -40)
        }
    }

    // MARK: - Cover Section

    @ViewBuilder
    private var coverSection: some View {
        ZStack(alignment: .bottomLeading) {
            // Background
            if let coverImageUrl = coverImageUrl, !coverImageUrl.isEmpty {
                AsyncImage(url: URL(string: coverImageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 220)
                            .clipped()
                    default:
                        defaultCoverBackground
                    }
                }
            } else {
                defaultCoverBackground
            }

            // Gradient overlay
            LinearGradient(
                colors: [
                    Color.black.opacity(0.5),
                    Color.black.opacity(0.2),
                    Color.clear
                ],
                startPoint: .bottom,
                endPoint: .top
            )
        }
        .frame(height: 220)
    }

    private var defaultCoverBackground: some View {
        ZStack {
            theme.colors.primaryColor
                .opacity(0.8)

            // Pattern based on header style
            if theme.style.headerStyle == .passport {
                passportPattern
            }
        }
        .frame(height: 220)
    }

    @ViewBuilder
    private var passportPattern: some View {
        GeometryReader { geometry in
            Path { path in
                let spacing: CGFloat = 20
                for x in stride(from: 0, to: geometry.size.width, by: spacing) {
                    for y in stride(from: 0, to: geometry.size.height, by: spacing) {
                        path.addEllipse(in: CGRect(x: x, y: y, width: 2, height: 2))
                    }
                }
            }
            .fill(Color.white.opacity(0.1))
        }
    }

    // MARK: - Content Card

    private var contentCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Country stamp (if available)
            if let countryCode = primaryCountryCode {
                countryStamp(code: countryCode)
            }

            // Title
            Text(title)
                .font(theme.typography.headingFont(size: 28, weight: .bold))
                .foregroundColor(theme.colors.textPrimaryColor)

            // Description
            if let description = description, !description.isEmpty {
                Text(description)
                    .font(theme.typography.bodyFont(size: 15))
                    .foregroundColor(theme.colors.textSecondaryColor)
            }

            // Dates
            if let dateRange = dateRangeText {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                    Text(dateRange)
                        .font(theme.typography.labelFont(size: 12))
                }
                .foregroundColor(theme.colors.textMutedColor)
            }

            // Route
            if let route = routeText {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.triangle.swap")
                        .font(.system(size: 12))
                    Text(route)
                        .font(theme.typography.labelFont(size: 12))
                        .lineLimit(1)
                }
                .foregroundColor(theme.colors.textMutedColor)
            }

            // Stats pill - bottom right
            if let stats = statsConfig {
                HStack {
                    Spacer()
                    ThemedHeaderStatsBar(config: stats)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.colors.cardBackgroundColor)
        .cornerRadius(theme.style.borderRadius)
        .overlay(
            RoundedRectangle(cornerRadius: theme.style.borderRadius)
                .stroke(
                    theme.style.borderRadius == 0 ? theme.colors.borderColor : theme.colors.borderColor.opacity(0.5),
                    lineWidth: theme.style.borderRadius == 0 ? 2 : 1
                )
        )
        .shadow(
            color: theme.style.cardShadow ? Color.black.opacity(0.1) : .clear,
            radius: theme.style.cardShadow ? 10 : 0,
            x: 0,
            y: theme.style.cardShadow ? 4 : 0
        )
        .padding(.horizontal, 16)
    }

    // MARK: - Country Stamp

    @ViewBuilder
    private func countryStamp(code: String) -> some View {
        switch theme.style.headerStyle {
        case .passport:
            Text(code.uppercased())
                .font(theme.typography.labelFont(size: 14, weight: .bold))
                .foregroundColor(theme.colors.accentColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(theme.colors.accentColor, lineWidth: 2)
                )
                .rotationEffect(.degrees(-5))

        case .standard:
            HStack(spacing: 4) {
                Text(flag(for: code))
                    .font(.system(size: 20))
                Text(code.uppercased())
                    .font(theme.typography.labelFont(size: 12, weight: .semibold))
                    .foregroundColor(theme.colors.textSecondaryColor)
            }

        case .minimal:
            EmptyView()
        }
    }

    private func flag(for countryCode: String) -> String {
        let base: UInt32 = 127397
        var flag = ""
        for scalar in countryCode.uppercased().unicodeScalars {
            if let unicodeScalar = UnicodeScalar(base + scalar.value) {
                flag.append(Character(unicodeScalar))
            }
        }
        return flag
    }
}

// MARK: - Preview

#Preview("Default Theme") {
    ScrollView {
        ThemedJournalHeader(
            title: "Two Weeks in the Philippines",
            description: "Island hopping adventure through paradise",
            coverImageUrl: nil,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 14),
            stops: [
                TripStop(id: UUID(), order: 0, arrivalDate: nil, place: TripStopPlace(id: UUID(), name: "Manila", displayName: "Manila, Philippines", placeType: .city, countryCode: "PH", latitude: 14.5995, longitude: 120.9842)),
                TripStop(id: UUID(), order: 1, arrivalDate: nil, place: TripStopPlace(id: UUID(), name: "Palawan", displayName: "Palawan, Philippines", placeType: .city, countryCode: "PH", latitude: 9.8349, longitude: 118.7384)),
                TripStop(id: UUID(), order: 2, arrivalDate: nil, place: TripStopPlace(id: UUID(), name: "Cebu", displayName: "Cebu, Philippines", placeType: .city, countryCode: "PH", latitude: 10.3157, longitude: 123.8854)),
            ]
        )
    }
    .background(Color(hex: "#f5f5f5"))
    .journalTheme(.default)
}

#Preview("Passport Theme") {
    ScrollView {
        ThemedJournalHeader(
            title: "Two Weeks in the Philippines",
            description: "Island hopping adventure through paradise",
            coverImageUrl: nil,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 14),
            stops: [
                TripStop(id: UUID(), order: 0, arrivalDate: nil, place: TripStopPlace(id: UUID(), name: "Manila", displayName: "Manila, Philippines", placeType: .city, countryCode: "PH", latitude: 14.5995, longitude: 120.9842)),
                TripStop(id: UUID(), order: 1, arrivalDate: nil, place: TripStopPlace(id: UUID(), name: "Palawan", displayName: "Palawan, Philippines", placeType: .city, countryCode: "PH", latitude: 9.8349, longitude: 118.7384)),
            ]
        )
    }
    .background(Color(hex: "#f5f1e8"))
    .journalTheme(.passport)
}

#Preview("Retro Theme") {
    ScrollView {
        ThemedJournalHeader(
            title: "Two Weeks in the Philippines",
            description: "Island hopping adventure",
            coverImageUrl: nil,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 14),
            stops: [
                TripStop(id: UUID(), order: 0, arrivalDate: nil, place: TripStopPlace(id: UUID(), name: "Manila", displayName: "Manila, Philippines", placeType: .city, countryCode: "PH", latitude: 14.5995, longitude: 120.9842)),
            ]
        )
    }
    .background(Color(hex: "#C0C0C0"))
    .journalTheme(.retro)
}
