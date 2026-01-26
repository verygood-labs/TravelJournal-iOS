import SwiftUI

struct TripPreviewView: View {
    @ObservedObject var viewModel: AddTripViewModel
    @Environment(\.dismiss) private var dismiss
    
    let onTripCreated: (Trip) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header (dark background)
            headerSection
                .background(AppTheme.Colors.backgroundDark)
            
            // Gold border
            GoldBorder()
            
            // Content (passport page background)
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Title section
                    titleSection
                    
                    // Stats row
                    statsSection
                    
                    // Journal name field
                    journalNameSection
                    
                    // Description field
                    descriptionSection
                    
                    // Bottom padding
                    Spacer()
                        .frame(height: 100)
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.top, AppTheme.Spacing.md)
            }
            .background(
                PassportPageBackgroundView { Color.clear }
            )
            
            // Bottom button (dark background)
            bottomButton
        }
        .background(AppTheme.Colors.backgroundDark)
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Text("← Back")
            }
            .buttonStyle(BackButtonStyle())
            
            Spacer()
            
            Text("STEP 2 OF 2")
                .font(AppTheme.Typography.monoSmall())
                .tracking(2)
                .foregroundColor(AppTheme.Colors.primary)
            
            Spacer()
            
            // Invisible button for balance
            Text("← Back")
                .opacity(0)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.md)
    }
    
    // MARK: - Title Section
    private var titleSection: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Text("✦ TRIP PREVIEW ✦")
                .font(AppTheme.Typography.monoSmall())
                .tracking(2)
                .foregroundColor(AppTheme.Colors.passportTextMuted)
            
            Text("Review Your Journey")
                .font(AppTheme.Typography.serifMedium())
                .foregroundColor(AppTheme.Colors.passportTextPrimary)
        }
        .padding(.top, AppTheme.Spacing.md)
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        HStack(spacing: 0) {
            // Dates
            datesStatItem
            
            Divider()
                .frame(height: 50)
                .background(AppTheme.Colors.passportInputBorder)
            
            // Duration
            statItem(
                label: "DURATION",
                value: viewModel.totalDuration != nil ? "\(viewModel.totalDuration!) days" : "-"
            )
            
            Divider()
                .frame(height: 50)
                .background(AppTheme.Colors.passportInputBorder)
            
            // Stops
            statItem(
                label: "STOPS",
                value: "\(viewModel.countriesCount) \(viewModel.countriesCount == 1 ? "country" : "countries")"
            )
        }
        .padding(.vertical, AppTheme.Spacing.md)
        .background(AppTheme.Colors.passportInputBackground)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .stroke(AppTheme.Colors.passportInputBorder, lineWidth: 1)
        )
        .cornerRadius(AppTheme.CornerRadius.medium)
    }

    // MARK: - Dates Stat Item
    private var datesStatItem: some View {
        VStack(spacing: AppTheme.Spacing.xxxs) {
            Text("DATES")
                .font(AppTheme.Typography.monoCaption())
                .tracking(1)
                .foregroundColor(AppTheme.Colors.passportTextMuted)
            
            VStack(spacing: 2) {
                Text(viewModel.startDateFormatted ?? "-")
                    .font(AppTheme.Typography.monoSmall())
                    .foregroundColor(AppTheme.Colors.passportTextPrimary)
                
                Text(viewModel.endDateFormatted ?? "-")
                    .font(AppTheme.Typography.monoSmall())
                    .foregroundColor(AppTheme.Colors.passportTextPrimary)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func statItem(label: String, value: String) -> some View {
        VStack(spacing: AppTheme.Spacing.xxxs) {
            Text(label)
                .font(AppTheme.Typography.monoCaption())
                .tracking(1)
                .foregroundColor(AppTheme.Colors.passportTextMuted)
            
            Text(value)
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.passportTextPrimary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Journal Name Section
    private var journalNameSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text("JOURNAL NAME (OPTIONAL)")
                .font(AppTheme.Typography.monoCaption())
                .tracking(1)
                .foregroundColor(AppTheme.Colors.passportTextMuted)
            
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                TextField(
                    "",
                    text: $viewModel.tripTitle,
                    prompt: Text(viewModel.autoGeneratedTitle)
                        .foregroundColor(AppTheme.Colors.passportTextPlaceholder)
                )
                .font(AppTheme.Typography.monoMedium())
                .foregroundColor(AppTheme.Colors.passportTextPrimary)
                .padding(.horizontal, AppTheme.Spacing.sm)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(AppTheme.Colors.passportInputBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .stroke(AppTheme.Colors.passportInputBorder, lineWidth: 1)
                )
                .cornerRadius(AppTheme.CornerRadius.medium)
                
                Text("Tap to customize")
                    .font(AppTheme.Typography.monoCaption())
                    .foregroundColor(AppTheme.Colors.passportTextMuted.opacity(0.6))
            }
        }
    }
    
    // MARK: - Description Section
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text("DESCRIPTION (OPTIONAL)")
                .font(AppTheme.Typography.monoCaption())
                .tracking(1)
                .foregroundColor(AppTheme.Colors.passportTextMuted)
            
            TextField(
                "",
                text: $viewModel.tripDescription,
                prompt: Text("Add a description for your trip...")
                    .foregroundColor(AppTheme.Colors.passportTextPlaceholder),
                axis: .vertical
            )
            .font(AppTheme.Typography.monoSmall())
            .foregroundColor(AppTheme.Colors.passportTextPrimary)
            .lineLimit(3...6)
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(AppTheme.Colors.passportInputBackground)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(AppTheme.Colors.passportInputBorder, lineWidth: 1)
            )
            .cornerRadius(AppTheme.CornerRadius.medium)
        }
    }
    
    // MARK: - Bottom Button
    private var bottomButton: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            // Error message
            if let error = viewModel.error {
                Text(error)
                    .font(AppTheme.Typography.monoCaption())
                    .foregroundColor(AppTheme.Colors.error)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.bottom, AppTheme.Spacing.xs)
            }
            
            Button {
                Task {
                    if let createdTrip = await viewModel.saveTrip() {
                        onTripCreated(createdTrip)
                    }
                }
            } label: {
                HStack(spacing: AppTheme.Spacing.xxs) {
                    if viewModel.isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.backgroundDark))
                            .scaleEffect(0.8)
                    } else {
                        Text("✦")
                    }
                    Text("START JOURNALING")
                        .font(AppTheme.Typography.button())
                        .tracking(1)
                }
            }
            .buttonStyle(PrimaryButtonStyle(isLoading: viewModel.isSubmitting))
            .disabled(viewModel.isSubmitting)
            
            Text("Add entries to complete your journal")
                .font(AppTheme.Typography.monoCaption())
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(AppTheme.Colors.backgroundDark)
    }
}

// MARK: - Preview
#Preview {
    TripPreviewView(
        viewModel: {
            let vm = AddTripViewModel()
            vm.stops = [
                TripStop_Draft(
                    city: LocationSearchResult(
                        displayName: "Paris, France",
                        name: "Paris",
                        osmType: "R",
                        osmId: 123456,
                        latitude: 48.8566,
                        longitude: 2.3522,
                        placeType: .city,
                        countryCode: "FR",
                        boundingBox: nil
                    ),
                    startDate: Date(),
                    endDate: Date().addingTimeInterval(86400 * 3)
                ),
                TripStop_Draft(
                    city: LocationSearchResult(
                        displayName: "Rome, Italy",
                        name: "Rome",
                        osmType: "R",
                        osmId: 234567,
                        latitude: 41.9028,
                        longitude: 12.4964,
                        placeType: .city,
                        countryCode: "IT",
                        boundingBox: nil
                    ),
                    startDate: Date().addingTimeInterval(86400 * 4),
                    endDate: Date().addingTimeInterval(86400 * 7)
                )
            ]
            return vm
        }(),
        onTripCreated: { trip in print("Trip created: \(trip.title)") }    )
}
