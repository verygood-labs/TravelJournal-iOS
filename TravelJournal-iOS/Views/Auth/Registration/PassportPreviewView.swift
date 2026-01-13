import SwiftUI

// MARK: - Confirm Details Form Content
/// The form content for step 4 (only the passport page that flips)
/// Shows all entered information for review before submission
struct PassportPreviewFormContent: View {
    // Registration data bindings from parent
    let fullName: String
    let username: String
    let nationalityName: String
    let passportPhoto: UIImage?
    
    var body: some View {
        PassportPageBackgroundView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    headerSection
                        .padding(.top, AppTheme.Spacing.xl)
                        .padding(.bottom, AppTheme.Spacing.lg)
                    
                    // Photo display
                    photoSection
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.bottom, AppTheme.Spacing.lg)
                    
                    // Details section
                    detailsSection
                        .padding(.horizontal, AppTheme.Spacing.lg)
                    
                    Spacer(minLength: AppTheme.Spacing.xxxl)
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Text("✦ APPLICATION REVIEW ✦")
                .font(AppTheme.Typography.monoSmall())
                .tracking(2)
                .foregroundColor(AppTheme.Colors.passportTextMuted)
            
            Text("Confirm Details")
                .font(AppTheme.Typography.serifMedium())
                .foregroundColor(AppTheme.Colors.passportTextPrimary)
            
            Text("Please verify your information before\nsubmitting your passport application.")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.passportTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
    
    // MARK: - Photo Section
    private var photoSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            // Photo with corner brackets
            ZStack {
                Group {
                    if let image = passportPhoto {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 140, height: 170)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(AppTheme.Colors.passportInputBackground)
                            .frame(width: 140, height: 170)
                    }
                }
                .overlay(
                    Rectangle()
                        .stroke(AppTheme.Colors.passportInputBorderFocused, lineWidth: 2)
                )
                
                // Corner brackets
                ConfirmPhotoCornerBrackets()
            }
            .frame(width: 140, height: 170)
            
            Text("PASSPORT PHOTOGRAPH")
                .font(AppTheme.Typography.monoCaption())
                .tracking(1)
                .foregroundColor(AppTheme.Colors.passportTextMuted)
        }
    }
    
    // MARK: - Details Section
    private var detailsSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Full Name
            DetailRow(label: "FULL NAME", value: fullName)
            
            // Username
            DetailRow(label: "HANDLE / USERNAME", value: "@\(username)")
            
            // Nationality
            DetailRow(label: "NATIONALITY", value: nationalityName)
        }
    }
}

// MARK: - Detail Row Component
private struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
            Text(label)
                .font(AppTheme.Typography.inputLabel())
                .tracking(1)
                .foregroundColor(AppTheme.Colors.passportTextMuted)
            
            HStack {
                Text(value)
                    .font(AppTheme.Typography.monoMedium())
                    .foregroundColor(AppTheme.Colors.passportTextPrimary)
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "4CAF50"))
            }
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.vertical, 14)
            .background(AppTheme.Colors.passportInputBackground)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(AppTheme.Colors.passportInputBorder, lineWidth: 2)
            )
            .cornerRadius(AppTheme.CornerRadius.medium)
        }
    }
}

// MARK: - Corner Brackets for Confirm Photo
private struct ConfirmPhotoCornerBrackets: View {
    var body: some View {
        GeometryReader { geometry in
            let bracketSize: CGFloat = 16
            let offset: CGFloat = -4
            let lineWidth: CGFloat = 2
            
            ZStack {
                // Top-left bracket
                Path { path in
                    path.move(to: CGPoint(x: offset + bracketSize, y: offset))
                    path.addLine(to: CGPoint(x: offset, y: offset))
                    path.addLine(to: CGPoint(x: offset, y: offset + bracketSize))
                }
                .stroke(AppTheme.Colors.primary, lineWidth: lineWidth)
                
                // Top-right bracket
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width - offset - bracketSize, y: offset))
                    path.addLine(to: CGPoint(x: geometry.size.width - offset, y: offset))
                    path.addLine(to: CGPoint(x: geometry.size.width - offset, y: offset + bracketSize))
                }
                .stroke(AppTheme.Colors.primary, lineWidth: lineWidth)
                
                // Bottom-left bracket
                Path { path in
                    path.move(to: CGPoint(x: offset, y: geometry.size.height - offset - bracketSize))
                    path.addLine(to: CGPoint(x: offset, y: geometry.size.height - offset))
                    path.addLine(to: CGPoint(x: offset + bracketSize, y: geometry.size.height - offset))
                }
                .stroke(AppTheme.Colors.primary, lineWidth: lineWidth)
                
