import SwiftUI

// MARK: - Styled Text Field

/// A custom TextField with styled placeholder text
/// Used on dark backgrounds
struct StyledTextField: View {
    let placeholder: String
    @Binding var text: String
    var isFocused: Bool = false
    var validationState: ValidationState = .none
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var autocapitalization: TextInputAutocapitalization = .sentences

    enum ValidationState {
        case none, valid, invalid
    }

    private var borderColor: Color {
        switch validationState {
        case .valid:
            return .green
        case .invalid:
            return .red
        case .none:
            return isFocused ? AppTheme.Colors.inputBorderFocused : AppTheme.Colors.inputBorder
        }
    }

    var body: some View {
        TextField(
            "",
            text: $text,
            prompt: Text(placeholder)
                .foregroundColor(AppTheme.Colors.textPlaceholder)
        )
        .font(AppTheme.Typography.monoMedium())
        .foregroundColor(AppTheme.Colors.textPrimary)
        .tint(AppTheme.Colors.primary)
        .keyboardType(keyboardType)
        .textContentType(textContentType)
        .textInputAutocapitalization(autocapitalization)
        .autocorrectionDisabled()
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, 14)
        .background(
            isFocused
                ? AppTheme.Colors.primaryOverlayLight
                : AppTheme.Colors.inputBackground
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .stroke(borderColor, lineWidth: 1.5)
        )
        .cornerRadius(AppTheme.CornerRadius.medium)
        .animation(.easeInOut(duration: AppTheme.Animation.fast), value: isFocused)
        .animation(.easeInOut(duration: AppTheme.Animation.fast), value: validationState)
    }
}

// MARK: - Styled Text Field (Passport Page)

/// A custom TextField with styled placeholder text for passport page background
/// Used on light/cream backgrounds
struct StyledPassportPageTextField: View {
    let placeholder: String
    @Binding var text: String
    var isFocused: Bool = false
    var validationState: ValidationState = .none
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var autocapitalization: TextInputAutocapitalization = .sentences

    enum ValidationState {
        case none, valid, invalid
    }

    private var borderColor: Color {
        switch validationState {
        case .valid:
            return .green
        case .invalid:
            return .red
        case .none:
            return isFocused ? AppTheme.Colors.passportInputBorderFocused : AppTheme.Colors.passportInputBorder
        }
    }

    var body: some View {
        TextField(
            "",
            text: $text,
            prompt: Text(placeholder)
                .foregroundColor(AppTheme.Colors.passportTextPlaceholder)
        )
        .font(AppTheme.Typography.monoMedium())
        .foregroundColor(AppTheme.Colors.passportTextPrimary)
        .tint(AppTheme.Colors.passportInputBorderFocused)
        .keyboardType(keyboardType)
        .textContentType(textContentType)
        .textInputAutocapitalization(autocapitalization)
        .autocorrectionDisabled()
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, 14)
        .background(
            isFocused
                ? AppTheme.Colors.passportInputBackground.opacity(1.5)
                : AppTheme.Colors.passportInputBackground
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .stroke(borderColor, lineWidth: 2)
        )
        .cornerRadius(AppTheme.CornerRadius.medium)
        .animation(.easeInOut(duration: AppTheme.Animation.fast), value: isFocused)
        .animation(.easeInOut(duration: AppTheme.Animation.fast), value: validationState)
    }
}

// MARK: - Preview

#Preview("Dark Background") {
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()

        VStack(spacing: 20) {
            StyledTextField(
                placeholder: "traveler@example.com",
                text: .constant("")
            )

            StyledTextField(
                placeholder: "traveler@example.com",
                text: .constant(""),
                isFocused: true
            )

            StyledTextField(
                placeholder: "traveler@example.com",
                text: .constant("test@email.com"),
                validationState: .valid
            )
        }
        .padding()
    }
}

#Preview("Passport Page") {
    ZStack {
        LinearGradient(
            colors: [
                AppTheme.Colors.passportPageLight,
                AppTheme.Colors.passportPageDark,
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        VStack(spacing: 20) {
            StyledPassportPageTextField(
                placeholder: "Your name as it appears",
                text: .constant("")
            )

            StyledPassportPageTextField(
                placeholder: "Your name as it appears",
                text: .constant(""),
                isFocused: true
            )

            StyledPassportPageTextField(
                placeholder: "Your name as it appears",
                text: .constant("John Doe"),
                validationState: .valid
            )
        }
        .padding()
    }
}
