//
//  MapControlsView.swift
//  TravelJournal-iOS
//
//  Map zoom and location controls overlay
//

import SwiftUI

struct MapControlsView: View {
    let onZoomIn: () -> Void
    let onZoomOut: () -> Void
    let onCenterLocation: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xxs) {
            // Zoom In
            controlButton(icon: "plus", action: onZoomIn)

            // Zoom Out
            controlButton(icon: "minus", action: onZoomOut)

            Divider()
                .frame(width: 32)
                .background(AppTheme.Colors.divider)

            // Center Location
            controlButton(icon: "location.fill", action: onCenterLocation)
        }
        .padding(.vertical, AppTheme.Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.1), radius: 8, y: 4)
        )
    }

    private func controlButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.Colors.textPrimary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.gray.opacity(0.3)
            .ignoresSafeArea()

        HStack {
            Spacer()
            MapControlsView(
                onZoomIn: { print("Zoom in") },
                onZoomOut: { print("Zoom out") },
                onCenterLocation: { print("Center") }
            )
            .padding(.trailing, 16)
        }
    }
}
