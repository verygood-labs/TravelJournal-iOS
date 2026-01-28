//
//  EditorDividerRow.swift
//  TravelJournal-iOS
//

import SwiftUI

struct EditorDividerRow: View {
    let block: EditorBlock
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Rectangle()
                .fill(AppTheme.Colors.passportInputBorder)
                .frame(height: 1)
            
            Image(systemName: "airplane")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.Colors.passportTextMuted)
            
            Rectangle()
                .fill(AppTheme.Colors.passportInputBorder)
                .frame(height: 1)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.md)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        AppTheme.Colors.passportPageDark
            .ignoresSafeArea()
        
        VStack(spacing: AppTheme.Spacing.md) {
            EditorDividerRow(
                block: EditorBlock.newDivider(order: 0),
                onTap: {}
            )
        }
        .padding()
    }
}