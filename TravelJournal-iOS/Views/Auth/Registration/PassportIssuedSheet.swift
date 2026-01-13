import SwiftUI

// MARK: - Passport Issued Sheet
/// Success sheet shown after registration submission
/// Displays the issued passport with interactive passport book opening sequence
struct PassportIssuedSheet: View {
    let fullName: String
    let username: String
    let nationalityName: String
    let passportPhoto: UIImage?
    let onContinue: () -> Void
    
    // Animation states - sequential timeline
    @State private var bookAppeared = false
    @State private var showTapHint = false
    @State private var bookOpened = false
    @State private var hasUserInteracted = false
    @State private var stampLanded = false
    @State private var stampBounced = false
    @State private var titleWritten = false
    @State private var subtextRevealed = false
    @State private var buttonRevealed = false
    
    // Drag gesture state for interactive flip
    @State private var dragOffset: CGFloat = 0
    @State private var flipProgress: Double = 0
    
    // Title text for typewriter effect
    private let titleText = "Passport Issued"
    @State private var displayedTitle = ""
    
    var body: some View {
        AppBackgroundView {
            GeometryReader { geometry in
                ZStack {
                    // Main content
                    VStack(spacing: 0) {
                        Spacer()
                        
                        // Passport Book Container
                        ZStack {
                            // Passport card inside (always visible underneath cover)
                            PassportCard(
                                fullName: fullName,
                                username: username,
                                nationalityName: nationalityName,
                                passportPhoto: passportPhoto
                            )
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            .opacity(bookAppeared ? 1 : 0)
                            .overlay(
                                // Stamp on top right of card
                                Group {
                                    if stampLanded {
                                        stampSeal
                                            .offset(x: 120, y: -30)
                                    }
                                }
                            )
                            
                            // Front cover (interactive flip) - matches card size
                            if !bookOpened {
                                passportCover
                                    .padding(.horizontal, AppTheme.Spacing.lg)
                                    .opacity(bookAppeared ? 1 : 0)
                                    .scaleEffect(bookAppeared ? 1 : 0.3)
                                    .offset(y: bookAppeared ? 0 : -100)
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                // Only allow upward drag
                                                if value.translation.height < 0 {
                                                    dragOffset = value.translation.height
                                                    // Convert drag to flip progress (0 to 1)
                                                    flipProgress = min(1.0, abs(Double(dragOffset)) / 150.0)
                                                }
                                            }
                                            .onEnded { value in
                                                if flipProgress > 0.4 || value.predictedEndTranslation.height < -100 {
                                                    // Complete the flip
                                                    openBook()
                                                } else {
                                                    // Snap back
                                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                        dragOffset = 0
                                                        flipProgress = 0
                                                    }
                                                }
                                            }
                                    )
                                    .onTapGesture {
                                        openBook()
                                    }
                            }
                            
                            // Tap hint
                            if showTapHint && !bookOpened {
                                tapHintView
                                    .offset(y: 130)
                            }
                        }
                        .frame(height: 350)
                        
                        Spacer()
                            .frame(height: AppTheme.Spacing.lg)
                        
                        // Header text section
                        VStack(spacing: AppTheme.Spacing.sm) {
                            // Official document badge
                            Text("✦ OFFICIAL DOCUMENT ✦")
                                .font(AppTheme.Typography.monoSmall())
                                .tracking(3)
                                .foregroundColor(AppTheme.Colors.primary.opacity(0.8))
                                .opacity(titleWritten ? 1 : 0)
                                .scaleEffect(titleWritten ? 1 : 0.8)
                            
                            // Typewriter title with checkmark
                            HStack(spacing: AppTheme.Spacing.xs) {
                                Text(displayedTitle)
                                    .font(AppTheme.Typography.serifLarge())
                                    .foregroundColor(AppTheme.Colors.primary)
                                
                                if displayedTitle == titleText {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundColor(AppTheme.Colors.primary)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .frame(height: 36)
                            
                            // Subtext
                            Text("You're ready to start your journey.\nYour passport has been created\nsuccessfully.")
                                .font(AppTheme.Typography.monoSmall())
                                .foregroundColor(AppTheme.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .opacity(subtextRevealed ? 1 : 0)
                                .offset(y: subtextRevealed ? 0 : 15)
                        }
                        
                        Spacer()
                            .frame(height: AppTheme.Spacing.xl)
                        
                        // Continue button
                        Button {
                            onContinue()
                        } label: {
                            HStack(spacing: AppTheme.Spacing.xxxs) {
                                Text("START EXPLORING")
                                    .font(AppTheme.Typography.button())
                                    .tracking(1)
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 12, weight: .medium))
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .opacity(buttonRevealed ? 1 : 0)
                        .offset(y: buttonRevealed ? 0 : 20)
                        
                        Spacer()
                            .frame(height: AppTheme.Spacing.xxl)
                    }
                }
            }
        }
        .onAppear {
            startInitialAnimation()
        }
    }
    
    // MARK: - Open Book Action
    private func openBook() {
        hasUserInteracted = true
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            bookOpened = true
            flipProgress = 1.0
            dragOffset = 0
            showTapHint = false
        }
        