                // Bottom-right bracket
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width - offset, y: geometry.size.height - offset - bracketSize))
                    path.addLine(to: CGPoint(x: geometry.size.width - offset, y: geometry.size.height - offset))
                    path.addLine(to: CGPoint(x: geometry.size.width - offset - bracketSize, y: geometry.size.height - offset))
                }
                .stroke(AppTheme.Colors.primary, lineWidth: lineWidth)
            }
        }
    }
}

// MARK: - Passport Card Component
/// The passport ID card design shown only in the issued state
/// Uses passport page styling (cream/paper background)
struct PassportCard: View {
    let fullName: String
    let username: String
    let nationalityName: String
    let passportPhoto: UIImage?
    
    private var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top section with photo and name
            HStack(alignment: .center, spacing: AppTheme.Spacing.lg) {
                // Photo area
                photoArea
                
                // Details area
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xxxs) {
                    Text("TRAVELER")
                        .font(AppTheme.Typography.inputLabel())
                        .tracking(2)
                        .foregroundColor(AppTheme.Colors.passportTextMuted)
                    
                    Text(fullName)
                        .font(AppTheme.Typography.serifMedium())
                        .foregroundColor(AppTheme.Colors.passportTextPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    
                    // Status badge
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                        Text("ACTIVE")
                            .font(AppTheme.Typography.monoSmall())
                            .tracking(1)
                    }
                    .foregroundColor(Color(hex: "27ae60"))
                    .padding(.top, 4)
                }
                
                Spacer()
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.top, AppTheme.Spacing.lg)
            .padding(.bottom, AppTheme.Spacing.md)
            
            // Divider
            Rectangle()
                .fill(AppTheme.Colors.passportInputBorder)
                .frame(height: 1)
                .padding(.horizontal, AppTheme.Spacing.lg)
            
            // Bottom info row
            HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                // Issued date
                VStack(alignment: .leading, spacing: 4) {
                    Text("ISSUED")
                        .font(AppTheme.Typography.monoTiny())
                        .tracking(1)
                        .foregroundColor(AppTheme.Colors.passportTextMuted)
                    
                    Text(currentDate)
                        .font(AppTheme.Typography.monoSmall())
                        .foregroundColor(AppTheme.Colors.passportTextPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Passport No (username)
                VStack(alignment: .leading, spacing: 4) {
                    Text("PASSPORT NO.")
                        .font(AppTheme.Typography.monoTiny())
                        .tracking(1)
                        .foregroundColor(AppTheme.Colors.passportTextMuted)
                    
                    Text("@\(username)")
                        .font(AppTheme.Typography.monoSmall())
                        .foregroundColor(AppTheme.Colors.passportTextPrimary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Nationality
                VStack(alignment: .leading, spacing: 4) {
                    Text("NATIONALITY")
                        .font(AppTheme.Typography.monoTiny())
                        .tracking(1)
                        .foregroundColor(AppTheme.Colors.passportTextMuted)
                    
                    Text(nationalityName)
                        .font(AppTheme.Typography.monoSmall())
                        .foregroundColor(AppTheme.Colors.passportTextPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
        }
        .background(
            // Passport page cream/paper gradient
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
            // Gold border with corner accents
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                    .stroke(AppTheme.Colors.primary, lineWidth: 2)
                
                // Corner accents
                PassportCardCornerAccents()
            }
        )
        .cornerRadius(AppTheme.CornerRadius.large)
        .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
    }
    
    // MARK: - Photo Area
    private var photoArea: some View {
        ZStack {
            Group {
                if let image = passportPhoto {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 85, height: 105)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(AppTheme.Colors.passportInputBackground)
                        .frame(width: 85, height: 105)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 36))
                                .foregroundColor(AppTheme.Colors.passportTextMuted.opacity(0.3))
                        )
                }
            }
            .overlay(
                Rectangle()
                    .stroke(AppTheme.Colors.passportInputBorderFocused, lineWidth: 2)
            )
            
            // Photo corner brackets
            PhotoCornerBrackets()
                .frame(width: 85, height: 105)
        }
    }
}

// MARK: - Passport Card Corner Accents
private struct PassportCardCornerAccents: View {
    var body: some View {
        GeometryReader { geometry in
            let size: CGFloat = 20
            let offset: CGFloat = -1
            let lineWidth: CGFloat = 3
            
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

// MARK: - Photo Corner Brackets
private struct PhotoCornerBrackets: View {
    var body: some View {
        GeometryReader { geometry in
            let size: CGFloat = 10
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

// MARK: - Preview
#Preview {
    PassportPreviewFormContent(
        fullName: "Ralph Buan",
        username: "rjbuan",
        nationalityName: "Philippines",
        passportPhoto: nil
    )
}
