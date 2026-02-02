import SwiftUI

// MARK: - Social Auth Section

/// Reusable social authentication section with divider and Google/Apple buttons
/// Usage: SocialAuthSection(onGoogleTap: { }, onAppleTap: { })
struct SocialAuthSection: View {
    var showLabels: Bool = true
    var onGoogleTap: () -> Void
    var onAppleTap: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Divider
            divider

            // Social buttons
            HStack(spacing: AppTheme.Spacing.xs) {
                // Google
                Button(action: onGoogleTap) {
                    if showLabels {
                        HStack(spacing: AppTheme.Spacing.xxs) {
                            googleIcon
                            Text("Google")
                                .font(AppTheme.Typography.monoSmall())
                        }
                    } else {
                        googleIcon
                    }
                }
                .buttonStyle(SocialButtonStyle())

                // Apple
                Button(action: onAppleTap) {
                    if showLabels {
                        HStack(spacing: AppTheme.Spacing.xxs) {
                            appleIcon
                            Text("Apple")
                                .font(AppTheme.Typography.monoSmall())
                        }
                    } else {
                        appleIcon
                    }
                }
                .buttonStyle(SocialButtonStyle())
            }
        }
    }

    // MARK: - Divider

    private var divider: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Rectangle()
                .fill(AppTheme.Colors.divider)
                .frame(height: 1)

            Text("OR")
                .font(AppTheme.Typography.monoCaption())
                .tracking(1)
                .foregroundColor(AppTheme.Colors.textPrimary.opacity(0.3))

            Rectangle()
                .fill(AppTheme.Colors.divider)
                .frame(height: 1)
        }
    }

    // MARK: - Google Icon

    private var googleIcon: some View {
        // Using SF Symbol as fallback - replace with actual Google logo asset
        Image(systemName: "g.circle.fill")
            .font(.system(size: showLabels ? 16 : 20))
            .foregroundStyle(.linearGradient(
                colors: [.red, .yellow, .green, .blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
    }

    // MARK: - Apple Icon

    private var appleIcon: some View {
        Image(systemName: "apple.logo")
            .font(.system(size: showLabels ? 16 : 20))
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()

        VStack(spacing: 40) {
            // With labels (for RegisterView)
            SocialAuthSection(
                showLabels: true,
                onGoogleTap: {},
                onAppleTap: {}
            )

            // Without labels (for LoginView)
            SocialAuthSection(
                showLabels: false,
                onGoogleTap: {},
                onAppleTap: {}
            )
        }
        .padding()
    }
}
