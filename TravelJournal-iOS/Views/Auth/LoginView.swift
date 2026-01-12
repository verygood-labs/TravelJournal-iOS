import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    
    @State private var email = ""
    @State private var password = ""
    @State private var showingRegister = false
    @State private var showingForgotPassword = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Logo/Header
                    VStack(spacing: 8) {
                        Image(systemName: "globe.americas.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.blue)
                        
                        Text("Travel Journal")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Document your adventures")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Form
                    VStack(spacing: 16) {
                        TextField("Email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.password)
                        
                        if let error = authManager.error {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button {
                            Task {
                                await authManager.login(email: email, password: password)
                            }
                        } label: {
                            if authManager.isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text("Sign In")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(email.isEmpty || password.isEmpty || authManager.isLoading)
                        
                        Button("Forgot Password?") {
                            showingForgotPassword = true
                        }
                        .font(.footnote)
                    }
                    .padding(.horizontal)
                    
                    // Divider
                    HStack {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(height: 1)
                        Text("or")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Rectangle()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.horizontal)
                    
                    // OAuth Buttons
                    VStack(spacing: 12) {
                        Button {
                            // TODO: Implement Google Sign In
                        } label: {
                            HStack {
                                Image(systemName: "g.circle.fill")
                                Text("Continue with Google")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        
                        Button {
                            // TODO: Implement Apple Sign In
                        } label: {
                            HStack {
                                Image(systemName: "apple.logo")
                                Text("Continue with Apple")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.primary)
                    }
                    .padding(.horizontal)
                    
                    // Register Link
                    HStack {
                        Text("Don't have an account?")
                            .foregroundStyle(.secondary)
                        Button("Sign Up") {
                            showingRegister = true
                        }
                    }
                    .font(.footnote)
                }
                .padding(.bottom, 32)
            }
            .sheet(isPresented: $showingRegister) {
                RegisterView()
            }
            .sheet(isPresented: $showingForgotPassword) {
                ForgotPasswordView()
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
}