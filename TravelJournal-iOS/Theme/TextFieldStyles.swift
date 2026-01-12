import SwiftUI

// MARK: - Passport Text Field Style
/// Custom text field style with passport theme styling and validation states
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

// MARK: - Preview
#Preview {
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