import SwiftUI

struct TripStop_Draft: Identifiable, Equatable {
    let id = UUID()
    var city: LocationSearchResult
    var startDate: Date
    var endDate: Date
}

struct TripStopCard: View {
    let stopNumber: Int
    @Binding var stop: TripStop_Draft
    let onRemove: () -> Void
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header row (always visible)
            headerRow
            
            // Date pickers (collapsible)
            if isExpanded {
                dateSection
                    .padding(.top, AppTheme.Spacing.sm)
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.backgroundMedium.opacity(0.5))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .stroke(AppTheme.Colors.primary.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
    
    // MARK: - Header Row
    private var headerRow: some View {
        Button {
            withAnimation(.easeInOut(duration: AppTheme.Animation.fast)) {
                isExpanded.toggle()
            }
        } label: {
            HStack(alignment: .center, spacing: AppTheme.Spacing.sm) {
                // Stop number badge
                Text("\(stopNumber)")
                    .font(AppTheme.Typography.monoSmall())
                    .foregroundColor(AppTheme.Colors.backgroundDark)
                    .frame(width: 24, height: 24)
                    .background(AppTheme.Colors.primary)
                    .clipShape(Circle())
                
                // City name and country
                VStack(alignment: .leading, spacing: 2) {
                    Text(stop.city.name)
                        .font(AppTheme.Typography.monoMedium())
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    if let countryCode = stop.city.countryCode {
                        Text(countryName(for: countryCode))
                            .font(AppTheme.Typography.monoCaption())
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
                
                Spacer()
                
                // Date badge (collapsed state shows dates)
                if !isExpanded {
                    dateBadge
                }
                
                // Expand/collapse chevron
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.Colors.primary.opacity(0.7))
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Date Badge (Collapsed State)
    private var dateBadge: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(formatDate(stop.startDate))
                .font(AppTheme.Typography.monoCaption())
                .foregroundColor(AppTheme.Colors.primary)
            
            Text(formatDate(stop.endDate))
                .font(AppTheme.Typography.monoCaption())
                .foregroundColor(AppTheme.Colors.primary)
        }
        .padding(.horizontal, AppTheme.Spacing.xs)
        .padding(.vertical, AppTheme.Spacing.xxxs)
        .background(AppTheme.Colors.primaryOverlayLight)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                .stroke(AppTheme.Colors.primary.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(AppTheme.CornerRadius.small)
    }
    
    // MARK: - Date Section (Expanded State)
    private var dateSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            // Divider
            Rectangle()
                .fill(AppTheme.Colors.primary.opacity(0.2))
                .frame(height: 1)
            
            VStack(spacing: AppTheme.Spacing.xs) {
                ThemedDatePicker(
                    label: "FROM",
                    date: $stop.startDate
                )
                
                ThemedDatePicker(
                    label: "TO",
                    date: $stop.endDate,
                    minDate: stop.startDate
                )
            }
        }
    }
    
    // MARK: - Helpers
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }
    
    private func countryName(for code: String) -> String {
        Locale.current.localizedString(forRegionCode: code) ?? code
    }
}

// MARK: - Preview
#Preview("Single Card - Collapsed") {
    let mockCity = LocationSearchResult(
        displayName: "Paris, France",
        name: "Paris",
        osmType: "R",
        osmId: 123456,
        latitude: 48.8566,
        longitude: 2.3522,
        placeType: 2,
        countryCode: "FR",
        boundingBox: nil
    )
    
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()
        
        TripStopCard(
            stopNumber: 1,
            stop: .constant(TripStop_Draft(
                city: mockCity,
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400 * 3)
            )),
            onRemove: { print("Remove tapped") }
        )
        .padding()
    }
}

#Preview("Multiple Cards") {
    let mockCities = [
        LocationSearchResult(
            displayName: "Paris, France",
            name: "Paris",
            osmType: "R",
            osmId: 123456,
            latitude: 48.8566,
            longitude: 2.3522,
            placeType: 2,
            countryCode: "FR",
            boundingBox: nil
        ),
        LocationSearchResult(
            displayName: "Rome, Italy",
            name: "Rome",
            osmType: "R",
            osmId: 234567,
            latitude: 41.9028,
            longitude: 12.4964,
            placeType: 2,
            countryCode: "IT",
            boundingBox: nil
        ),
        LocationSearchResult(
            displayName: "Barcelona, Spain",
            name: "Barcelona",
            osmType: "R",
            osmId: 345678,
            latitude: 41.3874,
            longitude: 2.1686,
            placeType: 2,
            countryCode: "ES",
            boundingBox: nil
        )
    ]
    
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()
        
        ScrollView {
            VStack(spacing: AppTheme.Spacing.sm) {
                ForEach(Array(mockCities.enumerated()), id: \.offset) { index, city in
                    TripStopCard(
                        stopNumber: index + 1,
                        stop: .constant(TripStop_Draft(
                            city: city,
                            startDate: Date().addingTimeInterval(Double(index) * 86400 * 4),
                            endDate: Date().addingTimeInterval(Double(index + 1) * 86400 * 4 - 86400)
                        )),
                        onRemove: { print("Remove \(city.name)") }
                    )
                }
            }
            .padding()
        }
    }
}
