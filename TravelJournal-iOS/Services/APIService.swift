import Foundation

final class APIService: @unchecked Sendable {
    static let shared = APIService()
    
    private let baseURL: String
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    // Enable/disable API logging
    var enableLogging: Bool = true
    
    private init() {
        #if DEBUG
        // Use 127.0.0.1 instead of localhost to avoid network warnings
        self.baseURL = "http://127.0.0.1:5151/api"
        #else
        self.baseURL = "https://api.yourdomain.com/api"
        #endif
        
        // Configure URLSession with proper timeouts
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        configuration.waitsForConnectivity = true
        self.session = URLSession(configuration: configuration)
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    // MARK: - Token Management
    
    private var accessToken: String? {
        get { KeychainService.shared.get(key: "accessToken") }
        set {
            if let token = newValue {
                KeychainService.shared.save(key: "accessToken", value: token)
            } else {
                KeychainService.shared.delete(key: "accessToken")
            }
        }
    }
    
    private var refreshToken: String? {
        get { KeychainService.shared.get(key: "refreshToken") }
        set {
            if let token = newValue {
                KeychainService.shared.save(key: "refreshToken", value: token)
            } else {
                KeychainService.shared.delete(key: "refreshToken")
            }
        }
    }
    
    func setTokens(access: String, refresh: String) {
        self.accessToken = access
        self.refreshToken = refresh
    }
    
    func clearTokens() {
        self.accessToken = nil
        self.refreshToken = nil
    }
    
    var isAuthenticated: Bool {
        accessToken != nil
    }
    
    // MARK: - Logging
    
    private func logRequest(method: String, url: URL, headers: [String: String], body: Data?) {
        guard enableLogging else { return }
        
        print("\n🌐 ===== API REQUEST =====")
        print("📍 \(method) \(url.absoluteString)")
        print("📋 Headers:")
        headers.forEach { key, value in
            // Mask token for security
            if key == "Authorization" {
                print("  \(key): Bearer ***")
            } else {
                print("  \(key): \(value)")
            }
        }
        
        if let body = body, let jsonString = String(data: body, encoding: .utf8) {
            print("📦 Body:")
            print(jsonString)
        }
        print("========================\n")
    }
    
    private func logResponse(statusCode: Int, data: Data, url: URL) {
        guard enableLogging else { return }
        
        print("\n✅ ===== API RESPONSE =====")
        print("📍 URL: \(url.absoluteString)")
        print("📊 Status: \(statusCode)")
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📦 Response Data:")
            // Try to pretty print JSON
            if let jsonData = jsonString.data(using: .utf8),
               let jsonObject = try? JSONSerialization.jsonObject(with: jsonData),
               let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                print(prettyString)
            } else {
                print(jsonString)
            }
        }
        print("==========================\n")
    }
    
    private func logError(_ error: Error, url: URL) {
        guard enableLogging else { return }
        
        print("\n❌ ===== API ERROR =====")
        print("📍 URL: \(url.absoluteString)")
        print("⚠️ Error: \(error.localizedDescription)")
        print("========================\n")
    }
    
    // MARK: - Request Building
    
    private func buildRequest(
        endpoint: String,
        method: String,
        body: Data? = nil,
        authenticated: Bool = true
    ) -> URLRequest {
        let url = URL(string: "\(baseURL)\(endpoint)")!
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if authenticated, let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = body
        return request
    }
    
    // MARK: - Request Execution
    
    func request<T: Codable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil,
        authenticated: Bool = true,
        retryCount: Int = 0
    ) async throws -> T {
        var bodyData: Data? = nil
        if let body = body {
            bodyData = try encoder.encode(body)
        }
        
        let request = buildRequest(
            endpoint: endpoint,
            method: method,
            body: bodyData,
            authenticated: authenticated
        )
        
        // Log the request
        logRequest(
            method: method,
            url: request.url!,
            headers: request.allHTTPHeaderFields ?? [:],
            body: bodyData
        )
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            logError(error, url: request.url!)
            throw APIError.networkError(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }
        
        // Log the response
        logResponse(statusCode: httpResponse.statusCode, data: data, url: request.url!)
        
        // Handle token refresh on 401 (prevent infinite loop with retryCount)
        if httpResponse.statusCode == 401 && authenticated && retryCount == 0 {
            if try await refreshAccessToken() {
                // Retry the request with new token (only once)
                return try await self.request(
                    endpoint: endpoint,
                    method: method,
                    body: body,
                    authenticated: authenticated,
                    retryCount: retryCount + 1
                )
            } else {
                throw APIError.unauthorized
            }
        }
        
        return try handleResponse(data: data, response: httpResponse)
    }
    
    func requestVoid(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil,
        authenticated: Bool = true,
        retryCount: Int = 0
    ) async throws {
        var bodyData: Data? = nil
        if let body = body {
            bodyData = try encoder.encode(body)
        }
        
        let request = buildRequest(
            endpoint: endpoint,
            method: method,
            body: bodyData,
            authenticated: authenticated
        )
        
        // Log the request
        logRequest(
            method: method,
            url: request.url!,
            headers: request.allHTTPHeaderFields ?? [:],
            body: bodyData
        )
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            logError(error, url: request.url!)
            throw APIError.networkError(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }
        
        // Log the response
        logResponse(statusCode: httpResponse.statusCode, data: data, url: request.url!)
        
        // Handle token refresh on 401 (prevent infinite loop with retryCount)
        if httpResponse.statusCode == 401 && authenticated && retryCount == 0 {
            if try await refreshAccessToken() {
                // Retry the request with new token (only once)
                return try await self.requestVoid(
                    endpoint: endpoint,
                    method: method,
                    body: body,
                    authenticated: authenticated,
                    retryCount: retryCount + 1
                )
            } else {
                throw APIError.unauthorized
            }
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            throw try parseError(data: data, statusCode: httpResponse.statusCode)
        }
    }
    
    // MARK: - Response Handling
    
    private func handleResponse<T: Codable>(data: Data, response: HTTPURLResponse) throws -> T {
        switch response.statusCode {
        case 200...299:
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        default:
            throw try parseError(data: data, statusCode: response.statusCode)
        }
    }
    
    private func parseError(data: Data, statusCode: Int) throws -> APIError {
        switch statusCode {
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 400, 422:
            if let problemDetails = try? decoder.decode(ProblemDetails.self, from: data) {
                if let errors = problemDetails.errors {
                    return .validationError(errors: errors)
                }
                return .serverError(message: problemDetails.detail ?? "Validation error")
            }
            return .unknown
        case 500...599:
            if let problemDetails = try? decoder.decode(ProblemDetails.self, from: data) {
                return .serverError(message: problemDetails.detail ?? "Server error")
            }
            return .serverError(message: "Internal server error")
        default:
            return .unknown
        }
    }
    
    // MARK: - Token Refresh
    
    private func refreshAccessToken() async throws -> Bool {
        guard let refreshToken = refreshToken else {
            return false
        }
        
        let request = RefreshTokenRequest(refreshToken: refreshToken)
        
        do {
            let response: AuthResponse = try await self.request(
                endpoint: "/auth/refresh-token",
                method: "POST",
                body: request,
                authenticated: false
            )
            
            setTokens(access: response.accessToken, refresh: response.refreshToken)
            return true
        } catch {
            clearTokens()
            return false
        }
    }
}
