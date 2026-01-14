import Foundation
import SwiftUI
import Combine

@MainActor
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var error: String?
    
    private let authService = AuthService.shared
    private let api = APIService.shared
    
    init() {
        // Check if user is already logged in
        isAuthenticated = api.isAuthenticated
        
        if isAuthenticated {
            Task {
                await loadCurrentUser()
            }
        }
    }
    
    func login(email: String, password: String) async {
        isLoading = true
        error = nil
        
        do {
            let response = try await authService.login(email: email, password: password)
            currentUser = response.user
            isAuthenticated = true
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = "An unexpected error occurred"
        }
        
        isLoading = false
    }
    
    func register(email: String, password: String, name: String, userName: String) async {
        isLoading = true
        error = nil
        
        do {
            let response = try await authService.register(
                email: email,
                password: password,
                name: name,
                userName: userName
            )
            currentUser = response.user
            isAuthenticated = true
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = "An unexpected error occurred"
        }
        
        isLoading = false
    }
    
    func logout() async {
        isLoading = true
        
        do {
            try await authService.logout()
        } catch {
            // Even if logout fails on server, clear local state
            print("Logout error: \(error)")
        }
        
        api.clearTokens()
        currentUser = nil
        isAuthenticated = false
        isLoading = false
    }
    
    func forgotPassword(email: String) async -> Bool {
        isLoading = true
        error = nil
        
        do {
            try await authService.forgotPassword(email: email)
            isLoading = false
            return true
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = "An unexpected error occurred"
        }
        
        isLoading = false
        return false
    }
    
    private func loadCurrentUser() async {
        do {
            let profile = try await ProfileService.shared.getProfile()
            currentUser = User(
                id: profile.id,
                email: profile.email,
                name: profile.displayName,
                userName: profile.displayName,
                profilePictureUrl: profile.avatarUrl
            )
        } catch {
            // Token might be invalid, clear auth state
            api.clearTokens()
            isAuthenticated = false
            currentUser = nil
        }
    }
}