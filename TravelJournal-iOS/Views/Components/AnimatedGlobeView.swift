import SwiftUI

// MARK: - Animated Globe View
/// Animated globe icon with pulsing glow, rotating longitude, and blinking city dots
/// Usage: AnimatedGlobeView(size: 100)
struct AnimatedGlobeView: View {
    var size: CGFloat = 80
    var color: Color = AppTheme.Colors.primary
    
    // Animation states
    @State private var isPulsing = false
    @State private var rotationAngle: Double = 0
    @State private var cityDotScales: [CGFloat] = [1, 1, 1, 1]
    @State private var cityDotOpacities: [Double] = [0.5, 0.5, 0.5, 0.5]
    
    var body: some View {
        ZStack {
            // Outer glow (pulsing)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            color.opacity(0.3),
                            color.opacity(0.1),
                            color.opacity(0)
                        ],
                        center: .center,
                        startRadius: size * 0.3,
                        endRadius: size * 0.5
                    )
                )
                .frame(width: size, height: size)
                .scaleEffect(isPulsing ? 1.05 : 1.0)
                .opacity(isPulsing ? 0.6 : 0.3)
            
            // Main globe circle
            Circle()
                .stroke(color, lineWidth: 2)
                .frame(width: size * 0.8, height: size * 0.8)
            
            // Latitude line 1 (narrow)
            Ellipse()
                .stroke(color.opacity(0.5), lineWidth: 1)
                .frame(width: size * 0.8, height: size * 0.3)
            
            // Latitude line 2 (wider)
            Ellipse()
                .stroke(color.opacity(0.3), lineWidth: 1)
                .frame(width: size * 0.8, height: size * 0.6)
            
            // Longitude line (rotating)
            Ellipse()
                .stroke(color.opacity(0.5), lineWidth: 1)
                .frame(width: size * 0.3, height: size * 0.8)
                .rotation3DEffect(
                    .degrees(rotationAngle),
                    axis: (x: 0, y: 1, z: 0)
                )
            
            // Center meridian (vertical line)
            Rectangle()
                .fill(color.opacity(0.3))
                .frame(width: 1, height: size * 0.8)
            
            // Equator (horizontal line)
            Rectangle()
                .fill(color.opacity(0.3))
                .frame(width: size * 0.8, height: 1)
            
            // City dots
            CityDotsView(
                size: size,
                color: color,
                scales: cityDotScales,
                opacities: cityDotOpacities
            )
        }
        .frame(width: size, height: size)
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Pulse animation
        withAnimation(
            .easeInOut(duration: AppTheme.Animation.pulse)
            .repeatForever(autoreverses: true)
        ) {
            isPulsing = true
        }
        
        // Globe rotation animation
        withAnimation(
            .linear(duration: 20)
            .repeatForever(autoreverses: false)
        ) {
            rotationAngle = 360
        }
        
        // City dot animations with staggered delays
        for i in 0..<4 {
            let delay = Double(i) * 0.5
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(
                    .easeInOut(duration: 2)
                    .repeatForever(autoreverses: true)
                ) {
                    cityDotScales[i] = 1.3
                    cityDotOpacities[i] = 1.0
                }
            }
        }
    }
}

// MARK: - City Dots View
struct CityDotsView: View {
    let size: CGFloat
    let color: Color
    let scales: [CGFloat]
    let opacities: [Double]
    
    // Dot positions as percentages of the globe size
    private let positions: [(x: CGFloat, y: CGFloat)] = [
        (0.35, 0.35),
        (0.65, 0.40),
        (0.45, 0.60),
        (0.70, 0.55)
    ]
    
    var body: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .fill(color)
                    .frame(width: size * 0.06, height: size * 0.06)
                    .scaleEffect(scales[index])
                    .opacity(opacities[index])
                    .position(
                        x: size * positions[index].x,
                        y: size * positions[index].y
                    )
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        AppBackgroundView {
            VStack(spacing: 40) {
                AnimatedGlobeView(size: 100)
                AnimatedGlobeView(size: 60)
            }
        }
    }
}