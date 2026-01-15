import SwiftUI

struct IdentificationSection: View {
    @ObservedObject var viewModel: PassportHomeViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Section header
            sectionHeader
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.bottom, AppTheme.Spacing.md)
            
            // Main card content
            HStack(alignment: .top, spacing: AppTheme.Spacing.md) {
                // Profile photo with corner brackets
                profilePhotoSection
                
                // Details section
                detailsSection
                
                Spacer()
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.bottom, AppTheme.Spacing.md) // Changed from .lg to .md
            
            // Stats row
            statsRow
                .padding(.horizontal, AppTheme.Spacing.lg)
        }
    }
    
    // MARK: - Section Header
    private var sectionHeader: some View {
        VStack(spacing: AppTheme.Spacing.xxxs) {
            Text("IDENTIFICATION")
                .font(AppTheme.Typography.monoSmall())
                .tracking(2)
                .foregroundColor(AppTheme.Colors.passportTextMuted)
        }
    }
    
    // MARK: - Profile Photo Section
    private var profilePhotoSection: some View {
        ZStack {
            // Photo frame
            Group {
                if let url = viewModel.profileImageUrl {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 100, height: 120)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 120)
                                .clipped()
                        case .failure:
                            placeholderImage
                        @unknown default:
                            placeholderImage
                        }
                    }
                } else {
                    placeholderImage
                }
            }
            .overlay(
                Rectangle()
                    .stroke(AppTheme.Colors.passportInputBorderFocused, lineWidth: 2)
            )
            
            // Corner brackets
            PhotoCornerBrackets()
        }
        .frame(width: 100, height: 120)
    }

    private var placeholderImage: some View {
        Rectangle()
            .fill(AppTheme.Colors.passportInputBackground)
            .frame(width: 100, height: 120)
            .overlay(
                Image(systemName: "person.fill")
                    .font(.system(size: 36))
                    .foregroundColor(AppTheme.Colors.passportTextMuted.opacity(0.3))
            )
    }

    // MARK: - Details Section
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            // Row 1: Traveler Name (full width)
            DetailField(
                label: "TRAVELER NAME",
                value: viewModel.displayName,
                useSerifFont: false,
                valueFont: AppTheme.Typography.monoMedium() // or monoLarge() for even bigger
            )
            
            // Row 2: Username and Nationality (side by side)
            HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                DetailField(
                    label: "PASSPORT NO.",
                    value: "@\(viewModel.username)",
                    useSerifFont: false
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                
                DetailField(
                    label: "NATIONALITY",
                    value: viewModel.nationalityName,
                    useSerifFont: false
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Row 3: Passport Number and Date Issued (side by side)
            HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                DetailField(
                    label: "ISSUED",
                    value: viewModel.dateIssued,
                    useSerifFont: false
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    // MARK: - Stats Row
    private var statsRow: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            StatItem(
                value: viewModel.countriesCount,
                label: "COUNTRIES"
            )
            
            StatItem(
                value: viewModel.entriesCount,
                label: "ENTRIES"
            )
            
            StatItem(
                value: viewModel.tripsCount,
                label: "TRIPS"
            )
        }
        .padding(.vertical, AppTheme.Spacing.sm)
        .padding(.horizontal, AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .fill(AppTheme.Colors.passportInputBackground.opacity(1.5))
        )
    }
}

// MARK: - Stat Item Component
private struct StatItem: View {
    let value: Int
    let label: String
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.xxxs) {
            Text("\(value)")
                .font(AppTheme.Typography.monoLarge())
                .foregroundColor(AppTheme.Colors.passportTextPrimary)
            
            Text(label)
                .font(AppTheme.Typography.monoCaption())
                .tracking(1)
                .foregroundColor(AppTheme.Colors.passportTextMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Photo Corner Brackets
private struct PhotoCornerBrackets: View {
    var body: some View {
        GeometryReader { geometry in
            let size: CGFloat = 12
            let offset: CGFloat = -3
            let lineWidth: CGFloat = 2
            
            ZStack {
                // Top-left
                Path { path in
                    path.move(to: CGPoint(x: offset + size, y: offset))
                    path.addLine(to: CGPoint(x: offset, y: offset))
                    path.addLine(to: CGPoint(x: offset, y: offset + size))
                }
                .stroke(AppTheme.Colors.primary, lineWidth: lineWidth)
                
                // Top-right
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width - offset - size, y: offset))
                    path.addLine(to: CGPoint(x: geometry.size.width - offset, y: offset))
                    path.addLine(to: CGPoint(x: geometry.size.width - offset, y: offset + size))
                }
                .stroke(AppTheme.Colors.primary, lineWidth: lineWidth)
                
                // Bottom-left
                Path { path in
                    path.move(to: CGPoint(x: offset, y: geometry.size.height - offset - size))
                    path.addLine(to: CGPoint(x: offset, y: geometry.size.height - offset))
                    path.addLine(to: CGPoint(x: offset + size, y: geometry.size.height - offset))
                }
                .stroke(AppTheme.Colors.primary, lineWidth: lineWidth)
                
                // Bottom-right
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width - offset, y: geometry.size.height - offset - size))
                    path.addLine(to: CGPoint(x: geometry.size.width - offset, y: geometry.size.height - offset))
                    path.addLine(to: CGPoint(x: geometry.size.width - offset - size, y: geometry.size.height - offset))
                }
                .stroke(AppTheme.Colors.primary, lineWidth: lineWidth)
            }
        }
    }
}

// MARK: - Detail Field Component
private struct DetailField: View {
    let label: String
    let value: String
    var useSerifFont: Bool = true
    var valueFont: Font? = nil // New parameter for custom font
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(AppTheme.Typography.monoCaption())
                .tracking(1)
                .foregroundColor(AppTheme.Colors.passportTextMuted)
            
            Text(value)
                .font(valueFont ?? (useSerifFont ? AppTheme.Typography.serifSmall() : AppTheme.Typography.monoSmall()))
                .foregroundColor(AppTheme.Colors.passportTextPrimary)
        }
    }
}

// MARK: - Preview
#Preview {
    PassportPageBackgroundView {
        IdentificationSection(viewModel: PassportHomeViewModel())
    }
}
