import SwiftUI

// MARK: - Profile Picture View
/// Step 3 of registration: Choose or upload a profile picture
struct ProfilePictureView: View {
    // Data from previous steps
    let email: String
    let password: String
    let fullName: String
    let username: String
    let nationalityId: String
    
    // Avatar options
    private let avatarOptions = [
        "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&q=80",
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&q=80",
        "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&q=80",
        "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&q=80",
        "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&q=80",
        "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150&q=80",
    ]
    
    // State
    @State private var selectedAvatarUrl: String? = nil
    @State private var showingImagePicker = false
    @State private var showingNextStep = false
    
    // Navigation
    @Environment(\.dismiss) var dismiss
    
    private var isFormValid: Bool {
        selectedAvatarUrl != nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress bar with app background
            AppBackgroundView {
                RegistrationProgressBar(currentStep: 3, totalSteps: 4)
            }
            .frame(height: 80)
            
            // Passport page content
            PassportPageBackgroundView {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 0) {
                            // Header
                            headerSection
                                .padding(.top, AppTheme.Spacing.xl)
                                .padding(.bottom, AppTheme.Spacing.lg)
                            
                            // Photo preview
                            photoPreviewSection
                                .padding(.bottom, AppTheme.Spacing.lg)
                            
                            // Avatar selection
                            avatarSelectionSection
                                .padding(.horizontal, AppTheme.Spacing.lg)
                            
                            Spacer(minLength: AppTheme.Spacing.xxxl)
                        }
                    }
                    
                    // Bottom navigation
                    bottomNavigation
                }
            }
        }
        .background(AppTheme.Colors.backgroundDark)
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Text("✦ PHOTO PAGE ✦")
                .font(AppTheme.Typography.monoSmall())
                .tracking(2)
                .foregroundColor(AppTheme.Colors.passportTextMuted)
            
            Text("Passport Photo")
                .font(AppTheme.Typography.serifMedium())
                .foregroundColor(AppTheme.Colors.passportTextPrimary)
            
            Text("Every passport needs a photo. Choose yours.")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.passportTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
    
    // MARK: - Photo Preview Section
    private var photoPreviewSection: some View {
        ZStack {
            // Photo frame
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .fill(
                    selectedAvatarUrl != nil
                        ? Color.clear
                        : AppTheme.Colors.passportTextPrimary.opacity(0.05)
                )
                .frame(width: 120, height: 150)
                .overlay(
                    Group {
                        if let url = selectedAvatarUrl {
                            AsyncImage(url: URL(string: url)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 120, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
                        } else {
                            VStack(spacing: AppTheme.Spacing.xxs) {
                                Text("📷")
                                    .font(.system(size: 40))
                                    .opacity(0.3)
                                Text("Select below")
                                    .font(AppTheme.Typography.monoCaption())
                                    .foregroundColor(AppTheme.Colors.passportTextMuted)
                            }
                        }
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .stroke(AppTheme.Colors.passportTextPrimary, lineWidth: 4)
                )
            
            // Corner accents
            CornerAccentsView(size: 16, offset: 6)
                .frame(width: 120 + 12, height: 150 + 12)
            
            // Selected badge
            if selectedAvatarUrl != nil {
                Text("✓ Selected")
                    .font(AppTheme.Typography.monoCaption())
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, AppTheme.Spacing.sm)
                    .padding(.vertical, AppTheme.Spacing.xxxs)
                    .background(Color.green)
                    .cornerRadius(10)
                    .offset(y: 85)
            }
        }
    }
    
    // MARK: - Avatar Selection Section
    private var avatarSelectionSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Text("CHOOSE AN AVATAR")
                .font(AppTheme.Typography.inputLabel())
                .tracking(1)
                .foregroundColor(AppTheme.Colors.passportTextMuted)
            
            // Avatar grid (3 columns)
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: AppTheme.Spacing.md) {
                ForEach(avatarOptions, id: \.self) { avatarUrl in
                    AvatarOptionView(
                        url: avatarUrl,
                        isSelected: selectedAvatarUrl == avatarUrl,
                        onSelect: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedAvatarUrl = avatarUrl
                            }
                        }
                    )
                }
            }
            
            // Upload button
            Button {
                showingImagePicker = true
            } label: {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Text("📤")
                    Text("Upload your own photo")
                        .font(AppTheme.Typography.monoSmall())
                }
                .foregroundColor(AppTheme.Colors.passportTextMuted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                        .foregroundColor(AppTheme.Colors.passportInputBorder)
                )
            }
            .padding(.top, AppTheme.Spacing.sm)
        }
    }
    
    // MARK: - Bottom Navigation
    private var bottomNavigation: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            // Back button
            Button {
                dismiss()
            } label: {
                HStack(spacing: AppTheme.Spacing.xxxs) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 12, weight: .medium))
                    Text("BACK")
                        .font(AppTheme.Typography.button())
                        .tracking(1)
                }
            }
            .buttonStyle(SecondaryButtonStyle())
            .frame(width: 120)
            
            // Continue button
            Button {
                // TODO: Navigate to next step or complete registration
                showingNextStep = true
            } label: {
                HStack(spacing: AppTheme.Spacing.xxxs) {
                    Text("CONTINUE")
                        .font(AppTheme.Typography.button())
                        .tracking(1)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .medium))
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!isFormValid)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(AppTheme.Colors.backgroundDark)
    }
}

// MARK: - Avatar Option View
struct AvatarOptionView: View {
    let url: String
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            AsyncImage(url: URL(string: url)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(AppTheme.Colors.passportTextMuted.opacity(0.2))
                    .overlay(ProgressView().scaleEffect(0.7))
            }
            .frame(width: 72, height: 72)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(
                        isSelected ? AppTheme.Colors.goldAccent : Color.clear,
                        lineWidth: 3
                    )
            )
            .overlay(
                Circle()
                    .stroke(
                        isSelected ? AppTheme.Colors.goldAccent.opacity(0.3) : Color.clear,
                        lineWidth: isSelected ? 8 : 0
                    )
                    .scaleEffect(isSelected ? 1.1 : 1)
            )
            .shadow(
                color: isSelected ? AppTheme.Colors.goldAccent.opacity(0.3) : Color.black.opacity(0.1),
                radius: isSelected ? 8 : 4,
                y: 2
            )
            .scaleEffect(isSelected ? 1.05 : 1)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
}

// MARK: - Preview
#Preview {
    ProfilePictureView(
        email: "test@example.com",
        password: "password123",
        fullName: "John Doe",
        username: "johndoe",
        nationalityId: "some-uuid"
    )
}
