import SwiftUI

// MARK: - Corner Accents View
/// Decorative corner brackets like a passport frame
/// Usage: Add as overlay on Splash/Auth screens
struct CornerAccentsView: View {
    var color: Color = AppTheme.Colors.primary.opacity(0.4)
    var size: CGFloat = 40
    var lineWidth: CGFloat = 3
    var padding: CGFloat = 20
    
    var body: some View {
        GeometryReader { geometry in
            // Top Left
            CornerBracket(color: color, size: size, lineWidth: lineWidth)
                .position(x: padding + size / 2, y: padding + size / 2)
            
            // Top Right
            CornerBracket(color: color, size: size, lineWidth: lineWidth)
                .rotationEffect(.degrees(90))
                .position(x: geometry.size.width - padding - size / 2, y: padding + size / 2)
            
            // Bottom Left
            CornerBracket(color: color, size: size, lineWidth: lineWidth)
                .rotationEffect(.degrees(-90))
                .position(x: padding + size / 2, y: geometry.size.height - padding - size / 2)
            
            // Bottom Right
            CornerBracket(color: color, size: size, lineWidth: lineWidth)
                .rotationEffect(.degrees(180))
                .position(x: geometry.size.width - padding - size / 2, y: geometry.size.height - padding - size / 2)
        }
    }
}

// MARK: - Corner Bracket Shape
struct CornerBracket: View {
    var color: Color
    var size: CGFloat
    var lineWidth: CGFloat
    
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: size))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: size, y: 0))
        }
        .stroke(color, lineWidth: lineWidth)
        .frame(width: size, height: size)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        AppBackgroundView {
            Text("Content")
                .foregroundColor(.white)
        }
        
        CornerAccentsView()
    }
}