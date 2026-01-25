//
//  AccountSection.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/24/26.
//

import Foundation
import SwiftUI

// MARK: - Account Section
/// Account settings section with email, password, and nationality
struct AccountSection: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        SettingsSection(title: "ACCOUNT") {
            SettingsRow(
                icon: "envelope.fill",
                label: "Email",
                value: viewModel.email,
                showChevron: false
            )
            
            SettingsDivider()
            
            NavigationLink {
                ChangePasswordView()
            } label: {
                SettingsRow(
                    icon: "lock.fill",
                    label: "Change Password"
                )
            }
            .buttonStyle(.plain)
            
            SettingsDivider()
            
            NavigationLink {
                EditProfileView(viewModel: viewModel, field: .nationality)
            } label: {
                SettingsRow(
                    icon: "globe.americas.fill",
                    label: "Nationality",
                    value: viewModel.nationalityName
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Preview

#Preview {
    AccountSection(viewModel: ProfileViewModel())
}
