//
//  EditorTripHeaderCard.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/22/26.
//


import SwiftUI

struct EditorTripHeaderCard: View {
    @ObservedObject var viewModel: JournalEditorViewModel
    var onDatesTapped: (() -> Void)?
    var onLocationTapped: (() -> Void)?
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            // Title
            Text(viewModel.tripTitle)
                .font(AppTheme.Typography.serifMedium())
                .foregroundColor(AppTheme.Colors.passportTextPrimary)
                .multilineTextAlignment(.center)
            
            // Route (from stops)
            if let routeText = viewModel.routeText {
                Text(routeText)
                    .font(AppTheme.Typography.monoSmall())
                    .foregroundColor(AppTheme.Colors.passportTextSecondary)
                    .multilineTextAlignment(.center)
            }
            
            // Divider
            Rectangle()
                .fill(AppTheme.Colors.passportInputBorder)
                .frame(height: 1)
                .padding(.vertical, AppTheme.Spacing.xxs)
            
            // Quick actions
            HStack(spacing: AppTheme.Spacing.xl) {
                quickActionButton(
                    icon: "calendar",
                    label: "Dates",
                    action: { onDatesTapped?() }
                )
                
                quickActionButton(
                    icon: "mappin.and.ellipse",
                    label: "Location",
                    action: { onLocationTapped?() }
                )
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(
            LinearGradient(
                colors: [
                    AppTheme.Colors.passportPageLight,
                    AppTheme.Colors.passportPageDark
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                .stroke(AppTheme.Colors.primary.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(AppTheme.CornerRadius.large)
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
    }
    
    // MARK: - Quick Action Button
    private func quickActionButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: AppTheme.Spacing.xxxs) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(label)
                    .font(AppTheme.Typography.monoSmall())
            }
            .foregroundColor(AppTheme.Colors.passportInputBorderFocused)
        }
    }
}

// MARK: - Preview
#Preview {
    let trip = Trip(
        id: UUID(),
        title: "Two Weeks in the Philippines",
        description: nil,
        coverImageUrl: nil,
        status: .draft,
        tripMode: .live,
        startDate: Date(),
        endDate: Date(),
        createdAt: Date(),
        updatedAt: Date(),
        stops: [
            TripStop(id: UUID(), placeId: nil, placeName: "Manila", latitude: 0, longitude: 0, order: 0, arrivedAt: nil, departedAt: nil),
            TripStop(id: UUID(), placeId: nil, placeName: "Palawan", latitude: 0, longitude: 0, order: 1, arrivedAt: nil, departedAt: nil),
            TripStop(id: UUID(), placeId: nil, placeName: "Cebu", latitude: 0, longitude: 0, order: 2, arrivedAt: nil, departedAt: nil)
        ]
    )
    
    ZStack {
        AppTheme.Colors.passportPageDark
            .ignoresSafeArea()
        
        EditorTripHeaderCard(viewModel: JournalEditorViewModel(trip: trip))
            .padding()
    }
}
