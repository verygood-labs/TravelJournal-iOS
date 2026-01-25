//
//  DeleteAccountSheet.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/24/26.
//


import SwiftUI

// MARK: - Delete Account Confirmation Sheet
/// Sheet that requires user to type "DELETE" to confirm account deletion
struct DeleteAccountSheet: View {
    @ObservedObject var viewModel: ProfileViewModel
    @ObservedObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Header
            VStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(AppTheme.Colors.error)
                
                Text("Confirm Deletion")
                    .font(AppTheme.Typography.serifSmall())
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
            .padding(.top, AppTheme.Spacing.md)
            
            // Instructions
            Text("Type DELETE to confirm")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            // Text Field
            TextField("", text: $viewModel.deleteConfirmationText)
                .font(AppTheme.Typography.monoMedium())
                .multilineTextAlignment(.center)
                .padding()
                .background(AppTheme.Colors.inputBackground)
                .cornerRadius(AppTheme.CornerRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
                )
                .padding(.horizontal, AppTheme.Spacing.xl)
            
            // Delete Button
            Button {
                Task {
                    await viewModel.deleteAccount()
                    if viewModel.error == nil {
                        await authManager.logout()
                    }
                }
            } label: {
                HStack {
                    if viewModel.isDeletingAccount {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Delete My Account")
                    }
                }
                .font(AppTheme.Typography.button())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(viewModel.canDeleteAccount ? AppTheme.Colors.error : AppTheme.Colors.error.opacity(0.5))
                .cornerRadius(AppTheme.CornerRadius.medium)
            }
            .disabled(!viewModel.canDeleteAccount || viewModel.isDeletingAccount)
            .padding(.horizontal, AppTheme.Spacing.lg)
            
            Spacer()
        }
        .background(AppTheme.Colors.backgroundMedium)
        .onDisappear {
            viewModel.resetDeleteConfirmation()
        }
    }
}

// MARK: - Preview

#Preview {
    DeleteAccountSheet(
        viewModel: ProfileViewModel(),
        authManager: AuthManager()
    )
}
