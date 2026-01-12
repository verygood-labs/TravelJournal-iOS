import SwiftUI

// MARK: - Passport Text Field Style
/// Custom text field style with passport theme styling and validation states
/// Used on dark backgrounds
struct PassportTextFieldStyle: TextFieldStyle {
    var isFocused: Bool = false
    var validationState: ValidationState = .none
    
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
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(AppTheme.Typography.monoMedium())
            .foregroundColor(AppTheme.Colors.textPrimary)
            .tint(AppTheme.Colors.primary)
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

// MARK: - Passport Page Text Field Style
/// Custom text field style for passport page (cream/paper background)
/// Used on light passport page backgrounds
struct PassportPageTextFieldStyle: TextFieldStyle {
    var isFocused: Bool = false
    var validationState: ValidationState = .none
    
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
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(AppTheme.Typography.monoMedium())
            .foregroundColor(AppTheme.Colors.passportTextPrimary)
            .tint(AppTheme.Colors.passportInputBorderFocused)
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
            TextField("Default", text: .constant(""))
                .textFieldStyle(PassportTextFieldStyle())
            
            TextField("Focused", text: .constant(""))
                .textFieldStyle(PassportTextFieldStyle(isFocused: true))
            
            TextField("Valid", text: .constant("test@email.com"))
                .textFieldStyle(PassportTextFieldStyle(validationState: .valid))
            
            TextField("Invalid", text: .constant("bad input"))
                .textFieldStyle(PassportTextFieldStyle(validationState: .invalid))
        }
        .padding()
    }
}

#Preview("Passport Page Background") {
    ZStack {
        LinearGradient(
            colors: [
                AppTheme.Colors.passportPageLight,
                AppTheme.Colors.passportPageDark
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        VStack(spacing: 20) {
            TextField("Default", text: .constant(""))
                .textFieldStyle(PassportPageTextFieldStyle())
            
            TextField("Focused", text: .constant(""))
                .textFieldStyle(PassportPageTextFieldStyle(isFocused: true))
            
            TextField("Valid", text: .constant("test@email.com"))
                .textFieldStyle(PassportPageTextFieldStyle(validationState: .valid))
            
            TextField("Invalid", text: .constant("bad input"))
                .textFieldStyle(PassportPageTextFieldStyle(validationState: .invalid))
        }
        .padding()
    }
}