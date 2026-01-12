import SwiftUI

// MARK: - Register View
/// Passport-themed registration screen with email/password and social signup options
struct RegisterView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    // Form state
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var agreedToTerms = false
    
    // Focus state
    @FocusState private var focusedField: Field?
    
    // Navigation state
    @State private var showingLogin = false
    
    enum Field {
        case email, password, confirmPassword
    }
    
    // Validation
    private var passwordsMatch: Bool {
        password == confirmPassword
    }
    
    private var passwordStrength: Int {
        min(4, password.count / 2)
    }
    
    private var isFormValid: Bool {
        !email.isEmpty &&
        password.count >= 8 &&
        passwordsMatch &&
        agreedToTerms
    }
    
    private var confirmPasswordValidationState: PassportTextFieldStyle.ValidationState {
        if confirmPassword.isEmpty {
            return .none
        } else if passwordsMatch {
            return .valid
        } else {
            return .invalid
        }
    }
    
    var body: some View {
        AppBackgroundView {
            ScrollView {
                VStack(spacing: 0) {
                    // Back button
                    backButton
                        .padding(.top, AppTheme.Spacing.lg)
                    
                    // Header
                    headerSection
                        .padding(.top, AppTheme.Spacing.xl)
                        .padding(.bottom, AppTheme.Spacing.xl)
                    
                    // Signup Form
                    formSection
                    
                    // Social Signup
                    SocialAuthSection(
                        showLabels: true,
                        onGoogleTap: {
                            // TODO: Implement Google Sign Up
                        },
                        onAppleTap: {
                            // TODO: Implement Apple Sign Up
                        }
                    )
                    .padding(.vertical, AppTheme.Spacing.lg)
                    
                    Spacer(minLength: AppTheme.Spacing.xl)
                    
                    // Login link
                    loginSection
                        .padding(.bottom, AppTheme.Spacing.xl)
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingLogin) {
            LoginView()
        }
        .onTapGesture {
            focusedField = nil
        }
    }
    
    // MARK: - Back Button
    private var backButton: some View {
        HStack {
            Button("← Back") {
                dismiss()
            }
            .buttonStyle(BackButtonStyle())
            
            Spacer()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ApplicationBadge()
            
            Text("Begin Your Journey")
                .font(AppTheme.Typography.serifMedium())
                .foregroundColor(AppTheme.Colors.primary)
            
            Text("Create your account to start collecting memories from around the world.")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Form Section
    private var formSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Email field
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                Text("EMAIL ADDRESS")
                    .font(AppTheme.Typography.inputLabel())
                    .tracking(1)
                    .foregroundColor(AppTheme.Colors.textAccentMuted)
                
                TextField("traveler@example.com", text: $email)
                    .textFieldStyle(PassportTextFieldStyle(isFocused: focusedField == .email))
                    .focused($focusedField, equals: .email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
            }
            
            // Password field
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                Text("CREATE PASSWORD")
                    .font(AppTheme.Typography.inputLabel())
                    .tracking(1)
                    .foregroundColor(AppTheme.Colors.textAccentMuted)
                
                SecureField("Min. 8 characters", text: $password)
                    .textFieldStyle(PassportTextFieldStyle(isFocused: focusedField == .password))
                    .focused($focusedField, equals: .password)
                    .textContentType(.newPassword)
                
                PasswordStrengthIndicator(strength: passwordStrength)
            }
            
            // Confirm password field
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                Text("CONFIRM PASSWORD")
                    .font(AppTheme.Typography.inputLabel())
                    .tracking(1)
                    .foregroundColor(AppTheme.Colors.textAccentMuted)
                
                SecureField("Repeat password", text: $confirmPassword)
                    .textFieldStyle(PassportTextFieldStyle(
                        isFocused: focusedField == .confirmPassword,
                        validationState: confirmPasswordValidationState
                    ))
                    .focused($focusedField, equals: .confirmPassword)
                    .textContentType(.newPassword)
                
                if !confirmPassword.isEmpty && !passwordsMatch {
                    Text("Passwords do not match")
                        .font(AppTheme.Typography.monoCaption())
                        .foregroundColor(.red)
                }
            }
            
            // Terms checkbox
            termsSection
                .padding(.top, AppTheme.Spacing.xxs)
            
            // Error message
            if let error = authManager.error {
                Text(error)
                    .font(AppTheme.Typography.monoSmall())
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.top, AppTheme.Spacing.xxs)
            }
            
            // Signup button
            Button {
                focusedField = nil
                Task {
                    await authManager.register(
                        email: email,
                        password: password,
                        displayName: email.components(separatedBy: "@").first ?? "Traveler"
                    )
                }
            } label: {
                if authManager.isLoading {
                    HStack(spacing: AppTheme.Spacing.xxs) {
                        Text("🛫")
                        Text("PROCESSING...")
                    }
                } else {
                    Text("ISSUE PASSPORT →")
                }
            }
            .buttonStyle(PrimaryButtonStyle(isLoading: authManager.isLoading))
            .disabled(!isFormValid || authManager.isLoading)
            .padding(.top, AppTheme.Spacing.xxs)
        }
    }
    
    // MARK: - Terms Section
    private var termsSection: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.xs) {
            Button {
                agreedToTerms.toggle()
            } label: {
                Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                    .font(.system(size: 20))
                    .foregroundColor(agreedToTerms ? AppTheme.Colors.primary : AppTheme.Colors.textSecondary)
            }
            
            Text("I agree to the ")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.textSecondary)
            +
            Text("Terms of Service")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.primary)
            +
            Text(" and ")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.textSecondary)
            +
            Text("Privacy Policy")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.primary)
        }
    }
    
    // MARK: - Login Section
    private var loginSection: some View {
        HStack(spacing: AppTheme.Spacing.xxxs) {
            Text("Already have a passport?")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Button("Sign In") {
                showingLogin = true
            }
            .font(AppTheme.Typography.monoSmall())
            .fontWeight(.semibold)
            .foregroundColor(AppTheme.Colors.primary)
        }
    }
}

