import SwiftUI

// MARK: - Profile View

/// Main profile/settings screen with profile card and settings sections
struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        // Profile Card Section
                        ProfileCardSection(viewModel: viewModel)

                        // Account Section
                        AccountSection(viewModel: viewModel)

                        // Preferences Section
                        PreferencesSection(viewModel: viewModel)

                        // Support Section
                        SupportSection()

                        // App Version
                        appVersionSection

                        // Danger Zone
                        dangerZoneSection

                        // Bottom padding for tab bar
                        Spacer()
                            .frame(height: AppTheme.Spacing.xxxl)
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.top, AppTheme.Spacing.md)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(AppTheme.Typography.serifMedium())
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.loadProfile()
            }
            .refreshable {
                await viewModel.loadProfile()
            }
            // Currency Picker Sheet
            .sheet(isPresented: $viewModel.showingCurrencyPicker) {
                OptionPickerSheet(
                    title: "Currency",
                    options: Currency.allCases,
                    selectedOption: viewModel.selectedCurrency,
                    optionLabel: { $0.displayName },
                    onSelect: { viewModel.updateCurrency($0) }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            // Distance Unit Picker Sheet
            .sheet(isPresented: $viewModel.showingDistanceUnitPicker) {
                OptionPickerSheet(
                    title: "Distance Units",
                    options: DistanceUnit.allCases,
                    selectedOption: viewModel.selectedDistanceUnit,
                    optionLabel: { $0.displayName },
                    onSelect: { viewModel.updateDistanceUnit($0) }
                )
                .presentationDetents([.height(250)])
                .presentationDragIndicator(.visible)
            }
            // Logout Alert
            .alert("Log Out", isPresented: $viewModel.showingLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Log Out", role: .destructive) {
                    Task {
                        await authManager.logout()
                    }
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
            // Delete Account Alert
            .alert("Delete Account", isPresented: $viewModel.showingDeleteAccountAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Continue", role: .destructive) {
                    viewModel.showingDeleteConfirmation = true
                }
            } message: {
                Text("This will permanently delete your account and all your data. This action cannot be undone.")
            }
            // Delete Confirmation Sheet
            .sheet(isPresented: $viewModel.showingDeleteConfirmation) {
                DeleteAccountSheet(viewModel: viewModel, authManager: authManager)
                    .presentationDetents([.height(300)])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - App Version Section

    private var appVersionSection: some View {
        VStack(spacing: 0) {
            Text("TravelJournal")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.textSecondary)

            Text(viewModel.appVersion)
                .font(AppTheme.Typography.monoCaption())
                .foregroundColor(AppTheme.Colors.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.md)
    }

    // MARK: - Danger Zone Section

    private var dangerZoneSection: some View {
        SettingsSection {
            Button {
                viewModel.showingLogoutAlert = true
            } label: {
                SettingsRow(
                    icon: "rectangle.portrait.and.arrow.right",
                    label: "Log Out",
                    isDanger: true,
                    showChevron: false
                )
            }
            .buttonStyle(.plain)

            SettingsDivider()

            Button {
                viewModel.showingDeleteAccountAlert = true
            } label: {
                SettingsRow(
                    icon: "trash.fill",
                    label: "Delete Account",
                    isDanger: true
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
        .environmentObject(AuthManager())
}
