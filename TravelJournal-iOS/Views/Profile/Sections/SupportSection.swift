//
//  SupportSection.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/24/26.
//

import SwiftUI

// MARK: - Support Section
/// Support settings section with links for Help & FAQ, Privacy Policy, and Terms of Service
struct SupportSection: View {
    
    var body: some View {
        SettingsSection(title: "SUPPORT") {
            NavigationLink {
                HelpView()
            } label: {
                SettingsRow(
                    icon: "questionmark.circle.fill",
                    label: "Help & FAQ"
                )
            }
            .buttonStyle(.plain)
            
            SettingsDivider()
            
            NavigationLink {
                PrivacyPolicyView()
            } label: {
                SettingsRow(
                    icon: "hand.raised.fill",
                    label: "Privacy Policy"
                )
            }
            .buttonStyle(.plain)
            
            SettingsDivider()
            
            NavigationLink {
                TermsOfServiceView()
            } label: {
                SettingsRow(
                    icon: "doc.text.fill",
                    label: "Terms of Service"
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Preview

#Preview {
    SupportSection();
}
