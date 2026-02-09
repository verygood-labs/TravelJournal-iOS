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

            // Dates and Location info
            HStack(spacing: AppTheme.Spacing.xl) {
                // Dates
                Button {
                    onDatesTapped?()
                } label: {
                    HStack(spacing: AppTheme.Spacing.xxxs) {
                        Image(systemName: "calendar")
                            .font(.system(size: 14))
                        if viewModel.startDateText != nil || viewModel.endDateText != nil {
                            VStack(alignment: .leading, spacing: 2) {
                                if let startText = viewModel.startDateText {
                                    Text(startText)
                                        .font(AppTheme.Typography.monoSmall())
                                }
                                if let endText = viewModel.endDateText {
                                    Text(endText)
                                        .font(AppTheme.Typography.monoSmall())
                                }
                            }
                        } else {
                            Text("Add Dates")
                                .font(AppTheme.Typography.monoSmall())
                        }
                    }
                    .foregroundColor(AppTheme.Colors.passportInputBorderFocused)
                }

                // Location
                Button {
                    onLocationTapped?()
                } label: {
                    HStack(spacing: AppTheme.Spacing.xxxs) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 14))
                        if !viewModel.tripStops.isEmpty {
                            Text("\(viewModel.tripStops.count) stop\(viewModel.tripStops.count == 1 ? "" : "s")")
                                .font(AppTheme.Typography.monoSmall())
                        } else {
                            Text("Add Location")
                                .font(AppTheme.Typography.monoSmall())
                        }
                    }
                    .foregroundColor(AppTheme.Colors.passportInputBorderFocused)
                }
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(
            LinearGradient(
                colors: [
                    AppTheme.Colors.passportPageLight,
                    AppTheme.Colors.passportPageDark,
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
}

// MARK: - Preview

#Preview {
    ZStack {
        AppTheme.Colors.passportPageDark
            .ignoresSafeArea()

        EditorTripHeaderCard(viewModel: JournalEditorViewModel(trip: .previewWithStops, toastManager: ToastManager()))
            .padding()
    }
}
