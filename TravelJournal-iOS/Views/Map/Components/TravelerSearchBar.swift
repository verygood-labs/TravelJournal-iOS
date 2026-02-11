//
//  TravelerSearchBar.swift
//  TravelJournal-iOS
//
//  Search bar for finding travelers
//

import SwiftUI

struct TravelerSearchBar: View {
    @Binding var text: String
    let placeholder: String
    let onClear: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            // Search icon
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(
                    isFocused ? AppTheme.Colors.primary : AppTheme.Colors.textSecondary
                )

            // Text field
            TextField(placeholder, text: $text)
                .font(AppTheme.Typography.monoMedium())
                .foregroundColor(AppTheme.Colors.textPrimary)
                .focused($isFocused)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            // Clear button
            if !text.isEmpty {
                Button(action: onClear) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
        }
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, AppTheme.Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .fill(AppTheme.Colors.inputBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .stroke(
                            isFocused ? AppTheme.Colors.inputBorderFocused : AppTheme.Colors.inputBorder,
                            lineWidth: 1
                        )
                )
        )
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()

        VStack(spacing: 20) {
            TravelerSearchBar(
                text: .constant(""),
                placeholder: "Search travelers...",
                onClear: {}
            )

            TravelerSearchBar(
                text: .constant("john"),
                placeholder: "Search travelers...",
                onClear: {}
            )
        }
        .padding()
    }
}
