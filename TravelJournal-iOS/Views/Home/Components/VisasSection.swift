import SwiftUI

struct VisasSection: View {
    @ObservedObject var viewModel: PassportHomeViewModel

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Section header
            sectionHeader
                .padding(.horizontal, AppTheme.Spacing.lg)
            
            // Placeholder stamps grid
            stampGrid
                .padding(.horizontal, AppTheme.Spacing.lg)
        }
    }

    // MARK: - Section Header
    private var sectionHeader: some View {
        SectionHeader(title: "VISAS & ENTRIES", subtitle: "Your travel stamps")
    }
    
    // MARK: - Stamp Grid
    private var stampGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: AppTheme.Spacing.xs),
                GridItem(.flexible(), spacing: AppTheme.Spacing.xs),
                GridItem(.flexible(), spacing: AppTheme.Spacing.xs)
            ],
            spacing: AppTheme.Spacing.xs
        ) {
            if viewModel.countryStamps.isEmpty {
                // Empty state - show "Add More" button only
                AddMoreStamp()
            } else {
                // Real stamps
                ForEach(viewModel.countryStamps) { stamp in
                    CountryStampView(stamp: stamp)
                }
                
                // Add more button at the end
                AddMoreStamp()
            }
        }
    }
}

// MARK: - Placeholder Stamp
private struct PlaceholderStamp: View {
    let index: Int
    
    // Sample data for visual purposes
    private let sampleData = [
        ("JAPAN", "🗾", "Mar 2024"),
        ("ITALIA", "🍝", "Jul 2023"),
        ("KOREA", "🏯", "Oct 2023"),
        ("THAILAND", "🏖️", "Feb 2024"),
        ("MEXICO", "🌮", "May 2023"),
        ("FRANCE", "🗼", "Aug 2023")
    ]
    
    var body: some View {
        let data = sampleData[index % sampleData.count]
        
        VStack(spacing: AppTheme.Spacing.xxs) {
            // Stamp illustration
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.8),
                                Color.white.opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .aspectRatio(1, contentMode: .fit)
                
                // Emoji icon
                Text(data.1)
                    .font(.system(size: 32))
            }
            .overlay(
                // Postage stamp edges
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                    .strokeBorder(
                        style: StrokeStyle(
                            lineWidth: 2,
                            dash: [4, 4]
                        )
                    )
                    .foregroundColor(AppTheme.Colors.passportTextMuted.opacity(0.4))
            )
            
            // Country name
            Text(data.0)
                .font(AppTheme.Typography.monoCaption())
                .tracking(0.5)
                .foregroundColor(AppTheme.Colors.passportTextPrimary)
                .lineLimit(1)
            
            // Date
            Text(data.2)
                .font(AppTheme.Typography.monoTiny())
                .foregroundColor(AppTheme.Colors.passportTextMuted)
        }
    }
}

// MARK: - Add More Stamp
private struct AddMoreStamp: View {
    var body: some View {
        VStack(spacing: AppTheme.Spacing.xxs) {
            // Add button
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                    .fill(AppTheme.Colors.passportInputBackground)
                    .aspectRatio(1, contentMode: .fit)
                
                Image(systemName: "plus")
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(AppTheme.Colors.passportTextMuted)
            }
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                    .strokeBorder(
                        style: StrokeStyle(
                            lineWidth: 2,
                            dash: [4, 4]
                        )
                    )
                    .foregroundColor(AppTheme.Colors.passportTextMuted.opacity(0.4))
            )
            
            // Label
            Text("ADD MORE")
                .font(AppTheme.Typography.monoCaption())
                .tracking(0.5)
                .foregroundColor(AppTheme.Colors.passportTextMuted)
                .lineLimit(1)
            
            // Spacer for alignment
            Text(" ")
                .font(AppTheme.Typography.monoTiny())
        }
    }
}

// MARK: - Preview
#Preview {
    PassportPageBackgroundView {
        VisasSection(viewModel: PassportHomeViewModel())
            .padding(.vertical, AppTheme.Spacing.lg)
    }
}
