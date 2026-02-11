//
//  JournalPinView.swift
//  TravelJournal-iOS
//
//  Custom golden pin for journal locations on the map
//

import SwiftUI

struct JournalPinView: View {
    let journalCount: Int
    let isSelected: Bool

    var body: some View {
        ZStack {
            // Pin shape
            VStack(spacing: 0) {
                // Circle with count
                ZStack {
                    Circle()
                        .fill(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.primaryLight)
                        .frame(width: 36, height: 36)
                        .shadow(color: Color.black.opacity(0.3), radius: 4, y: 2)

                    Text("\(journalCount)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(isSelected ? .white : AppTheme.Colors.backgroundDark)
                }

                // Pin tail
                PinTriangle()
                    .fill(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.primaryLight)
                    .frame(width: 12, height: 8)
                    .offset(y: -2)
            }
        }
        .scaleEffect(isSelected ? 1.2 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

// MARK: - Triangle Shape

struct PinTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.gray.opacity(0.3)

        VStack(spacing: 40) {
            JournalPinView(journalCount: 12, isSelected: false)
            JournalPinView(journalCount: 5, isSelected: true)
            JournalPinView(journalCount: 1, isSelected: false)
        }
    }
}