// MARK: - Application Badge
struct ApplicationBadge: View {
    var body: some View {
        VStack(spacing: AppTheme.Spacing.xxxs) {
            Text("APPLICATION FOR")
                .font(AppTheme.Typography.monoTiny())
                .tracking(2)
                .foregroundColor(AppTheme.Colors.primary.opacity(0.7))
            
            Text("DIGITAL PASSPORT")
                .font(AppTheme.Typography.monoMedium())
                .fontWeight(.semibold)
                .tracking(3)
                .foregroundColor(AppTheme.Colors.primary)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.xs)
        .background(AppTheme.Colors.primaryOverlayLight)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
        )
        .overlay(BadgeCorners())
        .cornerRadius(AppTheme.CornerRadius.small)
    }
}

// MARK: - Badge Corners
struct BadgeCorners: View {
    private let size: CGFloat = 8
    private let lineWidth: CGFloat = 2
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: CGPoint(x: 0, y: size))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: size, y: 0))
            }
            .stroke(AppTheme.Colors.primary, lineWidth: lineWidth)
            .position(x: size / 2, y: size / 2)
            
            Path { path in
                path.move(to: CGPoint(x: -size, y: 0))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 0, y: size))
            }
            .stroke(AppTheme.Colors.primary, lineWidth: lineWidth)
            .position(x: geometry.size.width - size / 2, y: size / 2)
            
            Path { path in
                path.move(to: CGPoint(x: 0, y: -size))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: size, y: 0))
            }
            .stroke(AppTheme.Colors.primary, lineWidth: lineWidth)
            .position(x: size / 2, y: geometry.size.height - size / 2)
            
            Path { path in
                path.move(to: CGPoint(x: -size, y: 0))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 0, y: -size))
            }
            .stroke(AppTheme.Colors.primary, lineWidth: lineWidth)
            .position(x: geometry.size.width - size / 2, y: geometry.size.height - size / 2)
        }
    }
}

// MARK: - Password Strength Indicator
struct PasswordStrengthIndicator: View {
    let strength: Int
    
    private func color(for level: Int) -> Color {
        if level > strength {
            return Color.white.opacity(0.1)
        }
        switch strength {
        case 1, 2:
            return .red
        case 3:
            return .orange
        case 4:
            return .green
        default:
            return Color.white.opacity(0.1)
        }
    }
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.xxxs) {
            ForEach(1...4, id: \.self) { level in
                RoundedRectangle(cornerRadius: 2)
                    .fill(color(for: level))
                    .frame(height: 3)
            }
        }
        .animation(.easeInOut(duration: AppTheme.Animation.fast), value: strength)
    }
}

// MARK: - Preview
#Preview {
    RegisterView()
        .environmentObject(AuthManager())
}