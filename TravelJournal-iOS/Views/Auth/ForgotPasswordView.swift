import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var emailSent = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if emailSent {
                    // Success state
                    VStack(spacing: 16) {
                        Image(systemName: "envelope.badge.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.green)
                        
                        Text("Check Your Email")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("We've sent password reset instructions to \(email)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Done") {
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                    }
                    .padding()
                } else {
                    // Form state
                    VStack(spacing: 16) {
                        Image(systemName: "lock.rotation")
                            .font(.system(size: 60))
                            .foregroundStyle(.blue)
                        
                        Text("Reset Password")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Enter your email address and we'll send you instructions to reset your password.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        
                        TextField("Email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                        
                        if let error = authManager.error {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                        
                        Button {
                            Task {
                                let success = await authManager.forgotPassword(email: email)
                                if success {
                                    emailSent = true
                                }
                            }
                        } label: {
                            if authManager.isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text("Send Reset Link")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(email.isEmpty || authManager.isLoading)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ForgotPasswordView()
        .environmentObject(AuthManager())
}