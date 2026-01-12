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
    @State private var selectedCountry: LocationSearchResult? = nil
    
    // Loading/Error state
    @State private var isCheckingUsername = false
    @State private var usernameError: String? = nil
    @State private var isUsernameAvailable: Bool? = nil
    @State private var lastCheckedUsername: String = ""
    @State private var isResolvingCountry = false
    @State private var countryError: String? = nil
    
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
        isValidUsername(username) &&
        isUsernameAvailable == true &&
        selectedCountry != nil
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
            ? AppTheme.Colors.passportInputBorderFocused
            : AppTheme.Colors.passportInputBorder
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress bar with app background
            AppBackgroundView {
                RegistrationProgressBar(currentStep: 2, totalSteps: 4)
            }
            .frame(height: 80)
            
            // Passport page content
            PassportPageBackgroundView {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 0) {
                            // Header
                            headerSection
                                .padding(.top, AppTheme.Spacing.xl)
                                .padding(.bottom, AppTheme.Spacing.lg)
                            
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
        }
        .background(AppTheme.Colors.backgroundDark)
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .onTapGesture {
            focusedField = nil
        }
        .onChange(of: username) { _, _ in
            usernameError = nil
            isUsernameAvailable = nil
        }
        .onChange(of: focusedField) { oldValue, newValue in
            // Check username when user leaves the username field
            if oldValue == .username && newValue != .username {
                let trimmedUsername = username.trimmingCharacters(in: .whitespaces)
                if !trimmedUsername.isEmpty && 
                   isValidUsername(trimmedUsername) && 
                   trimmedUsername != lastCheckedUsername {
                    Task {
                        await checkUsernameAvailability()
                    }
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Text("✦ IDENTIFICATION PAGE ✦")
                .font(AppTheme.Typography.monoSmall())
                .tracking(2)
                .foregroundColor(AppTheme.Colors.passportTextMuted)
            
            Text("Traveler Details")
                .font(AppTheme.Typography.serifMedium())
                .foregroundColor(AppTheme.Colors.passportTextPrimary)
            
            Text("Let's set up your passport identification.")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.passportTextSecondary)
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
                    .foregroundColor(AppTheme.Colors.passportTextMuted)
                
                TextField(
                    "",
                    text: $fullName,
                    prompt: Text("Your name as it appears")
                        .foregroundColor(AppTheme.Colors.passportTextPlaceholder)
                )
                .textFieldStyle(PassportPageTextFieldStyle(isFocused: focusedField == .fullName))
                .focused($focusedField, equals: .fullName)
                .textContentType(.name)
                .autocorrectionDisabled()
                
                Text("This will appear on your passport")
                    .font(AppTheme.Typography.monoCaption())
                    .foregroundColor(AppTheme.Colors.passportTextMuted)
            }
            
            // Username field
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                Text("HANDLE / USERNAME")
                    .font(AppTheme.Typography.inputLabel())
                    .tracking(1)
                    .foregroundColor(AppTheme.Colors.passportTextMuted)
                
                HStack(spacing: 0) {
                    Text("@")
                        .font(AppTheme.Typography.monoMedium())
                        .foregroundColor(AppTheme.Colors.passportTextMuted)
                        .padding(.leading, AppTheme.Spacing.sm)
                    
                    TextField(
                        "",
                        text: $username,
                        prompt: Text("wanderlust")
                            .foregroundColor(AppTheme.Colors.passportTextPlaceholder)
                    )
                    .font(AppTheme.Typography.monoMedium())
                    .foregroundColor(AppTheme.Colors.passportTextPrimary)
                    .focused($focusedField, equals: .username)
                    .textContentType(.username)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .padding(.vertical, 14)
                    
                    // Status indicator
                    if isCheckingUsername {
                        ProgressView()
                            .scaleEffect(0.8)
                            .padding(.trailing, AppTheme.Spacing.sm)
                    } else if isUsernameAvailable == true {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .padding(.trailing, AppTheme.Spacing.sm)
                    } else if isUsernameAvailable == false {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .padding(.trailing, AppTheme.Spacing.sm)
                    } else {
                        Spacer()
                            .frame(width: AppTheme.Spacing.sm)
                    }
                }
                .background(
                    focusedField == .username
                        ? AppTheme.Colors.passportInputBackground.opacity(1.5)
                        : AppTheme.Colors.passportInputBackground
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .stroke(usernameBorderColor, lineWidth: 2)
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
                        .foregroundColor(AppTheme.Colors.passportTextMuted)
                }
            }
            
            // Home Country field
            SearchableDropdown<LocationSearchResult>(
                label: "Home Country",
                placeholder: "Search for a country...",
                helperText: "Type to search for your country",
                selectedHelperText: "Your home country for your passport",
                selectedItem: $selectedCountry,
                displayText: { $0.displayNameWithFlag },
                search: { query in
                    try await CountryService.shared.searchCountries(query: query)
                }
            )
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
                    await proceedToNextStep()
                }
            } label: {
                HStack(spacing: AppTheme.Spacing.xxxs) {
                    Text(isResolvingCountry ? "SAVING..." : "CONTINUE")
                        .font(AppTheme.Typography.button())
                        .tracking(1)
                    if !isResolvingCountry {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .medium))
                    }
                }
            }
            .buttonStyle(PrimaryButtonStyle(isLoading: isResolvingCountry))
            .disabled(!isFormValid || isResolvingCountry)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(AppTheme.Colors.backgroundDark)
    }
    
    // MARK: - Username Check
    private func checkUsernameAvailability() async {
        let trimmedUsername = username.trimmingCharacters(in: .whitespaces)
        guard !trimmedUsername.isEmpty else { return }
        
        isCheckingUsername = true
        usernameError = nil
        isUsernameAvailable = nil
        
        do {
            let response = try await AuthService.shared.checkUsername(userName: trimmedUsername)
            lastCheckedUsername = trimmedUsername
            
            if response.available {
                isUsernameAvailable = true
            } else {
                isUsernameAvailable = false
                usernameError = response.message ?? "This username is already taken."
            }
        } catch {
            isUsernameAvailable = nil
            usernameError = "Unable to verify username. Please try again."
        }
        
        isCheckingUsername = false
    }
    
    // MARK: - Proceed to Next Step
    private func proceedToNextStep() async {
        guard let country = selectedCountry else { return }
        
        isResolvingCountry = true
        countryError = nil
        
        do {
            // Call getOrCreate to save the country and get its UUID
            let placeDTO = try await PlaceService.shared.getOrCreate(from: country)
            
            // TODO: Navigate to next step with the resolved data
            // nationalityId = placeDTO.id
            print("Resolved country: \(placeDTO.name) with ID: \(placeDTO.id)")
            
            showingNextStep = true
        } catch {
            countryError = "Unable to save country. Please try again."
        }
        
        isResolvingCountry = false
    }
}

// MARK: - Preview
#Preview {
    TravelerDetailsView(
        email: "test@example.com",
        password: "password123"
    )
}
