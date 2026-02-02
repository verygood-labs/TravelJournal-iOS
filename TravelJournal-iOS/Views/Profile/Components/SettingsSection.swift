//
//  SettingsSection.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/24/26.
//

import SwiftUI

// MARK: - Settings Section

/// A container for grouping settings rows with an optional title
struct SettingsSection<Content: View>: View {
    let title: String?
    let content: Content

    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
            // Section title
            if let title = title {
                Text(title)
                    .font(AppTheme.Typography.monoCaption())
                    .tracking(1.5)
                    .foregroundColor(AppTheme.Colors.textMuted)
                    .padding(.leading, AppTheme.Spacing.xxxs)
            }

            // Section content
            VStack(spacing: 0) {
                content
            }
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.large)
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()

        VStack(spacing: AppTheme.Spacing.lg) {
            // Section with title
            SettingsSection(title: "ACCOUNT") {
                SettingsRow(
                    icon: "envelope.fill",
                    label: "Email",
                    value: "john@example.com",
                    showChevron: false
                )

                SettingsDivider()

                SettingsRow(
                    icon: "lock.fill",
                    label: "Change Password"
                )
            }

            // Section without title
            SettingsSection {
                SettingsRow(
                    icon: "rectangle.portrait.and.arrow.right",
                    label: "Log Out",
                    isDanger: true,
                    showChevron: false
                )
            }
        }
        .padding()
    }
}
