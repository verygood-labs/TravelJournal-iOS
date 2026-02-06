//
//  ThemedDividerView.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 2/5/26.
//

import SwiftUI

// MARK: - Themed Divider View

/// A themed divider for separating content in preview mode.
struct ThemedDividerView: View {
    @Environment(\.journalTheme) private var theme

    // MARK: - Computed Properties

    private var dividerStyle: DividerBlockStyle {
        theme.blocks.divider
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: geometry.size.width, y: 0))
            }
            .stroke(
                dividerStyle.lineSwiftUIColor,
                style: strokeStyle(for: dividerStyle.lineStyle, width: geometry.size.width)
            )
        }
        .frame(height: 1)
        .padding(.vertical, 16)
    }

    // MARK: - Stroke Style

    private func strokeStyle(for lineStyle: DividerLineStyle, width: CGFloat) -> StrokeStyle {
        switch lineStyle {
        case .solid:
            return StrokeStyle(lineWidth: 1)
        case .dashed:
            return StrokeStyle(lineWidth: 1, dash: [8, 4])
        case .dotted:
            return StrokeStyle(lineWidth: 1, lineCap: .round, dash: [2, 4])
        }
    }
}

// MARK: - Preview

#Preview("All Themes") {
    VStack(spacing: 32) {
        // Default
        VStack(spacing: 8) {
            Text("Default Theme (Solid)")
                .font(.caption)
                .foregroundColor(.gray)
            ThemedDividerView()
                .journalTheme(.default)
        }
        .padding()
        .background(Color(hex: "#f5f5f5"))

        // Passport
        VStack(spacing: 8) {
            Text("Passport Theme (Dashed)")
                .font(.caption)
                .foregroundColor(.gray)
            ThemedDividerView()
                .journalTheme(.passport)
        }
        .padding()
        .background(Color(hex: "#f5f1e8"))

        // Retro
        VStack(spacing: 8) {
            Text("Retro Theme (Dotted)")
                .font(.caption)
                .foregroundColor(.gray)
            ThemedDividerView()
                .journalTheme(.retro)
        }
        .padding()
        .background(Color(hex: "#C0C0C0"))
    }
    .padding()
}
