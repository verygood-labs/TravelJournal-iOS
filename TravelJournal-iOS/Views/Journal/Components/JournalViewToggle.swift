//
//  JournalViewToggle.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/21/26.
//

import Foundation
import SwiftUI

enum JournalViewMode: String, CaseIterable {
    case card = "Cards"
    case list = "List"

    var icon: String {
        switch self {
        case .card: return "square.grid.2x2"
        case .list: return "list.bullet"
        }
    }
}

struct JournalViewToggle: View {
    @Binding var selectedMode: JournalViewMode

    var body: some View {
        HStack(spacing: 0) {
            ForEach(JournalViewMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.easeInOut(duration: AppTheme.Animation.fast)) {
                        selectedMode = mode
                    }
                } label: {
                    HStack(spacing: AppTheme.Spacing.xxs) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 12, weight: .medium))

                        Text(mode.rawValue.uppercased())
                            .font(AppTheme.Typography.monoCaption())
                            .tracking(1)
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.xs)
                    .frame(maxWidth: .infinity)
                    .background(
                        selectedMode == mode
                            ? AppTheme.Colors.primary
                            : Color.clear
                    )
                    .foregroundColor(
                        selectedMode == mode
                            ? AppTheme.Colors.backgroundDark
                            : AppTheme.Colors.primary.opacity(0.6)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .background(AppTheme.Colors.primary.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .stroke(AppTheme.Colors.primary.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
}

#Preview {
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()

        VStack(spacing: 20) {
            JournalViewToggle(selectedMode: .constant(.card))
            JournalViewToggle(selectedMode: .constant(.list))
        }
        .padding()
    }
}
