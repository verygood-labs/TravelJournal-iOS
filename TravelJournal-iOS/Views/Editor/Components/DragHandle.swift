//
//  DragHandle.swift
//  TravelJournal-iOS
//

import SwiftUI

/// A drag handle icon used for reordering items.
/// This component is just the visual - drag behavior is attached by the parent.
struct DragHandle: View {
    var isActive: Bool = false
    
    var body: some View {
        Image(systemName: "line.3.horizontal")
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(isActive ? AppTheme.Colors.primary : AppTheme.Colors.passportTextMuted)
            .frame(width: 28, height: 28)
            .background(
                Circle()
                    .fill(isActive ? AppTheme.Colors.primary.opacity(0.15) : Color.clear)
            )
            .contentShape(Rectangle())
    }
}

// MARK: - Preview

#Preview {
    PassportPageBackgroundView {
        VStack(spacing: AppTheme.Spacing.lg) {
            HStack {
                DragHandle(isActive: false)
                Text("Inactive state")
                    .font(AppTheme.Typography.monoSmall())
                    .foregroundColor(AppTheme.Colors.passportTextPrimary)
            }
            
            HStack {
                DragHandle(isActive: true)
                Text("Active/dragging state")
                    .font(AppTheme.Typography.monoSmall())
                    .foregroundColor(AppTheme.Colors.passportTextPrimary)
            }
        }
        .padding()
    }
}
