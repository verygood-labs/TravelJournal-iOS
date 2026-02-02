//
//  MediaService.swift
//  TravelJournal-iOS
//

import Foundation
import UIKit

// MARK: - Media Type

enum MediaType: String, Codable {
    case avatar = "Avatar"
    case tripCover = "TripCover"
    case block = "Block"
}

// MARK: - Media Upload Result

struct MediaUploadResult: Codable {
    let id: UUID
    let url: String
    let fileSizeBytes: Int64
}

// MARK: - Media Service

final class MediaService {
    static let shared = MediaService()
    private let api = APIService.shared

    private init() {}

    /// Upload an image to the media service
    /// - Parameters:
    ///   - image: The UIImage to upload
    ///   - type: Media type (avatar, tripCover, block)
    ///   - tripId: Required for tripCover and block types
    /// - Returns: MediaUploadResult with the URL
    func upload(
        image: UIImage,
        type: MediaType,
        tripId: UUID? = nil
    ) async throws -> MediaUploadResult {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw APIError.unknown
        }

        var fields: [String: String] = [
            "type": type.rawValue,
        ]

        if let tripId = tripId {
            fields["tripId"] = tripId.uuidString
        }

        return try await api.uploadMultipart(
            endpoint: "/media/upload",
            fields: fields,
            imageData: imageData,
            imageFieldName: "file",
            imageFileName: "photo.jpg",
            imageMimeType: "image/jpeg",
            authenticated: true
        )
    }
}
