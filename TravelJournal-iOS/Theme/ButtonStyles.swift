import SwiftUI

// MARK: - Primary Button Style

/// Full-width filled button with press effects
/// Usage: Button("CREATE PASSPORT") { }.buttonStyle(PrimaryButtonStyle())
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    var isLoading: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: AppTheme.Spacing.xxs) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.backgroundDark))
                    .scaleEffect(0.8)
            }

            configuration.label
                .font(AppTheme.Typography.button())
                .tracking(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(isEnabled ? AppTheme.Colors.primary : AppTheme.Colors.primary.opacity(0.3))
        .foregroundColor(isEnabled ? AppTheme.Colors.backgroundDark : AppTheme.Colors.backgroundDark.opacity(0.5))
        .cornerRadius(AppTheme.CornerRadius.pill)
        .scaleEffect(configuration.isPressed && isEnabled ? 0.98 : 1.0)
        .opacity(isLoading ? 0.7 : 1.0)
        .animation(.easeInOut(duration: AppTheme.Animation.fast), value: configuration.isPressed)
        .animation(.easeInOut(duration: AppTheme.Animation.fast), value: isEnabled)
    }
}

// MARK: - Secondary Button Style

/// Transparent button with border
/// Usage: Button("I HAVE A PASSPORT") { }.buttonStyle(SecondaryButtonStyle())
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Typography.button())
            .tracking(1)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(
                configuration.isPressed
                    ? AppTheme.Colors.primaryOverlayLight
                    : Color.clear
            )
            .foregroundColor(AppTheme.Colors.primary)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.pill)
                    .stroke(
                        configuration.isPressed
                            ? AppTheme.Colors.primary
                            : AppTheme.Colors.primary.opacity(0.4),
                        lineWidth: 2
                    )
            )
            .cornerRadius(AppTheme.CornerRadius.pill)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: AppTheme.Animation.fast), value: configuration.isPressed)
    }
}

// MARK: - Social Button Style

/// Square button for social login (Google, Apple)
/// Usage: Button { } label: { Image(...) }.buttonStyle(SocialButtonStyle())
struct SocialButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                configuration.isPressed
                    ? Color.white.opacity(0.1)
                    : AppTheme.Colors.inputBackground
            )
            .foregroundColor(AppTheme.Colors.textPrimary)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(
                        configuration.isPressed
                            ? AppTheme.Colors.inputBorder
                            : Color.white.opacity(0.1),
                        lineWidth: 1
                    )
            )
            .cornerRadius(AppTheme.CornerRadius.medium)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: AppTheme.Animation.fast), value: configuration.isPressed)
    }
}

// MARK: - Back Button Style

/// Small back button
/// Usage: Button("← Back") { }.buttonStyle(BackButtonStyle())
struct BackButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Typography.monoSmall())
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                configuration.isPressed
                    ? AppTheme.Colors.primary.opacity(0.25)
                    : AppTheme.Colors.primaryOverlay
            )
            .foregroundColor(AppTheme.Colors.primary)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
            )
            .cornerRadius(AppTheme.CornerRadius.medium)
            .animation(.easeInOut(duration: AppTheme.Animation.fast), value: configuration.isPressed)
    }
}

// MARK: - Text Link Button Style

/// Minimal text button for links
/// Usage: Button("Forgot password?") { }.buttonStyle(TextLinkButtonStyle())
struct TextLinkButtonStyle: ButtonStyle {
    var color: Color = AppTheme.Colors.primary.opacity(0.7)

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Typography.monoSmall())
            .foregroundColor(configuration.isPressed ? AppTheme.Colors.primary : color)
            .animation(.easeInOut(duration: AppTheme.Animation.fast), value: configuration.isPressed)
    }
}
