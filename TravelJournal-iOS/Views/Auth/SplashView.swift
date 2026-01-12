import SwiftUI

// MARK: - Splash View
/// Initial splash screen with animated globe and passport branding
struct SplashView: View {
    @EnvironmentObject var authManager: AuthManager
    
    // Animation states
    @State private var showGlobe = false
    @State private var showTitle = false
    @State private var showButtons = false
    @State private var floatOffset: CGFloat = 0
    
    // Navigation states
    @State private var showingLogin = false
    @State private var showingRegister = false
    
    var body: some View {
        AppBackgroundView {
            ZStack {
                // Corner accents
                CornerAccentsView()
                
                // Floating decorative stamps
                decorativeStamps
                
                // Main content
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Animated Globe
                    AnimatedGlobeView(size: 100)
                        .offset(y: floatOffset)
                        .opacity(showGlobe ? 1 : 0)
                        .offset(y: showGlobe ? 0 : 20)
                        .padding(.bottom, AppTheme.Spacing.xl)
                    
                    // Title Section
                    titleSection
                        .opacity(showTitle ? 1 : 0)
                        .offset(y: showTitle ? 0 : 20)
                    
                    Spacer()
                    
                    // CTA Buttons
                    buttonSection
                        .opacity(showButtons ? 1 : 0)
                        .offset(y: showButtons ? 0 : 40)
                        .padding(.bottom, AppTheme.Spacing.xxxl)
                    
                    // Version
                    versionLabel
                        .opacity(showButtons ? 1 : 0)
                        .padding(.bottom, AppTheme.Spacing.lg)
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
            }
        }
        .onAppear {
            startAnimations()
        }
        .fullScreenCover(isPresented: $showingLogin) {
            LoginView()
                .environmentObject(authManager)
        }
        .fullScreenCover(isPresented: $showingRegister) {
            AccountCredentialsView()
                .environmentObject(authManager)
        }
    }
    
    // MARK: - Title Section
    private var titleSection: some View {
        VStack(spacing: AppTheme.Spacing.xxs) {
            Text("DIGITAL")
                .font(AppTheme.Typography.monoCaption())
                .tracking(4)
                .foregroundColor(AppTheme.Colors.primary.opacity(0.6))
            
            Text("PASSPORT")
                .font(AppTheme.Typography.serifLarge())
                .foregroundColor(AppTheme.Colors.primary)
            
            Text("YOUR JOURNEY • YOUR STORY")
                .font(AppTheme.Typography.monoCaption())
                .tracking(2)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .padding(.top, AppTheme.Spacing.xxxs)
        }
    }
    
    // MARK: - Button Section
    private var buttonSection: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Button("CREATE PASSPORT") {
                showingRegister = true
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Button("I HAVE A PASSPORT") {
                showingLogin = true
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }
    
    // MARK: - Version Label
    private var versionLabel: some View {
        Text("v1.0.0 • VERY GOOD EDITION")
            .font(AppTheme.Typography.monoTiny())
            .tracking(1)
            .foregroundColor(AppTheme.Colors.textPrimary.opacity(0.3))
    }
    
    // MARK: - Decorative Stamps
    private var decorativeStamps: some View {
        GeometryReader { geometry in
            // Tokyo stamp (top right)
            StampView(text: "TOKYO", style: .circular)
                .rotationEffect(.degrees(15))
                .position(x: geometry.size.width * 0.85, y: geometry.size.height * 0.15)
            
            // Paris stamp (bottom left)
            StampView(text: "PARIS ✦", style: .rectangular)
                .rotationEffect(.degrees(-10))
                .position(x: geometry.size.width * 0.15, y: geometry.size.height * 0.75)
            
            // Rome stamp (left side)
            StampView(text: "ROME", style: .rectangular)
                .rotationEffect(.degrees(-5))
                .opacity(0.7)
                .position(x: geometry.size.width * 0.12, y: geometry.size.height * 0.35)
            
            // Airplane stamp (top left)
            StampView(text: "✈", style: .circular)
                .rotationEffect(.degrees(8))
                .opacity(0.5)
                .position(x: geometry.size.width * 0.20, y: geometry.size.height * 0.20)
        }
    }
    
    // MARK: - Animations
    private func startAnimations() {
        // Globe fade in
        withAnimation(.easeOut(duration: AppTheme.Animation.slow)) {
            showGlobe = true
        }
        
        // Title fade in (delayed)
        withAnimation(.easeOut(duration: AppTheme.Animation.slow).delay(0.2)) {
            showTitle = true
        }
        
        // Buttons fade in (more delayed)
        withAnimation(.easeOut(duration: 0.8).delay(0.4)) {
            showButtons = true
        }
        
        // Floating animation for globe
        withAnimation(
            .easeInOut(duration: AppTheme.Animation.float)
            .repeatForever(autoreverses: true)
        ) {
            floatOffset = -10
        }
    }
}

// MARK: - Stamp View
struct StampView: View {
    let text: String
    var style: StampStyle = .rectangular
    var opacity: Double = 0.15
    
    enum StampStyle {
        case circular
        case rectangular
    }
    
    var body: some View {
        Text(text)
            .font(AppTheme.Typography.monoTiny())
            .tracking(1)
            .foregroundColor(AppTheme.Colors.primary)
            .padding(.horizontal, style == .circular ? 8 : 12)
            .padding(.vertical, style == .circular ? 8 : 6)
            .overlay(
                Group {
                    if style == .circular {
                        Circle()
                            .stroke(AppTheme.Colors.primary, lineWidth: 2)
                    } else {
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                            .stroke(AppTheme.Colors.primary, lineWidth: 2)
                    }
                }
            )
            .opacity(opacity)
    }
}

// MARK: - Preview
#Preview {
    SplashView()
        .environmentObject(AuthManager())
}
