//
//  AppToolbarBackground.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 2/10/26.
//

import SwiftUI

// MARK: - App Toolbar Background

/// Background view with gradient and dot pattern for toolbars and headers.
/// Similar to AppBackgroundView but designed for smaller components.
struct AppToolbarBackground: View {
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    AppTheme.Colors.backgroundMedium,
                    AppTheme.Colors.backgroundDark,
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Dot pattern overlay
            DotPatternView()
        }
    }
}

// MARK: - View Extension

extension View {
    /// Applies the app toolbar background styling extending into top safe area
    func appToolbarBackground() -> some View {
        self.background(
            AppToolbarBackground()
                .ignoresSafeArea(edges: .top)
        )
    }
    
    /// Applies the app toolbar background styling extending into bottom safe area
    func appToolbarBackgroundBottom() -> some View {
        self.background(
            AppToolbarBackground()
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - Preview

#Preview {
    VStack {
        Text("Toolbar Content")
            .foregroundColor(.white)
            .padding()
    }
    .appToolbarBackground()
}
