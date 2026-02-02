//
//  APIErrorParser.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/26/26.
//

import Foundation

struct APIErrorParser {
    private let decoder: JSONDecoder

    init(decoder: JSONDecoder) {
        self.decoder = decoder
    }

    func parseError(data: Data, statusCode: Int) -> APIError {
        switch statusCode {
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 400, 422:
            // Try new validation format first
            if let validationResponse = try? decoder.decode(ValidationErrorResponse.self, from: data),
               let fieldErrors = validationResponse.errors, !fieldErrors.isEmpty
            {
                let errors = Dictionary(grouping: fieldErrors, by: { $0.field })
                    .mapValues { $0.map { $0.message } }
                return .validationError(errors: errors)
            }

            // Fall back to ProblemDetails format
            if let problemDetails = try? decoder.decode(ProblemDetails.self, from: data),
               problemDetails.detail != nil || problemDetails.errors != nil
            {
                if let errors = problemDetails.errors {
                    return .validationError(errors: errors)
                }
                return .serverError(message: problemDetails.detail ?? "Validation error")
            }

            // Fall back to simple error format: {"error": "message"}
            if let simpleError = try? decoder.decode(SimpleErrorResponse.self, from: data) {
                return .serverError(message: simpleError.error)
            }

            return .unknown
        case 500 ... 599:
            if let problemDetails = try? decoder.decode(ProblemDetails.self, from: data) {
                return .serverError(message: problemDetails.detail ?? "Server error")
            }
            return .serverError(message: "Internal server error")
        default:
            return .unknown
        }
    }
}
