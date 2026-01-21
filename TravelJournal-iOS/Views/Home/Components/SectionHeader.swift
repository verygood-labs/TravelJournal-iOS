import SwiftUI

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var trailingActionLabel: String? = nil
    var onTrailingActionTapped: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack(spacing: AppTheme.Spacing.xxxs) {
                Text(title)
                    .font(AppTheme.Typography.monoSmall())
                    .tracking(2)
                    .foregroundColor(AppTheme.Colors.passportTextMuted)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(AppTheme.Typography.monoCaption())
                        .foregroundColor(AppTheme.Colors.passportTextSecondary)
                }
            }
            
            Spacer()
        }
        .overlay(
            Group {
                if let actionLabel = trailingActionLabel {
                    Button {
                        onTrailingActionTapped?()
                    } label: {
                        Text(actionLabel)
                            .font(AppTheme.Typography.monoSmall())
                            .foregroundColor(AppTheme.Colors.passportInputBorderFocused)
                    }
                }
            },
            alignment: .topTrailing
        )
    }
}

#Preview {
    PassportPageBackgroundView {
        VStack(spacing: 40) {
            SectionHeader(title: "VISAS & ENTRIES", subtitle: "Your travel stamps")
            
            SectionHeader(
                title: "VISAS & ENTRIES",
                subtitle: "Your travel stamps",
                trailingActionLabel: "View All",
                onTrailingActionTapped: { print("Tapped!") }
            )
            
            SectionHeader(title: "IDENTIFICATION")
        }
        .padding()
    }
}
