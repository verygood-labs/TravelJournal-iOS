import Combine
import Foundation
import SwiftUI

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var error: String?

    /// Convenience property for current user's ID
    var currentUserId: UUID? {
        currentUser?.id
    }

    private let authService = AuthService.shared
    private let api = APIService.shared
    private var sessionExpiredObserver: NSObjectProtocol?

    /// Returns true when running in SwiftUI preview canvas
    private static var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    init() {
        // Skip real initialization in previews
        guard !Self.isPreview else { return }

        // Check if user is already logged in
        isAuthenticated = api.isAuthenticated

        if isAuthenticated {
            Task {
                await loadCurrentUser()
            }
        }

        // Listen for session expiration from APIService
        sessionExpiredObserver = NotificationCenter.default.addObserver(
            forName: APIService.sessionExpiredNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.handleSessionExpired()
            }
        }
    }

    deinit {
        if let observer = sessionExpiredObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    /// Called when the API detects the session has expired
    private func handleSessionExpired() {
        currentUser = nil
        isAuthenticated = false
        error = "Your session has expired. Please log in again."
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
                id: profile.userId, // Changed from profile.id
                email: profile.email,
                name: profile.name,
                userName: profile.userName,
                profilePictureUrl: profile.profilePictureUrl
            )
        } catch {
            // Token might be invalid, clear auth state
            api.clearTokens()
            isAuthenticated = false
            currentUser = nil
        }
    }
}
