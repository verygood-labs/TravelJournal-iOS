//
//  ChangePasswordView.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/24/26.
//

import SwiftUI

// MARK: - Change Password View

/// Placeholder view for password change functionality
struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showingSuccessAlert = false

    private var isFormValid: Bool {
        !currentPassword.isEmpty &&
            newPassword.count >= 8 &&
            newPassword == confirmPassword
    }

    var body: some View {
        PassportPageBackgroundView {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Header
                    headerSection
                        .padding(.top, AppTheme.Spacing.xl)

                    // Form
                    formSection
                        .padding(.horizontal, AppTheme.Spacing.lg)

                    // Submit Button
                    submitButton
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.top, AppTheme.Spacing.md)

                    Spacer()
                }
            }
        }
        .navigationTitle("Change Password")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Password Updated", isPresented: $showingSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your password has been successfully changed.")
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "lock.rotation")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.Colors.primary)

            Text("Update your password")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.passportTextSecondary)
        }
    }

    // MARK: - Form Section

    private var formSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Current Password
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                Text("CURRENT PASSWORD")
                    .font(AppTheme.Typography.inputLabel())
                    .tracking(1)
                    .foregroundColor(AppTheme.Colors.passportTextMuted)

                SecureField("Enter current password", text: $currentPassword)
                    .textFieldStyle(PassportPageTextFieldStyle())
            }

            // New Password
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                Text("NEW PASSWORD")
                    .font(AppTheme.Typography.inputLabel())
                    .tracking(1)
                    .foregroundColor(AppTheme.Colors.passportTextMuted)

                SecureField("Enter new password", text: $newPassword)
                    .textFieldStyle(PassportPageTextFieldStyle())

                Text("Must be at least 8 characters")
                    .font(AppTheme.Typography.monoCaption())
                    .foregroundColor(AppTheme.Colors.passportTextMuted)
            }

            // Confirm Password
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                Text("CONFIRM PASSWORD")
                    .font(AppTheme.Typography.inputLabel())
                    .tracking(1)
                    .foregroundColor(AppTheme.Colors.passportTextMuted)

                SecureField("Confirm new password", text: $confirmPassword)
                    .textFieldStyle(PassportPageTextFieldStyle())

                if !confirmPassword.isEmpty && newPassword != confirmPassword {
                    Text("Passwords do not match")
                        .font(AppTheme.Typography.monoCaption())
                        .foregroundColor(AppTheme.Colors.error)
                }
            }
        }
    }

    // MARK: - Submit Button

    private var submitButton: some View {
        Button {
            // TODO: Implement password change API call
            isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isLoading = false
                showingSuccessAlert = true
            }
        } label: {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.passportPageLight))
                } else {
                    Text("Update Password")
                }
            }
            .font(AppTheme.Typography.button())
            .foregroundColor(AppTheme.Colors.passportPageLight)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(isFormValid ? AppTheme.Colors.primary : AppTheme.Colors.primary.opacity(0.5))
            .cornerRadius(AppTheme.CornerRadius.medium)
        }
        .disabled(!isFormValid || isLoading)
    }
}

// MARK: - Help View

/// Placeholder view for Help & FAQ
struct HelpView: View {
    var body: some View {
        PassportPageBackgroundView {
            VStack(spacing: AppTheme.Spacing.lg) {
                Spacer()

                Image(systemName: "questionmark.circle")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.Colors.primary.opacity(0.5))

                Text("Help & FAQ")
                    .font(AppTheme.Typography.serifMedium())
                    .foregroundColor(AppTheme.Colors.passportTextPrimary)

                Text("Coming soon...")
                    .font(AppTheme.Typography.monoSmall())
                    .foregroundColor(AppTheme.Colors.passportTextSecondary)

                Spacer()
            }
        }
        .navigationTitle("Help & FAQ")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Privacy Policy View

/// Placeholder view for Privacy Policy
struct PrivacyPolicyView: View {
    var body: some View {
        PassportPageBackgroundView {
            VStack(spacing: AppTheme.Spacing.lg) {
                Spacer()

                Image(systemName: "hand.raised")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.Colors.primary.opacity(0.5))

                Text("Privacy Policy")
                    .font(AppTheme.Typography.serifMedium())
                    .foregroundColor(AppTheme.Colors.passportTextPrimary)

                Text("Coming soon...")
                    .font(AppTheme.Typography.monoSmall())
                    .foregroundColor(AppTheme.Colors.passportTextSecondary)

                Spacer()
            }
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Terms of Service View

/// Placeholder view for Terms of Service
struct TermsOfServiceView: View {
    var body: some View {
        PassportPageBackgroundView {
            VStack(spacing: AppTheme.Spacing.lg) {
                Spacer()

                Image(systemName: "doc.text")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.Colors.primary.opacity(0.5))

                Text("Terms of Service")
                    .font(AppTheme.Typography.serifMedium())
                    .foregroundColor(AppTheme.Colors.passportTextPrimary)

                Text("Coming soon...")
                    .font(AppTheme.Typography.monoSmall())
                    .foregroundColor(AppTheme.Colors.passportTextSecondary)

                Spacer()
            }
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Previews

#Preview("Change Password") {
    NavigationStack {
        ChangePasswordView()
    }
}

#Preview("Help") {
    NavigationStack {
        HelpView()
    }
}

#Preview("Privacy") {
    NavigationStack {
        PrivacyPolicyView()
    }
}

#Preview("Terms") {
    NavigationStack {
        TermsOfServiceView()
    }
}
