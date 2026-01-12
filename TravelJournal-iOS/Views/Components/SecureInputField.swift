import SwiftUI

// MARK: - Eye Icon
/// Custom eye icon drawn with SwiftUI paths
struct EyeIcon: View {
    var isOpen: Bool = true
    var size: CGFloat = 20
    
    var body: some View {
        ZStack {
            // Eye outline (always visible)
            Path { path in
                let width = size
                let height = size * 0.5
                let centerY = size / 2
                
                // Top curve
                path.move(to: CGPoint(x: 0, y: centerY))
                path.addQuadCurve(
                    to: CGPoint(x: width, y: centerY),
                    control: CGPoint(x: width / 2, y: centerY - height)
                )
                // Bottom curve
                path.addQuadCurve(
                    to: CGPoint(x: 0, y: centerY),
                    control: CGPoint(x: width / 2, y: centerY + height)
                )
            }
            .stroke(AppTheme.Colors.textSecondary, lineWidth: 1.5)
            
            // Pupil (only when open)
            if isOpen {
                Circle()
                    .fill(AppTheme.Colors.textSecondary)
                    .frame(width: size * 0.3, height: size * 0.3)
            }
            
            // Diagonal slash line when closed
            if !isOpen {
                Path { path in
                    path.move(to: CGPoint(x: size * 0.1, y: size * 0.1))
                    path.addLine(to: CGPoint(x: size * 0.9, y: size * 0.9))
                }
                .stroke(AppTheme.Colors.textSecondary, lineWidth: 2)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Secure Input Field
/// A text field with integrated password visibility toggle
struct SecureInputField: View {
    let placeholder: String
    @Binding var text: String
    var isFocused: Bool = false
    var validationState: PassportTextFieldStyle.ValidationState = .none
    
    @State private var isSecure: Bool = true
    
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
        HStack(spacing: AppTheme.Spacing.xs) {
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .font(AppTheme.Typography.monoMedium())
            .foregroundColor(AppTheme.Colors.textPrimary)
            
            Button {
                isSecure.toggle()
            } label: {
                EyeIcon(isOpen: !isSecure, size: 20)
            }
            .buttonStyle(.plain)
        }
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
            SecureInputField(
                placeholder: "Password",
                text: .constant(""),
                isFocused: false
            )
            
            SecureInputField(
                placeholder: "Password",
                text: .constant("mypassword"),
                isFocused: true
            )
            
            HStack(spacing: 20) {
                EyeIcon(isOpen: true, size: 24)
                EyeIcon(isOpen: false, size: 24)
            }
        }
        .padding()
    }
}
