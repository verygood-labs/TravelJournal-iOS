import Foundation

class APIService {
    static let shared = APIService()
    
    private let baseURL: String
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private init() {
        #if DEBUG
        self.baseURL = "http://localhost:5000/api"
        #else
        self.baseURL = "https://api.yourdomain.com/api"
        #endif
        
        self.session = URLSession.shared
        
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
        authenticated: Bool = true
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
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }
        
        // Handle token refresh on 401
        if httpResponse.statusCode == 401 && authenticated {
            if try await refreshAccessToken() {
                // Retry the request with new token
                return try await self.request(
                    endpoint: endpoint,
                    method: method,
                    body: body,
                    authenticated: authenticated
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
        authenticated: Bool = true
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
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
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