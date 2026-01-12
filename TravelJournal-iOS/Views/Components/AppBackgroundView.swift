import SwiftUI

// MARK: - App Background View
/// Full-screen background with gradient and subtle dot pattern texture
/// Usage: AppBackgroundView { YourContent() }
struct AppBackgroundView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    AppTheme.Colors.backgroundMedium,
                    AppTheme.Colors.backgroundDark
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Dot pattern overlay
            DotPatternView()
                .ignoresSafeArea()
            
            // Content
            content
        }
    }
}

// MARK: - Dot Pattern View
/// Subtle repeating dot pattern overlay
struct DotPatternView: View {
    var body: some View {
        Canvas { context, size in
            let dotSpacing: CGFloat = 40
            let dotRadius: CGFloat = 1
            
            for x in stride(from: dotSpacing / 2, to: size.width, by: dotSpacing) {
                for y in stride(from: dotSpacing / 2, to: size.height, by: dotSpacing) {
                    let rect = CGRect(
                        x: x - dotRadius,
                        y: y - dotRadius,
                        width: dotRadius * 2,
                        height: dotRadius * 2
                    )
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(AppTheme.Colors.primary.opacity(0.15))
                    )
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    AppBackgroundView {
        Text("Content goes here")
            .foregroundColor(.white)
    }
}