import SwiftUI
import PhotosUI

// MARK: - Passport Photo Form Content
/// The form content for step 3 (only the passport page that flips)
struct PassportPhotoFormContent: View {
    // Photo state (bindings from parent for page turn scenario)
    @Binding var selectedImage: UIImage?
    @Binding var showingImagePicker: Bool
    @Binding var showingCamera: Bool
    
    var body: some View {
        PassportPageBackgroundView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    headerSection
                        .padding(.top, AppTheme.Spacing.xl)
                        .padding(.bottom, AppTheme.Spacing.lg)
                    
                    // Photo capture area
                    photoSection
                        .padding(.horizontal, AppTheme.Spacing.lg)
                    
                    Spacer(minLength: AppTheme.Spacing.xxxl)
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
        }
        .fullScreenCover(isPresented: $showingCamera) {
            ImagePicker(image: $selectedImage, sourceType: .camera)
        }
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
    
    // MARK: - Photo Section
    private var photoSection: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Photo display with corner brackets
            ZStack {
                // Photo frame
                Group {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 280, height: 340)
                            .clipped()
                    } else {
                        // Placeholder
                        VStack(spacing: AppTheme.Spacing.sm) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 64, weight: .light))
                                .foregroundColor(AppTheme.Colors.passportTextMuted.opacity(0.4))
                            
                            Text("Select below")
                                .font(AppTheme.Typography.monoSmall())
                                .foregroundColor(AppTheme.Colors.passportTextPlaceholder)
                        }
                        .frame(width: 280, height: 340)
                        .background(AppTheme.Colors.passportInputBackground)
                    }
                }
                .overlay(
                    Rectangle()
                        .stroke(AppTheme.Colors.passportInputBorderFocused, lineWidth: 3)
                )
                
                // Corner brackets
                CornerBrackets()
            }
            .frame(width: 280, height: 340)
            
            // Action buttons
            VStack(spacing: AppTheme.Spacing.xs) {
                // Capture Photo button
                Button {
                    showingCamera = true
                } label: {
                    HStack(spacing: AppTheme.Spacing.xxxs) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 12, weight: .medium))
                        Text("CAPTURE PHOTOGRAPH")
                            .font(AppTheme.Typography.button())
                            .tracking(1)
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                
                // Upload Photo button
                Button {
                    showingImagePicker = true
                } label: {
                    HStack(spacing: AppTheme.Spacing.xxxs) {
                        Image(systemName: "arrow.up.doc.fill")
                            .font(.system(size: 12, weight: .medium))
                        Text("UPLOAD DOCUMENT")
                            .font(AppTheme.Typography.button())
                            .tracking(1)
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
    }
}

// MARK: - Passport Photo View (Standalone)
/// Step 3 of registration: Capture or upload passport photo
/// Use this when presenting as a standalone view (not in page turn)
struct PassportPhotoView: View {
    // Form data passed from previous step
    let email: String
    let password: String
    let fullName: String
    let username: String
    let nationalityId: UUID
    
    // Photo state
    @State private var selectedImage: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    
    // Navigation
    @Environment(\.dismiss) var standardDismiss
    @Environment(\.pageTurnDismiss) var pageTurnDismiss
    @State private var showingNextStep = false
    
    private var hasPhoto: Bool {
        selectedImage != nil
    }
    
    /// Dismisses using page turn if available, otherwise standard dismiss
    private func dismissView() {
        if let pageTurnDismiss {
            pageTurnDismiss()
        } else {
            standardDismiss()
        }
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
                            
                            // Photo capture area
                            photoSection
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
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
        }
        .fullScreenCover(isPresented: $showingCamera) {
            ImagePicker(image: $selectedImage, sourceType: .camera)
        }
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
    
