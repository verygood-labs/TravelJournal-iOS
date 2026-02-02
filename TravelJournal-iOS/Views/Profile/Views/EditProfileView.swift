//
//  EditProfileView.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/24/26.
//

import SwiftUI

// MARK: - Edit Profile Field

/// Specifies which field to focus when opening the edit screen
enum EditProfileField {
    case none
    case name
    case username
    case nationality
}

// MARK: - Edit Profile View

/// Screen for editing user profile information (name, username, photo, nationality)
/// Uses passport page styling consistent with the app theme
struct EditProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    var field: EditProfileField = .none

    @Environment(\.dismiss) private var dismiss
    @StateObject private var editViewModel = EditProfileViewModel()

    @FocusState private var focusedField: EditProfileField?

    var body: some View {
        PassportPageBackgroundView {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Profile Photo Section
                    profilePhotoSection
                        .padding(.top, AppTheme.Spacing.xl)

                    // Form Fields
                    formSection
                        .padding(.horizontal, AppTheme.Spacing.lg)

                    Spacer(minLength: AppTheme.Spacing.xxxl)
                }
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
                .font(AppTheme.Typography.monoMedium())
                .foregroundColor(AppTheme.Colors.passportTextSecondary)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                if editViewModel.isSaving {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Button("Save") {
                        Task {
                            await saveProfile()
                        }
                    }
                    .font(AppTheme.Typography.monoMedium())
                    .fontWeight(.semibold)
                    .foregroundColor(editViewModel.hasChanges ? AppTheme.Colors.primary : AppTheme.Colors.passportTextMuted)
                    .disabled(!editViewModel.hasChanges)
                }
            }
        }
        .task {
            // Initialize edit view model with current profile data
            if let profile = viewModel.userProfile {
                editViewModel.initialize(with: profile)
            }

            // Set initial focus if specified
            if field != .none {
                focusedField = field
            }
        }
        .sheet(isPresented: $editViewModel.showingImagePicker) {
            ImagePicker(image: $editViewModel.selectedImage, sourceType: .photoLibrary)
        }
        .fullScreenCover(isPresented: $editViewModel.showingCamera) {
            ImagePicker(image: $editViewModel.selectedImage, sourceType: .camera)
        }
        .alert("Error", isPresented: .init(
            get: { editViewModel.error != nil },
            set: { if !$0 { editViewModel.error = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(editViewModel.error ?? "")
        }
    }

    // MARK: - Profile Photo Section

    private var profilePhotoSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Photo
            ZStack {
                if let image = editViewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
                } else if let url = viewModel.profileImageUrl {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            photoPlaceholder
                                .overlay(ProgressView())
                        case let .success(image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
                        case .failure:
                            photoPlaceholder
                        @unknown default:
                            photoPlaceholder
                        }
                    }
                } else {
                    photoPlaceholder
                }
            }
            .frame(width: 120, height: 120)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(AppTheme.Colors.primary, lineWidth: 2)
            )

            // Photo action buttons
            HStack(spacing: AppTheme.Spacing.md) {
                Button {
                    editViewModel.showingCamera = true
                } label: {
                    HStack(spacing: AppTheme.Spacing.xxxs) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 12))
                        Text("Camera")
                            .font(AppTheme.Typography.monoSmall())
                    }
                    .foregroundColor(AppTheme.Colors.primary)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.xs)
                    .background(AppTheme.Colors.primary.opacity(0.1))
                    .cornerRadius(AppTheme.CornerRadius.pill)
                }

                Button {
                    editViewModel.showingImagePicker = true
                } label: {
                    HStack(spacing: AppTheme.Spacing.xxxs) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 12))
                        Text("Library")
                            .font(AppTheme.Typography.monoSmall())
                    }
                    .foregroundColor(AppTheme.Colors.primary)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.xs)
                    .background(AppTheme.Colors.primary.opacity(0.1))
                    .cornerRadius(AppTheme.CornerRadius.pill)
                }
            }
        }
    }

    private var photoPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .fill(AppTheme.Colors.passportInputBackground)
                .frame(width: 120, height: 120)

            Image(systemName: "person.fill")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.Colors.passportTextMuted)
        }
    }

    // MARK: - Form Section

    private var formSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Full Name
            nameField

            // Username
            usernameField

            // Nationality
            nationalityField
        }
    }

    // MARK: - Name Field

    private var nameField: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
            Text("FULL NAME")
                .font(AppTheme.Typography.inputLabel())
                .tracking(1)
                .foregroundColor(AppTheme.Colors.passportTextMuted)

            TextField(
                "",
                text: $editViewModel.name,
                prompt: Text("Your full name")
                    .foregroundColor(AppTheme.Colors.passportTextPlaceholder)
            )
            .textFieldStyle(PassportPageTextFieldStyle(isFocused: focusedField == .name))
            .focused($focusedField, equals: .name)
            .textContentType(.name)
            .autocorrectionDisabled()
        }
    }

    // MARK: - Username Field

    private var usernameField: some View {
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
                    text: $editViewModel.username,
                    prompt: Text("username")
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
                usernameStatusIndicator
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

            if let error = editViewModel.usernameError {
                Text(error)
                    .font(AppTheme.Typography.monoCaption())
                    .foregroundColor(.red)
            }
        }
    }

    private var usernameBorderColor: Color {
        if editViewModel.usernameError != nil {
            return .red
        }
        return focusedField == .username
            ? AppTheme.Colors.passportInputBorderFocused
            : AppTheme.Colors.passportInputBorder
    }

    @ViewBuilder
    private var usernameStatusIndicator: some View {
        if editViewModel.isCheckingUsername {
            ProgressView()
                .scaleEffect(0.8)
                .padding(.trailing, AppTheme.Spacing.sm)
        } else if editViewModel.isUsernameAvailable == true {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .padding(.trailing, AppTheme.Spacing.sm)
        } else if editViewModel.isUsernameAvailable == false {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
                .padding(.trailing, AppTheme.Spacing.sm)
        } else {
            Spacer()
                .frame(width: AppTheme.Spacing.sm)
        }
    }

    // MARK: - Nationality Field

    private var nationalityField: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
            Text("NATIONALITY")
                .font(AppTheme.Typography.inputLabel())
                .tracking(1)
                .foregroundColor(AppTheme.Colors.passportTextMuted)

            nationalityPicker
        }
        .task {
            await editViewModel.loadCountries()
        }
    }

    private var nationalityPicker: some View {
        VStack(spacing: 0) {
            // Input field
            HStack {
                if let country = editViewModel.selectedCountry {
                    Text(country.name)
                        .font(AppTheme.Typography.monoMedium())
                        .foregroundColor(AppTheme.Colors.passportTextPrimary)

                    Spacer()

                    Button {
                        editViewModel.clearSelectedCountry()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.Colors.passportTextMuted)
                    }
                } else {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.passportTextMuted)

                    TextField(
                        "",
                        text: $editViewModel.countrySearchText,
                        prompt: Text(editViewModel.isLoadingCountries ? "Loading..." : "Search for a country...")
                            .foregroundColor(AppTheme.Colors.passportTextPlaceholder)
                    )
                    .font(AppTheme.Typography.monoMedium())
                    .foregroundColor(AppTheme.Colors.passportTextPrimary)
                    .focused($focusedField, equals: .nationality)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .disabled(editViewModel.isLoadingCountries)
                    .onChange(of: editViewModel.countrySearchText) { _, newValue in
                        editViewModel.showCountryDropdown = !newValue.isEmpty
                    }

                    if editViewModel.isLoadingCountries {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.vertical, 14)
            .background(AppTheme.Colors.passportInputBackground)
            .overlay(
                RoundedRectangle(cornerRadius: editViewModel.showCountryDropdown ? 0 : AppTheme.CornerRadius.medium)
                    .stroke(
                        focusedField == .nationality
                            ? AppTheme.Colors.passportInputBorderFocused
                            : AppTheme.Colors.passportInputBorder,
                        lineWidth: 2
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: editViewModel.showCountryDropdown ? 0 : AppTheme.CornerRadius.medium))

            // Dropdown list
            if editViewModel.showCountryDropdown && !editViewModel.filteredCountries.isEmpty {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(editViewModel.filteredCountries) { country in
                            Button {
                                editViewModel.selectCountry(country)
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

                            if country.id != editViewModel.filteredCountries.last?.id {
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
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
            }
        }
    }

    // MARK: - Save Profile

    private func saveProfile() async {
        let success = await editViewModel.saveProfile()
        if success {
            await viewModel.loadProfile()
            dismiss()
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        EditProfileView(viewModel: ProfileViewModel())
    }
}
