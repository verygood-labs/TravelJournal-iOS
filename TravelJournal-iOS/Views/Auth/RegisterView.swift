import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var displayName = ""
    
    private var passwordsMatch: Bool {
        password == confirmPassword
    }
    
    private var isFormValid: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        !displayName.isEmpty &&
        passwordsMatch &&
        password.count >= 8
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Create Account")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Start documenting your travels")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 16) {
                        TextField("Display Name", text: $displayName)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.name)
                        
                        TextField("Email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.newPassword)
                        
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.newPassword)
                        
                        if !password.isEmpty && password.count < 8 {
                            Text("Password must be at least 8 characters")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                        
                        if !confirmPassword.isEmpty && !passwordsMatch {
                            Text("Passwords do not match")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                        
                        if let error = authManager.error {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button {
                            Task {
                                await authManager.register(
                                    email: email,
                                    password: password,
                                    displayName: displayName
                                )
                                if authManager.isAuthenticated {
                                    dismiss()
                                }
                            }
                        } label: {
                            if authManager.isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text("Create Account")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!isFormValid || authManager.isLoading)
                    }
                    .padding(.horizontal)
                    
                    Text("By creating an account, you agree to our Terms of Service and Privacy Policy")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.bottom, 32)
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
    RegisterView()
        .environmentObject(AuthManager())
}