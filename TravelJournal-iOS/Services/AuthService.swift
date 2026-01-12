import Foundation

class AuthService {
    static let shared = AuthService()
    private let api = APIService.shared
    
    private init() {}
    
    func register(email: String, password: String, displayName: String) async throws -> AuthResponse {
        let request = RegisterRequest(
            email: email,
            password: password,
            displayName: displayName
        )
        
        let response: AuthResponse = try await api.request(
            endpoint: "/auth/register",
            method: "POST",
            body: request,
            authenticated: false
        )
        
        api.setTokens(access: response.accessToken, refresh: response.refreshToken)
        return response
    }
    
    func login(email: String, password: String) async throws -> AuthResponse {
        let request = LoginRequest(email: email, password: password)
        
        let response: AuthResponse = try await api.request(
            endpoint: "/auth/login",
            method: "POST",
            body: request,
            authenticated: false
        )
        
        api.setTokens(access: response.accessToken, refresh: response.refreshToken)
        return response
    }
    
    func logout() async throws {
        try await api.requestVoid(
            endpoint: "/auth/logout",
            method: "POST"
        )
        api.clearTokens()
    }
    
    func forgotPassword(email: String) async throws {
        let request = ForgotPasswordRequest(email: email)
        try await api.requestVoid(
            endpoint: "/auth/forgot-password",
            method: "POST",
            body: request,
            authenticated: false
        )
    }
    
    func resetPassword(token: String, email: String, newPassword: String) async throws {
        let request = ResetPasswordRequest(
            token: token,
            email: email,
            newPassword: newPassword
        )
        try await api.requestVoid(
            endpoint: "/auth/reset-password",
            method: "POST",
            body: request,
            authenticated: false
        )
    }
    
    func signInWithGoogle(idToken: String) async throws -> AuthResponse {
        let request = GoogleAuthRequest(idToken: idToken)
        
        let response: AuthResponse = try await api.request(
            endpoint: "/auth/google",
            method: "POST",
            body: request,
            authenticated: false
        )
        
        api.setTokens(access: response.accessToken, refresh: response.refreshToken)
        return response
    }
    
    func signInWithApple(
        identityToken: String,
        authorizationCode: String,
        email: String?,
        firstName: String?,
        lastName: String?
    ) async throws -> AuthResponse {
        var userInfo: AppleUserInfo? = nil
        if email != nil || firstName != nil || lastName != nil {
            userInfo = AppleUserInfo(
                email: email,
                name: AppleUserName(firstName: firstName, lastName: lastName)
            )
        }
        
        let request = AppleAuthRequest(
            identityToken: identityToken,
            authorizationCode: authorizationCode,
            user: userInfo
        )
        
        let response: AuthResponse = try await api.request(
            endpoint: "/auth/apple",
            method: "POST",
            body: request,
            authenticated: false
        )
        
        api.setTokens(access: response.accessToken, refresh: response.refreshToken)
        return response
    }
}