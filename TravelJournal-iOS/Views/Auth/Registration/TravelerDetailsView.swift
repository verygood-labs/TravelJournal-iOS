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
    @State private var selectedCountry: PlaceSummaryDTO? = nil
    
    // Loading/Error state
    @State private var isCheckingUsername = false
    @State private var usernameError: String? = nil
    @State private var isUsernameAvailable: Bool? = nil
    @State private var lastCheckedUsername: String = ""
    
    // Country dropdown state
    @State private var allCountries: [PlaceSummaryDTO] = []
    @State private var isLoadingCountries = false
    @State private var countrySearchText = ""
    @State private var showCountryDropdown = false
    
    // Focus state
    @FocusState private var focusedField: Field?
    
    // Navigation
    @Environment(\.dismiss) var dismiss
    @State private var showingPassportPhoto = false
    @State private var showingPassportPreview = false
    @State private var showingPassportIssued = false
    @State private var isSubmitting = false
    
    // Photo state (shared with PassportPhotoPageContent)
    @State private var selectedImage: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    
    enum Field {
        case fullName, username, country
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
    
    // Filter countries based on search text
    private var filteredCountries: [PlaceSummaryDTO] {
        let trimmed = countrySearchText.trimmingCharacters(in: .whitespaces).lowercased()
        if trimmed.isEmpty {
            return allCountries
        }
        return allCountries.filter { $0.name.lowercased().contains(trimmed) }
    }
    
    private var currentStep: Int {
        if showingPassportPreview {
            return 4
        } else if showingPassportPhoto {
            return 3
        } else {
            return 2
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress bar stays in place during transition
            AppBackgroundView {
                RegistrationProgressBar(
                    currentStep: currentStep,
                    totalSteps: 4
                )
            }
            .frame(height: 80)
            .animation(.easeInOut(duration: 0.3), value: currentStep)
            
            // Page content with turn animation (only the form flips)
            // Step 2 -> Step 3 transition
            PageTurnCover(isPresented: $showingPassportPhoto) {
                travelerDetailsFormContent
            } destination: {
                // Step 3 -> Step 4 transition
                PageTurnCover(isPresented: $showingPassportPreview) {
                    PassportPhotoFormContent(
                        selectedImage: $selectedImage,
                        showingImagePicker: $showingImagePicker,
                        showingCamera: $showingCamera
                    )
                } destination: {
                    PassportPreviewFormContent(
                        fullName: fullName,
                        username: username,
                        nationalityName: selectedCountry?.name ?? "",
                        passportPhoto: selectedImage
                    )
                }
            }
            
            // Bottom navigation stays in place during transition
            bottomNavigation
                .animation(.easeInOut(duration: 0.3), value: currentStep)
        }
        .background(AppTheme.Colors.backgroundDark)
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await loadCountries()
            }
        }
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
        .fullScreenCover(isPresented: $showingPassportIssued) {
            PassportIssuedSheet(
                fullName: fullName,
                username: username,
                nationalityName: selectedCountry?.name ?? "",
                passportPhoto: selectedImage,
                onContinue: {
                    // TODO: Navigate to main app / home screen
                    // For now, just dismiss the sheet
                    showingPassportIssued = false
                    dismiss()
                }
            )
        }
    }
    
    // MARK: - Traveler Details Form Content (only the passport page that flips)
    private var travelerDetailsFormContent: some View {
        PassportPageBackgroundView {
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
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                Text("HOME COUNTRY")
                    .font(AppTheme.Typography.inputLabel())
                    .tracking(1)
                    .foregroundColor(AppTheme.Colors.passportTextMuted)
                
                VStack(spacing: 0) {
                    // Input field
                    HStack {
                        if let country = selectedCountry {
                            // Show selected country
                            Text(country.name)
                                .font(AppTheme.Typography.monoMedium())
                                .foregroundColor(AppTheme.Colors.passportTextPrimary)
                            
                            Spacer()
                            
                            Button {
                                selectedCountry = nil
                                countrySearchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppTheme.Colors.passportTextMuted)
                            }
                        } else {
                            // Show search input
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.Colors.passportTextMuted)
                            
                            TextField(
                                "",
                                text: $countrySearchText,
                                prompt: Text(isLoadingCountries ? "Loading countries..." : "Search for a country...")
                                    .foregroundColor(AppTheme.Colors.passportTextPlaceholder)
                            )
                            .font(AppTheme.Typography.monoMedium())
                            .foregroundColor(AppTheme.Colors.passportTextPrimary)
                            .focused($focusedField, equals: .country)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.words)
                            .disabled(isLoadingCountries)
                            .onTapGesture {
                                if !isLoadingCountries {
                                    showCountryDropdown = true
                                }
                            }
                            
                            if isLoadingCountries {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.sm)
                    .padding(.vertical, 14)
                    .background(AppTheme.Colors.passportInputBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: showCountryDropdown ? 0 : AppTheme.CornerRadius.medium)
                            .stroke(
                                focusedField == .country
                                    ? AppTheme.Colors.passportInputBorderFocused
                                    : AppTheme.Colors.passportInputBorder,
                                lineWidth: 2
                            )
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: showCountryDropdown ? 0 : AppTheme.CornerRadius.medium)
                    )
                    
                    // Dropdown list
                    if showCountryDropdown && !filteredCountries.isEmpty {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(filteredCountries) { country in
                                    Button {
                                        selectedCountry = country
                                        countrySearchText = ""
                                        showCountryDropdown = false
                                        focusedField = nil
                                    } label: {
                                        HStack {
                                            Text(country.name)
                                                .font(AppTheme.Typography.monoMedium())
                                                .foregroundColor(AppTheme.Colors.passportTextPrimary)
                                            Spacer()
                                        }
                                        .padding(.horizontal, AppTheme.Spacing.sm)
                                        .padding(.vertical, 12)
                                        .background(AppTheme.Colors.passportInputBackground)
                                    }
                                    
                                    if country.id != filteredCountries.last?.id {
                                        Divider()
                                            .background(AppTheme.Colors.passportInputBorder)
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 180)
                        .background(AppTheme.Colors.passportInputBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(AppTheme.Colors.passportInputBorder, lineWidth: 2)
                        )
                        .clipShape(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        )
                    }
                }
                
                Text(selectedCountry != nil ? "Your home country for your passport" : "Type to search for your country")
                    .font(AppTheme.Typography.monoCaption())
                    .foregroundColor(AppTheme.Colors.passportTextMuted)
            }
            .onChange(of: countrySearchText) { _, newValue in
                // Show dropdown when user starts typing
                if !newValue.isEmpty && selectedCountry == nil {
                    showCountryDropdown = true
                }
            }
            .onChange(of: focusedField) { _, newValue in
                if newValue == .country {
                    showCountryDropdown = true
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        showCountryDropdown = false
                    }
                }
            }
        }
    }
    
    // MARK: - Load Countries
    private func loadCountries() async {
        guard allCountries.isEmpty else { return }
        
        isLoadingCountries = true
        
        do {
            let countries = try await PlaceService.shared.getAllCountries()
            await MainActor.run {
                allCountries = countries.sorted { $0.name < $1.name }
                isLoadingCountries = false
            }
        } catch {
            await MainActor.run {
                isLoadingCountries = false
                // Could show an error, but for now just leave empty
            }
        }
    }
    
    // MARK: - Bottom Navigation
    private var bottomNavigation: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            // Back button
            Button {
                handleBack()
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
            .disabled(isSubmitting)
            
            // Continue/Submit button
            Button {
                handleContinue()
            } label: {
                HStack(spacing: AppTheme.Spacing.xxxs) {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.backgroundDark))
                            .scaleEffect(0.8)
                    }
                    Text(showingPassportPreview ? "SUBMIT" : "CONTINUE")
                        .font(AppTheme.Typography.button())
                        .tracking(1)
                    if !isSubmitting {
                        Image(systemName: showingPassportPreview ? "checkmark" : "arrow.right")
                            .font(.system(size: 12, weight: .medium))
                    }
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(isContinueDisabled)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(AppTheme.Colors.backgroundDark)
    }
    
    private var isContinueDisabled: Bool {
        if isSubmitting { return true }
        if showingPassportPreview { return false }
        if showingPassportPhoto { return !hasPhoto }
        return !isFormValid
    }
    
    private func handleBack() {
        if showingPassportPreview {
            // Go back to photo step
            showingPassportPreview = false
        } else if showingPassportPhoto {
            // Go back to traveler details
            showingPassportPhoto = false
        } else {
            // Go back to previous screen
            dismiss()
        }
    }
    
    private func handleContinue() {
        if showingPassportPreview {
            // Submit registration
            Task {
                await submitRegistration()
            }
        } else if showingPassportPhoto {
            // Proceed to preview
            proceedFromPhotoStep()
        } else {
            // Proceed from traveler details step
            focusedField = nil
            Task {
                await proceedToNextStep()
            }
        }
    }
    
    private var hasPhoto: Bool {
        selectedImage != nil
    }
    
    private func proceedFromPhotoStep() {
        guard hasPhoto else { return }
        // Proceed to preview step (Step 4)
        showingPassportPreview = true
    }
    
    // MARK: - Submit Registration
    private func submitRegistration() async {
        guard selectedCountry != nil else { return }
        
        isSubmitting = true
        
        // TODO: Implement actual registration API call
        // For now, simulate a delay
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        await MainActor.run {
            isSubmitting = false
            showingPassportIssued = true
        }
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
        
        // Country already has UUID from pre-seeded data
        // nationalityId = country.id
        print("Selected country: \(country.name) with ID: \(country.id)")
        
        showingPassportPhoto = true
    }
}

// MARK: - Preview
#Preview {
    TravelerDetailsView(
        email: "test@example.com",
        password: "password123"
    )
}