//
//  PreferencesSection.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/24/26.
//

import SwiftUI

// MARK: - Preferences Section
/// Preferences settings section with currency and distance units
struct PreferencesSection: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        SettingsSection(title: "PREFERENCES") {
            Button {
                viewModel.showingCurrencyPicker = true
            } label: {
                SettingsRow(
                    icon: "dollarsign.circle.fill",
                    label: "Currency",
                    value: viewModel.selectedCurrency.displayName
                )
            }
            .buttonStyle(.plain)
            
            SettingsDivider()
            
            Button {
                viewModel.showingDistanceUnitPicker = true
            } label: {
                SettingsRow(
                    icon: "ruler.fill",
                    label: "Distance Units",
                    value: viewModel.selectedDistanceUnit.displayName
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Preview

#Preview {
    PreferencesSection(viewModel: ProfileViewModel())
}

