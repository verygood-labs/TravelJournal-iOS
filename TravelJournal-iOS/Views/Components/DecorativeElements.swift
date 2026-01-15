import SwiftUI

// MARK: - Gold Border
/// Decorative gold border used to separate sections (e.g., between header and body)
/// Usage: GoldBorder()
struct GoldBorder: View {
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(AppTheme.Colors.primary)
                .frame(height: 3)
            
            Rectangle()
                .fill(AppTheme.Colors.primary.opacity(0.3))
                .frame(height: 1)
        }
    }
}

// MARK: - Section Divider
/// Subtle divider line for separating content sections on passport pages
/// Usage: SectionDivider()
struct SectionDivider: View {
    var padding: CGFloat = AppTheme.Spacing.lg
    
    var body: some View {
        Rectangle()
            .fill(AppTheme.Colors.passportInputBorder)
            .frame(height: 1)
            .padding(.horizontal, padding)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 40) {
        GoldBorder()
        
        PassportPageBackgroundView {
            VStack(spacing: 20) {
                Text("Section 1")
                SectionDivider()
                Text("Section 2")
            }
            .padding()
        }
        .frame(height: 200)
    }
}