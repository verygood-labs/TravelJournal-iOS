//
//  SortChipsView.swift
//  TravelJournal-iOS
//
//  Sort option chips for traveler search
//

import SwiftUI

struct SortChipsView: View {
    @Binding var selectedOption: TravelerSortOption

    var body: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            ForEach(TravelerSortOption.allCases, id: \.self) { option in
                SortChip(
                    title: option.rawValue,
                    isSelected: selectedOption == option
                ) {
                    selectedOption = option
                }
            }

            Spacer()
        }
    }
}

// MARK: - Sort Chip

struct SortChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(AppTheme.Typography.monoCaption())
                .tracking(0.5)
                .foregroundColor(
                    isSelected ? AppTheme.Colors.backgroundDark : AppTheme.Colors.textSecondary
                )
                .padding(.horizontal, AppTheme.Spacing.xs)
                .padding(.vertical, AppTheme.Spacing.xxxs + 2)
                .background(
                    Capsule()
                        .fill(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.cardBackground)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()

        SortChipsView(selectedOption: .constant(.mostTraveled))
            .padding()
    }
}