    // MARK: - Photo Section
    private var photoSection: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Photo display with corner brackets
            ZStack {
                // Photo frame
                Group {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 280, height: 340)
                            .clipped()
                    } else {
                        // Placeholder
                        VStack(spacing: AppTheme.Spacing.sm) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 64, weight: .light))
                                .foregroundColor(AppTheme.Colors.passportTextMuted.opacity(0.4))
                            
                            Text("Select below")
                                .font(AppTheme.Typography.monoSmall())
                                .foregroundColor(AppTheme.Colors.passportTextPlaceholder)
                        }
                        .frame(width: 280, height: 340)
                        .background(AppTheme.Colors.passportInputBackground)
                    }
                }
                .overlay(
                    Rectangle()
                        .stroke(AppTheme.Colors.passportInputBorderFocused, lineWidth: 3)
                )
                
                // Corner brackets
                CornerBrackets()
            }
            .frame(width: 280, height: 340)
            
            // Action buttons
            VStack(spacing: AppTheme.Spacing.xs) {
                // Capture Photo button
                Button {
                    showingCamera = true
                } label: {
                    HStack(spacing: AppTheme.Spacing.xxxs) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 12, weight: .medium))
                        Text("CAPTURE PHOTOGRAPH")
                            .font(AppTheme.Typography.button())
                            .tracking(1)
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                
                // Upload Photo button
                Button {
                    showingImagePicker = true
                } label: {
                    HStack(spacing: AppTheme.Spacing.xxxs) {
                        Image(systemName: "arrow.up.doc.fill")
                            .font(.system(size: 12, weight: .medium))
                        Text("UPLOAD DOCUMENT")
                            .font(AppTheme.Typography.button())
                            .tracking(1)
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
    }
    
    // MARK: - Bottom Navigation
    private var bottomNavigation: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            // Back button
            Button {
                dismissView()
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
                proceedToNextStep()
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
            .disabled(!hasPhoto)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(AppTheme.Colors.backgroundDark)
    }
    
    // MARK: - Proceed to Next Step
    private func proceedToNextStep() {
        guard hasPhoto else { return }
        
        // TODO: Upload photo to server
        // TODO: Navigate to next step
        print("Proceeding with photo to next step")
        showingNextStep = true
    }
}

// MARK: - Corner Brackets
private struct CornerBrackets: View {
    var body: some View {
        GeometryReader { geometry in
            let bracketSize: CGFloat = 24
            let offset: CGFloat = -6 // Negative offset to place brackets outside the border
            let lineWidth: CGFloat = 3
            
            ZStack {
                // Top-left bracket
                Path { path in
                    path.move(to: CGPoint(x: offset + bracketSize, y: offset))
                    path.addLine(to: CGPoint(x: offset, y: offset))
                    path.addLine(to: CGPoint(x: offset, y: offset + bracketSize))
                }
                .stroke(AppTheme.Colors.primary, lineWidth: lineWidth)
                
                // Top-right bracket
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width - offset - bracketSize, y: offset))
                    path.addLine(to: CGPoint(x: geometry.size.width - offset, y: offset))
                    path.addLine(to: CGPoint(x: geometry.size.width - offset, y: offset + bracketSize))
                }
                .stroke(AppTheme.Colors.primary, lineWidth: lineWidth)
                
                // Bottom-left bracket
                Path { path in
                    path.move(to: CGPoint(x: offset, y: geometry.size.height - offset - bracketSize))
                    path.addLine(to: CGPoint(x: offset, y: geometry.size.height - offset))
                    path.addLine(to: CGPoint(x: offset + bracketSize, y: geometry.size.height - offset))
                }
                .stroke(AppTheme.Colors.primary, lineWidth: lineWidth)
                
                // Bottom-right bracket
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width - offset, y: geometry.size.height - offset - bracketSize))
                    path.addLine(to: CGPoint(x: geometry.size.width - offset, y: geometry.size.height - offset))
                    path.addLine(to: CGPoint(x: geometry.size.width - offset - bracketSize, y: geometry.size.height - offset))
                }
                .stroke(AppTheme.Colors.primary, lineWidth: lineWidth)
            }
        }
    }
}

// MARK: - Image Picker Wrapper
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.image = originalImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Preview
#Preview {
    PassportPhotoView(
        email: "test@example.com",
        password: "password123",
        fullName: "John Doe",
        username: "johndoe",
        nationalityId: UUID()
    )
}