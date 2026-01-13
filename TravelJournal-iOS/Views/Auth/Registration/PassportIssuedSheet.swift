import SwiftUI

// MARK: - Passport Issued Sheet
/// Success sheet shown after registration submission
/// Displays the issued passport with animated checkmark
struct PassportIssuedSheet: View {
    let fullName: String
    let username: String
    let nationalityName: String
    let passportPhoto: UIImage?
    let onContinue: () -> Void
    
    @State private var showCheckmark = false
    @State private var showContent = false
    @State private var isPulsing = false
    
    var body: some View {
        AppBackgroundView {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    Spacer()
                        .frame(height: AppTheme.Spacing.xxl)
                    
                    // Animated checkmark seal
                    checkmarkSeal
                        .opacity(showCheckmark ? 1 : 0)
                        .scaleEffect(showCheckmark ? 1 : 0.5)
                    
                    // Official document header
                    VStack(spacing: AppTheme.Spacing.sm) {
                        Text("✦ OFFICIAL DOCUMENT ✦")
                            .font(AppTheme.Typography.monoSmall())
                            .tracking(3)
                            .foregroundColor(AppTheme.Colors.primary.opacity(0.8))
                        
                        Text("Passport Issued")
                            .font(AppTheme.Typography.serifLarge())
                            .foregroundColor(AppTheme.Colors.primary)
                        
                        Text("You're ready to start your journey.\nYour passport has been created\nsuccessfully.")
                            .font(AppTheme.Typography.monoSmall())
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    
                    // Passport card
                    PassportCard(
                        fullName: fullName,
                        username: username,
                        nationalityName: nationalityName,
                        passportPhoto: passportPhoto
                    )
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 30)
                    
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
                    .opacity(showContent ? 1 : 0)
                    
                    Spacer()
                        .frame(height: AppTheme.Spacing.xxl)
                }
            }
        }
        .onAppear {
            // Staggered animations
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                showCheckmark = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
                showContent = true
            }
            // Start pulsing after stamp animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                isPulsing = true
            }
        }
    }
    
    // MARK: - Checkmark Seal
    private var checkmarkSeal: some View {
        ZStack {
            // Pulsating glow ring
            Circle()
                .fill(AppTheme.Colors.primary.opacity(0.15))
                .frame(width: 160, height: 160)
                .scaleEffect(isPulsing ? 1.15 : 1.0)
                .opacity(isPulsing ? 0 : 0.5)
                .animation(
                    isPulsing ? .easeInOut(duration: 1.5).repeatForever(autoreverses: false) : .default,
                    value: isPulsing
                )
            
            // Outer dashed ring
            Circle()
                .strokeBorder(
                    AppTheme.Colors.primary.opacity(0.3),
                    style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                )
                .frame(width: 160, height: 160)
            
            // Inner solid ring with pulse shadow
            Circle()
                .stroke(AppTheme.Colors.primary, lineWidth: 4)
                .frame(width: 140, height: 140)
                .shadow(
                    color: AppTheme.Colors.primary.opacity(isPulsing ? 0.4 : 0),
                    radius: isPulsing ? 15 : 0
                )
                .animation(
                    isPulsing ? .easeInOut(duration: 1.5).repeatForever(autoreverses: true) : .default,
                    value: isPulsing
                )
            
            // Background circle
            Circle()
                .fill(AppTheme.Colors.primary.opacity(0.1))
                .frame(width: 134, height: 134)
            
            // Checkmark
            Image(systemName: "checkmark")
                .font(.system(size: 60, weight: .medium))
                .foregroundColor(AppTheme.Colors.primary)
        }
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
