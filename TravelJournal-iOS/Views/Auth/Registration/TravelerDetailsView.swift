import SwiftUI

// MARK: - Traveler Details View
/// Step 2 of registration: Collect name, username, and home country
struct TravelerDetailsView: View {
    // Form data passed from previous step
    let email: String
    let password: String
    
    // Form state
    @State private var fullName = ""
    @State private var username = ""
    @State private var selectedCountryId: String? = nil
    @State private var showingCountryPicker = false
    
    // Loading/Error state
    @State private var isCheckingUsername = false
    @State private var usernameError: String? = nil
    
    // Focus state
    @FocusState private var focusedField: Field?
    
    // Navigation
    @Environment(\.dismiss) var dismiss
    @State private var showingNextStep = false
    
    enum Field {
        case fullName, username
    }
    
    private var isFormValid: Bool {
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !username.trimmingCharacters(in: .whitespaces).isEmpty &&
        isValidUsername(username)
    }
    
    private func isValidUsername(_ username: String) -> Bool {
        let pattern = "^[a-zA-Z0-9_]+$"
        return username.range(of: pattern, options: .regularExpression) != nil
    }
    
    private var usernameBorderColor: Color {
        if usernameError != nil {
            return .red
        }
        return focusedField == .username
            ? AppTheme.Colors.inputBorderFocused
            : AppTheme.Colors.inputBorder
    }
    
    var body: some View {
        AppBackgroundView {
            VStack(spacing: 0) {
                // Progress bar
                RegistrationProgressBar(currentStep: 2, totalSteps: 4)
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        headerSection
                            .padding(.top, AppTheme.Spacing.xxl)
                            .padding(.bottom, AppTheme.Spacing.xl)
                        
                        // Form
                        formSection
                            .padding(.horizontal, AppTheme.Spacing.lg)
                        
                        Spacer(minLength: AppTheme.Spacing.xxxl)
                    }
                }
                
                // Bottom navigation
                bottomNavigation
            }
        }
        .navigationBarHidden(true)
        .onTapGesture {
            focusedField = nil
        }
        .onChange(of: username) { _, _ in
            usernameError = nil
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Text("✦ IDENTIFICATION PAGE ✦")
                .font(AppTheme.Typography.monoSmall())
                .tracking(2)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Text("Traveler Details")
                .font(AppTheme.Typography.serifMedium())
                .foregroundColor(AppTheme.Colors.primary)
            
            Text("Let's set up your passport identification.")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
    
    // MARK: - Form Section
    private var formSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Full Name field
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                Text("FULL NAME")
                    .font(AppTheme.Typography.inputLabel())
                    .tracking(1)
                    .foregroundColor(AppTheme.Colors.textAccentMuted)
                
                TextField("Your name as it appears", text: $fullName)
                    .textFieldStyle(PassportTextFieldStyle(isFocused: focusedField == .fullName))
                    .focused($focusedField, equals: .fullName)
                    .textContentType(.name)
                    .autocorrectionDisabled()
                
                Text("This will appear on your passport")
                    .font(AppTheme.Typography.monoCaption())
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            // Username field
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                Text("HANDLE / USERNAME")
                    .font(AppTheme.Typography.inputLabel())
                    .tracking(1)
                    .foregroundColor(AppTheme.Colors.textAccentMuted)
                
                HStack(spacing: 0) {
                    Text("@")
                        .font(AppTheme.Typography.monoMedium())
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .padding(.leading, AppTheme.Spacing.sm)
                    
                    TextField("wanderlust", text: $username)
                        .font(AppTheme.Typography.monoMedium())
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .focused($focusedField, equals: .username)
                        .textContentType(.username)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .padding(.trailing, AppTheme.Spacing.sm)
                        .padding(.vertical, 14)
                }
                .background(
                    focusedField == .username
                        ? AppTheme.Colors.primaryOverlayLight
                        : AppTheme.Colors.inputBackground
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .stroke(usernameBorderColor, lineWidth: 1.5)
                )
                .cornerRadius(AppTheme.CornerRadius.medium)
                .animation(.easeInOut(duration: AppTheme.Animation.fast), value: focusedField)
                
                if let error = usernameError {
                    Text(error)
                        .font(AppTheme.Typography.monoCaption())
                        .foregroundColor(.red)
                } else {
                    Text("Choose a unique handle for your profile")
                        .font(AppTheme.Typography.monoCaption())
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
            
            // Home Country field
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                Text("HOME COUNTRY")
                    .font(AppTheme.Typography.inputLabel())
                    .tracking(1)
                    .foregroundColor(AppTheme.Colors.textAccentMuted)
                
                Button {
                    showingCountryPicker = true
                } label: {
                    HStack {
                        Text(selectedCountryId == nil ? "Select your country" : "Country Selected")
                            .font(AppTheme.Typography.monoMedium())
                            .foregroundColor(
                                selectedCountryId == nil
                                    ? AppTheme.Colors.textSecondary
                                    : AppTheme.Colors.textPrimary
                            )
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    .padding(.horizontal, AppTheme.Spacing.sm)
                    .padding(.vertical, 14)
                    .background(AppTheme.Colors.inputBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                            .stroke(AppTheme.Colors.inputBorder, lineWidth: 1.5)
                    )
                    .cornerRadius(AppTheme.CornerRadius.medium)
                }
            }
        }
    }
    
    // MARK: - Bottom Navigation
    private var bottomNavigation: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            // Back button
            Button {
                dismiss()
            } label: {
                HStack(spacing: AppTheme.Spacing.xxxs) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 12, weight: .medium))
                    Text("BACK")
                        .font(AppTheme.Typography.button())
                        .tracking(1)
                }
            }
            .buttonStyle(SecondaryButtonStyle())
            .frame(width: 120)
            
            // Continue button
            Button {
                focusedField = nil
                Task {
                    await checkUsernameAndProceed()
                }
            } label: {
                HStack(spacing: AppTheme.Spacing.xxxs) {
                    Text(isCheckingUsername ? "CHECKING..." : "CONTINUE")
                        .font(AppTheme.Typography.button())
                        .tracking(1)
                    if !isCheckingUsername {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .medium))
                    }
                }
            }
            .buttonStyle(PrimaryButtonStyle(isLoading: isCheckingUsername))
            .disabled(!isFormValid || isCheckingUsername)
            .opacity(isFormValid ? 1 : 0.5)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(AppTheme.Colors.backgroundDark)
    }
    
    // MARK: - Username Check
    private func checkUsernameAndProceed() async {
        isCheckingUsername = true
        usernameError = nil
        
        do {
            let response = try await AuthService.shared.checkUsername(userName: username)
            
            if response.available {
                // TODO: Navigate to next step (profile picture)
                showingNextStep = true
            } else {
                usernameError = response.message ?? "This username is already taken."
            }
        } catch {
            usernameError = "Unable to verify username. Please try again."
        }
        
        isCheckingUsername = false
    }
}

// MARK: - Preview
#Preview {
    TravelerDetailsView(
        email: "test@example.com",
        password: "password123"
    )
}
