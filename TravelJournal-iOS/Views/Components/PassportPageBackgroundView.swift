import SwiftUI

// MARK: - Passport Page Background View

/// Cream/paper-style background with subtle grid pattern
/// Used for form sections that mimic passport page aesthetics
/// Usage: PassportPageBackgroundView { YourContent() }
struct PassportPageBackgroundView<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            // Base gradient - cream/paper colors
            LinearGradient(
                colors: [
                    AppTheme.Colors.passportPageLight,
                    AppTheme.Colors.passportPageDark,
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Grid pattern overlay
            PassportGridPatternView()

            // Content
            content
        }
    }
}

// MARK: - Passport Grid Pattern View

/// Subtle cross-hatch grid pattern overlay for passport page texture
struct PassportGridPatternView: View {
    var body: some View {
        Canvas(opaque: false, colorMode: .linear, rendersAsynchronously: true) { context, size in
            let gridSpacing: CGFloat = 60
            let lineWidth: CGFloat = 0.5

            // Draw vertical lines
            for x in stride(from: 0, to: size.width, by: gridSpacing) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(
                    path,
                    with: .color(AppTheme.Colors.passportPageGrid.opacity(0.3)),
                    lineWidth: lineWidth
                )
            }

            // Draw horizontal lines
            for y in stride(from: 0, to: size.height, by: gridSpacing) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(
                    path,
                    with: .color(AppTheme.Colors.passportPageGrid.opacity(0.3)),
                    lineWidth: lineWidth
                )
            }
        }
        .drawingGroup()
    }
}

// MARK: - Page Curl Decoration

/// Decorative page curl effect for bottom-right corner
struct PageCurlDecoration: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Triangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.black.opacity(0.05),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
            }
        }
    }
}

// MARK: - Triangle Shape

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview

#Preview {
    PassportPageBackgroundView {
        VStack {
            Text("Passport Page Content")
                .font(AppTheme.Typography.serifMedium())
                .foregroundColor(AppTheme.Colors.passportTextPrimary)

            Text("Subtitle text")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.passportTextSecondary)
        }
        .padding()
    }
    .frame(height: 400)
}
