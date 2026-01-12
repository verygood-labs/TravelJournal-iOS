import SwiftUI

// MARK: - Login View
/// Passport-themed login screen with email/password and social login options
struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    // Form state
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    
    // Focus state
    @FocusState private var focusedField: Field?
    
    // Navigation state
    @State private var showingRegister = false
    @State private var showingForgotPassword = false
    
    enum Field {
        case email, password
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
                        .padding(.bottom, AppTheme.Spacing.xxl)
                    
                    // Login Form
                    formSection
                    
                    // Social Login
                    SocialAuthSection(
                        showLabels: false,
                        onGoogleTap: {
                            // TODO: Implement Google Sign In
                        },
                        onAppleTap: {
                            // TODO: Implement Apple Sign In
                        }
                    )
                    .padding(.vertical, AppTheme.Spacing.xl)
                    
                    Spacer(minLength: AppTheme.Spacing.xl)
                    
                    // Sign up link
                    signUpSection
                        .padding(.bottom, AppTheme.Spacing.xl)
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingRegister) {
            RegisterView()
        }
        .sheet(isPresented: $showingForgotPassword) {
            ForgotPasswordView()
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
        VStack(spacing: AppTheme.Spacing.sm) {
            AnimatedGlobeView(size: 60)
                .padding(.bottom, AppTheme.Spacing.xxs)
            
            Text("Welcome Back")
                .font(AppTheme.Typography.serifMedium())
                .foregroundColor(AppTheme.Colors.primary)
            
            Text("Enter your credentials to continue your journey")
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
                Text("PASSWORD")
                    .font(AppTheme.Typography.inputLabel())
                    .tracking(1)
                    .foregroundColor(AppTheme.Colors.textAccentMuted)
                
                HStack(spacing: 0) {
                    Group {
                        if showPassword {
                            TextField("••••••••", text: $password)
                        } else {
                            SecureField("••••••••", text: $password)
                        }
                    }
                    .focused($focusedField, equals: .password)
                    .textContentType(.password)
                    
                    Button {
                        showPassword.toggle()
                    } label: {
                        Text(showPassword ? "🙈" : "👁️")
                            .font(.system(size: 16))
                    }
                }
                .textFieldStyle(PassportTextFieldStyle(isFocused: focusedField == .password))
            }
            
            // Forgot password
            HStack {
                Spacer()
                Button("Forgot passport code?") {
                    showingForgotPassword = true
                }
                .buttonStyle(TextLinkButtonStyle())
            }
            
            // Error message
            if let error = authManager.error {
                Text(error)
                    .font(AppTheme.Typography.monoSmall())
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.top, AppTheme.Spacing.xxs)
            }
            
            // Login button
            Button {
                focusedField = nil
                Task {
                    await authManager.login(email: email, password: password)
                }
            } label: {
                if authManager.isLoading {
                    HStack(spacing: AppTheme.Spacing.xxs) {
                        Text("✈️")
                        Text("BOARDING...")
                    }
                } else {
                    Text("ENTER PASSPORT")
                }
            }
            .buttonStyle(PrimaryButtonStyle(isLoading: authManager.isLoading))
            .disabled(email.isEmpty || password.isEmpty || authManager.isLoading)
            .padding(.top, AppTheme.Spacing.xxs)
        }
    }
    
    // MARK: - Sign Up Section
    private var signUpSection: some View {
        HStack(spacing: AppTheme.Spacing.xxxs) {
            Text("New traveler?")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Button("Create Passport") {
                showingRegister = true
            }
            .font(AppTheme.Typography.monoSmall())
            .fontWeight(.semibold)
            .foregroundColor(AppTheme.Colors.primary)
        }
    }
}

// MARK: - Preview
#Preview {
    LoginView()
        .environmentObject(AuthManager())
}