        // Continue with post-open animations
        startPostOpenAnimations()
    }
    
    // MARK: - Initial Animation (Book appears)
    private func startInitialAnimation() {
        // Step 1: Passport book drops in
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
            bookAppeared = true
        }
        
        // Step 2: Show tap hint after book lands
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if !hasUserInteracted {
                withAnimation(.easeInOut(duration: 0.4)) {
                    showTapHint = true
                }
            }
        }
    }
    
    // MARK: - Post-Open Animations
    private func startPostOpenAnimations() {
        // Step 1: Stamp lands (1.0s after open)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                stampLanded = true
            }
            // Bounce effect
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                    stampBounced = true
                }
            }
        }
        
        // Step 2: Title badge appears (1.5s after open)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                titleWritten = true
            }
            // Start typewriter effect
            typewriterEffect()
        }
        
        // Step 3: Subtext eases in (1.9s after open)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
            withAnimation(.easeOut(duration: 0.5)) {
                subtextRevealed = true
            }
        }
        
        // Step 4: Button appears (2.3s after open)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
            withAnimation(.easeOut(duration: 0.4)) {
                buttonRevealed = true
            }
        }
    }
    
    // MARK: - Typewriter Effect
    private func typewriterEffect() {
        displayedTitle = ""
        for (index, character) in titleText.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                withAnimation(.easeOut(duration: 0.1)) {
                    displayedTitle += String(character)
                }
            }
        }
    }
    
    // MARK: - Tap Hint View
    private var tapHintView: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Image(systemName: "hand.tap.fill")
                .font(.system(size: 24))
                .foregroundColor(AppTheme.Colors.primary.opacity(0.7))
            
            Text("Tap or swipe up to open")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.primary.opacity(0.7))
        }
        .padding(.vertical, AppTheme.Spacing.sm)
        .padding(.horizontal, AppTheme.Spacing.md)
        .background(
            Capsule()
                .fill(AppTheme.Colors.primary.opacity(0.1))
                .overlay(
                    Capsule()
                        .stroke(AppTheme.Colors.primary.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Passport Cover (Interactive)
    private var passportCover: some View {
        // Invisible PassportCard to get the exact size
        PassportCard(
            fullName: fullName,
            username: username,
            nationalityName: nationalityName,
            passportPhoto: passportPhoto
        )
        .opacity(0)
        .overlay(
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.18, green: 0.30, blue: 0.24),
                                Color(red: 0.12, green: 0.22, blue: 0.17)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .overlay(
                        VStack(spacing: AppTheme.Spacing.sm) {
                            // Emblem
                            Image(systemName: "globe.americas.fill")
                                .font(.system(size: 40, weight: .light))
                                .foregroundColor(AppTheme.Colors.primary.opacity(0.6))
                            
                            Text("TRAVEL")
                                .font(AppTheme.Typography.monoSmall())
                                .tracking(6)
                                .foregroundColor(AppTheme.Colors.primary.opacity(0.8))
                            
                            Text("JOURNAL")
                                .font(AppTheme.Typography.serifMedium())
                                .foregroundColor(AppTheme.Colors.primary)
                            
                            Rectangle()
                                .fill(AppTheme.Colors.primary.opacity(0.3))
                                .frame(width: 60, height: 1)
                            
                            Text("PASSPORT")
                                .font(AppTheme.Typography.monoSmall())
                                .tracking(4)
                                .foregroundColor(AppTheme.Colors.primary.opacity(0.6))
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                            .stroke(AppTheme.Colors.primary.opacity(0.4), lineWidth: 2)
                    )
                    .overlay(
                        // Corner decorations
                        ZStack {
                            cornerDecoration.position(x: 20, y: 20)
                            cornerDecoration.rotationEffect(.degrees(90)).position(x: geometry.size.width - 20, y: 20)
                            cornerDecoration.rotationEffect(.degrees(-90)).position(x: 20, y: geometry.size.height - 20)
                            cornerDecoration.rotationEffect(.degrees(180)).position(x: geometry.size.width - 20, y: geometry.size.height - 20)
                        }
                    )
                    .shadow(color: .black.opacity(0.4), radius: 15, y: 8)
                    // 3D rotation for opening effect - flips from top edge like a book cover
                    .rotation3DEffect(
                        .degrees(flipProgress * 180),
                        axis: (x: 1, y: 0, z: 0),
                        anchor: .top,
                        perspective: 0.3
                    )
            }
        )
    }
    
    // MARK: - Corner Decoration
    private var cornerDecoration: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 15))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 15, y: 0))
        }
        .stroke(AppTheme.Colors.primary.opacity(0.4), lineWidth: 1)
        .frame(width: 15, height: 15)
    }
    
    // MARK: - Stamp Seal
    private var stampSeal: some View {
        ZStack {
            // Outer ring with dashes
            Circle()
                .strokeBorder(
                    AppTheme.Colors.primary,
                    style: StrokeStyle(lineWidth: 2, dash: [3, 3])
                )
                .frame(width: 60, height: 60)
            
            // Inner circle
            Circle()
                .stroke(AppTheme.Colors.primary, lineWidth: 2)
                .frame(width: 48, height: 48)
            
            // Filled background
            Circle()
                .fill(AppTheme.Colors.primary.opacity(0.15))
                .frame(width: 44, height: 44)
            
            // Checkmark
            Image(systemName: "checkmark")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(AppTheme.Colors.primary)
        }
        .scaleEffect(stampLanded ? (stampBounced ? 1.0 : 1.4) : 3.0)
        .opacity(stampLanded ? 1 : 0)
        .rotationEffect(.degrees(stampLanded ? -12 : -45))
        .shadow(
            color: AppTheme.Colors.primary.opacity(stampBounced ? 0.4 : 0),
            radius: stampBounced ? 8 : 0
        )
    }
}

// MARK: - Preview
#Preview {
    PassportIssuedSheet(
        fullName: "Ralph Buan",
        username: "rjbuan",
        nationalityName: "Philippines",
        passportPhoto: nil,
        onContinue: {}
    )
}
