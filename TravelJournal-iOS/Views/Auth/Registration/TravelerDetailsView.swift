import SwiftUI

// MARK: - Traveler Details View

/// Step 2 of registration: Collect name, username, and home country
struct TravelerDetailsView: View {
    /// ViewModel handles all business logic
    @StateObject private var viewModel: RegistrationViewModel

    /// Focus state (UI-only, stays in view)
    @FocusState private var focusedField: Field?

    // Image picker state (UI-only)
    @State private var showingImagePicker = false
    @State private var showingCamera = false

    /// Navigation
    @Environment(\.dismiss) var dismiss

    enum Field {
        case fullName, username, country
    }

    // MARK: - Initialization

    init(email: String, password: String, authManager: AuthManager) {
        _viewModel = StateObject(wrappedValue: RegistrationViewModel(
            email: email,
            password: password,
            authManager: authManager
        ))
    }

    // MARK: - Computed Properties

    private var usernameBorderColor: Color {
        if viewModel.usernameError != nil {
            return .red
        }
        return focusedField == .username
            ? AppTheme.Colors.passportInputBorderFocused
            : AppTheme.Colors.passportInputBorder
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Progress bar stays in place during transition
            AppBackgroundView {
                RegistrationProgressBar(
                    currentStep: viewModel.currentStep,
                    totalSteps: 4
                )
            }
            .frame(height: 80)
            .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)

            // Page content with turn animation (only the form flips)
            // Step 2 -> Step 3 transition
            PageTurnCover(isPresented: $viewModel.showingPassportPhoto) {
                travelerDetailsFormContent
            } destination: {
                // Step 3 -> Step 4 transition
                PageTurnCover(isPresented: $viewModel.showingPassportPreview) {
                    PassportPhotoFormContent(
                        selectedImage: $viewModel.selectedImage,
                        showingImagePicker: $showingImagePicker,
                        showingCamera: $showingCamera
                    )
                } destination: {
                    PassportPreviewFormContent(
                        fullName: viewModel.fullName,
                        username: viewModel.username,
                        nationalityName: viewModel.selectedCountry?.name ?? "",
                        passportPhoto: viewModel.selectedImage
                    )
                }
            }

            // Bottom navigation stays in place during transition
            bottomNavigation
                .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
        }
        .background(AppTheme.Colors.backgroundDark)
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await viewModel.loadCountries()
            }
        }
        .onTapGesture {
            focusedField = nil
        }
        .onChange(of: viewModel.username) { _, _ in
            viewModel.onUsernameChanged()
        }
        .onChange(of: focusedField) { oldValue, newValue in
            // Check username when user leaves the username field
            if oldValue == .username && newValue != .username {
                Task {
                    await viewModel.checkUsernameAvailability()
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.showingPassportIssued) {
            PassportIssuedSheet(
                fullName: viewModel.fullName,
                username: viewModel.username,
                nationalityName: viewModel.selectedCountry?.name ?? "",
                passportPhoto: viewModel.selectedImage,
                onContinue: {
                    // TODO: Navigate to main app / home screen
                    viewModel.showingPassportIssued = false
                    dismiss()
                }
            )
        }
        .alert("Registration Error", isPresented: .init(
            get: { viewModel.registrationError != nil },
            set: { if !$0 { viewModel.registrationError = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.registrationError ?? "")
        }
    }

    // MARK: - Traveler Details Form Content

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
                    text: $viewModel.fullName,
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
                        text: $viewModel.username,
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
                    if viewModel.isCheckingUsername {
                        ProgressView()
                            .scaleEffect(0.8)
                            .padding(.trailing, AppTheme.Spacing.sm)
                    } else if viewModel.isUsernameAvailable == true {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .padding(.trailing, AppTheme.Spacing.sm)
                    } else if viewModel.isUsernameAvailable == false {
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

                if let error = viewModel.usernameError {
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
                        if let country = viewModel.selectedCountry {
                            // Show selected country
                            Text(country.name)
                                .font(AppTheme.Typography.monoMedium())
                                .foregroundColor(AppTheme.Colors.passportTextPrimary)

                            Spacer()

                            Button {
                                viewModel.clearSelectedCountry()
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
                                text: $viewModel.countrySearchText,
                                prompt: Text(viewModel.isLoadingCountries ? "Loading countries..." : "Search for a country...")
                                    .foregroundColor(AppTheme.Colors.passportTextPlaceholder)
                            )
                            .font(AppTheme.Typography.monoMedium())
                            .foregroundColor(AppTheme.Colors.passportTextPrimary)
                            .focused($focusedField, equals: .country)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.words)
                            .disabled(viewModel.isLoadingCountries)
                            .onTapGesture {
                                if !viewModel.isLoadingCountries {
                                    viewModel.showCountryDropdown = true
                                }
                            }

                            if viewModel.isLoadingCountries {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.sm)
                    .padding(.vertical, 14)
                    .background(AppTheme.Colors.passportInputBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: viewModel.showCountryDropdown ? 0 : AppTheme.CornerRadius.medium)
                            .stroke(
                                focusedField == .country
                                    ? AppTheme.Colors.passportInputBorderFocused
                                    : AppTheme.Colors.passportInputBorder,
                                lineWidth: 2
                            )
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: viewModel.showCountryDropdown ? 0 : AppTheme.CornerRadius.medium)
                    )

                    // Dropdown list
                    if viewModel.showCountryDropdown && !viewModel.filteredCountries.isEmpty {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(viewModel.filteredCountries) { country in
                                    Button {
                                        viewModel.selectCountry(country)
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

                                    if country.id != viewModel.filteredCountries.last?.id {
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

                Text(viewModel.selectedCountry != nil ? "Your home country for your passport" : "Type to search for your country")
                    .font(AppTheme.Typography.monoCaption())
                    .foregroundColor(AppTheme.Colors.passportTextMuted)
            }
            .onChange(of: viewModel.countrySearchText) { _, newValue in
                // Show dropdown when user starts typing
                if !newValue.isEmpty && viewModel.selectedCountry == nil {
                    viewModel.showCountryDropdown = true
                }
            }
            .onChange(of: focusedField) { _, newValue in
                if newValue == .country {
                    viewModel.showCountryDropdown = true
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        viewModel.showCountryDropdown = false
                    }
                }
            }
        }
    }

    // MARK: - Bottom Navigation

    private var bottomNavigation: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            // Back button
            Button {
                if viewModel.handleBack() {
                    dismiss()
                }
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
            .disabled(viewModel.isSubmitting)

            // Continue/Submit button
            Button {
                focusedField = nil
                Task {
                    await viewModel.handleContinue()
                }
            } label: {
                HStack(spacing: AppTheme.Spacing.xxxs) {
                    if viewModel.isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.backgroundDark))
                            .scaleEffect(0.8)
                    }
                    Text(viewModel.showingPassportPreview ? "SUBMIT" : "CONTINUE")
                        .font(AppTheme.Typography.button())
                        .tracking(1)
                    if !viewModel.isSubmitting {
                        Image(systemName: viewModel.showingPassportPreview ? "checkmark" : "arrow.right")
                            .font(.system(size: 12, weight: .medium))
                    }
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(viewModel.isContinueDisabled)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(AppTheme.Colors.backgroundDark)
    }
}

// MARK: - Preview

#Preview {
    TravelerDetailsView(
        email: "test@example.com",
        password: "password123",
        authManager: AuthManager()
    )
}
