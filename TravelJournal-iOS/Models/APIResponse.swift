import Foundation

struct PaginatedResponse<T: Codable>: Codable {
    let items: [T]
    let page: Int
    let pageSize: Int
    let totalCount: Int
    let totalPages: Int
    let hasNextPage: Bool
    let hasPreviousPage: Bool
}

struct ProblemDetails: Codable {
    let type: String?
    let title: String?
    let status: Int?
    let detail: String?
    let instance: String?
    let traceId: String?
    let errors: [String: [String]]?
}

struct ValidationErrorResponse: Codable {
    let message: String?
    let errors: [FieldError]?
    
    struct FieldError: Codable {
        let field: String
        let message: String
    }
}

struct SimpleErrorResponse: Codable {
    let error: String
}

enum APIError: Error, LocalizedError {
    case unauthorized
    case forbidden
    case notFound
    case validationError(errors: [String: [String]])
    case serverError(message: String)
    case networkError(Error)
    case decodingError(Error)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Please log in to continue"
        case .forbidden:
            return "You don't have permission to access this"
        case .notFound:
            return "The requested resource was not found"
        case .validationError(let errors):
            return errors.values.flatMap { $0 }.joined(separator: "\n")
        case .serverError(let message):
            return message
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError:
            return "Failed to process server response"
        case .unknown:
            return "An unexpected error occurred"
        }
    }
}
