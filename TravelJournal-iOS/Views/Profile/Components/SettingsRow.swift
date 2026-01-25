//
//  SettingsRow.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/24/26.
//


import SwiftUI

// MARK: - Settings Row
/// A single row in the settings list with icon, label, optional value, and chevron
struct SettingsRow: View {
    let icon: String
    let label: String
    var value: String? = nil
    var isDanger: Bool = false
    var showChevron: Bool = true
    
    private var iconColor: Color {
        isDanger ? AppTheme.Colors.error : AppTheme.Colors.primary
    }
    
    private var iconBackgroundColor: Color {
        isDanger
            ? AppTheme.Colors.error.opacity(0.15)
            : AppTheme.Colors.primary.opacity(0.15)
    }
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            // Icon with background
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(iconBackgroundColor)
                    .frame(width: 28, height: 28)
                
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(iconColor)
            }
            
            // Label
            Text(label)
                .font(AppTheme.Typography.monoMedium())
                .foregroundColor(isDanger ? AppTheme.Colors.error : AppTheme.Colors.textPrimary)
            
            Spacer()
            
            // Value (if any)
            if let value = value {
                Text(value)
                    .font(AppTheme.Typography.monoSmall())
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            // Chevron
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textMuted)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm)
        .contentShape(Rectangle())
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()
        
        VStack(spacing: 0) {
            // Normal row with value
            SettingsRow(
                icon: "envelope.fill",
                label: "Email",
                value: "john@example.com",
                showChevron: false
            )
            
            SettingsDivider()
            
            // Normal row with chevron
            SettingsRow(
                icon: "lock.fill",
                label: "Change Password"
            )
            
            SettingsDivider()
            
            // Danger row
            SettingsRow(
                icon: "trash.fill",
                label: "Delete Account",
                isDanger: true
            )
        }
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
        .padding()
    }
}