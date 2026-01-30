//
//  ToastView.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/29/26.
//


//
//  ToastView.swift
//  TravelJournal-iOS
//

import SwiftUI

// MARK: - Toast View

/// Visual component for displaying a toast notification.
struct ToastView: View {
    let toast: Toast
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            // Icon
            if let icon = toast.icon {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(toast.type.iconColor)
            }
            
            // Message
            Text(toast.message)
                .font(AppTheme.Typography.monoMedium())
                .foregroundColor(.white)
                .lineLimit(2)
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(toast.type.backgroundColor)
        .cornerRadius(AppTheme.CornerRadius.large)
        .shadow(
            color: Color.black.opacity(0.15),
            radius: 8,
            x: 0,
            y: 4
        )
        .onTapGesture {
            onDismiss()
        }
    }
}

// MARK: - Preview

#Preview("Success") {
    ZStack {
        Color.gray.opacity(0.3)
            .ignoresSafeArea()
        
        VStack(spacing: 20) {
            ToastView(toast: .success("Draft saved successfully")) { }
            ToastView(toast: .error("Failed to save draft")) { }
            ToastView(toast: .warning("You have unsaved changes")) { }
            ToastView(toast: .info("Tip: Tap to edit blocks")) { }
        }
        .padding()
    }
}