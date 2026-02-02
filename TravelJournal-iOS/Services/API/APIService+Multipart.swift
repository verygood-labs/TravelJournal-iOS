//
//  APIService+Multipart.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/26/26.
//

import Foundation

extension APIService {
    // MARK: - Multipart Form Data Upload

    func uploadMultipart<T: Codable>(
        endpoint: String,
        fields: [String: String],
        imageData: Data?,
        imageFieldName: String = "profilePicture",
        imageFileName: String = "photo.jpg",
        imageMimeType: String = "image/jpeg",
        authenticated: Bool = false
    ) async throws -> T {
        let boundary = "Boundary-\(UUID().uuidString)"
        let url = URL(string: "\(baseURL)\(endpoint)")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        if authenticated, let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        var body = Data()

        // Add text fields
        for (key, value) in fields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        // Add image if present
        if let imageData = imageData {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(imageFieldName)\"; filename=\"\(imageFileName)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(imageMimeType)\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        // Log the request (without binary image data)
        if enableLogging {
            print("\n🌐 ===== API MULTIPART REQUEST =====")
            print("📍 POST \(url.absoluteString)")
            print("📋 Fields: \(fields.keys.joined(separator: ", "))")
            if let imageData = imageData {
                print("📷 Image: \(imageFieldName) (\(imageData.count) bytes)")
            }
            print("====================================\n")
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            logError(error, url: url)
            throw APIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }

        logResponse(statusCode: httpResponse.statusCode, data: data, url: url)

        return try handleResponse(data: data, response: httpResponse)
    }
}
