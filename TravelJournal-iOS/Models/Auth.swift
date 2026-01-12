import Foundation

struct AuthResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date
    let user: User
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let displayName: String
}

struct RefreshTokenRequest: Codable {
    let refreshToken: String
}

struct ForgotPasswordRequest: Codable {
    let email: String
}

struct ResetPasswordRequest: Codable {
    let token: String
    let email: String
    let newPassword: String
}

struct GoogleAuthRequest: Codable {
    let idToken: String
}

struct AppleAuthRequest: Codable {
    let identityToken: String
    let authorizationCode: String
    let user: AppleUserInfo?
}

struct AppleUserInfo: Codable {
    let email: String?
    let name: AppleUserName?
}

struct AppleUserName: Codable {
    let firstName: String?
    let lastName: String?
}