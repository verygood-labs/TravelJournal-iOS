//
//  APIServce+Logging.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/26/26.
//

import Foundation

extension APIService {
    // MARK: - Logging
    
    func logRequest(method: String, url: URL, headers: [String: String], body: Data?) {
        guard enableLogging else { return }
        
        print("\n🌐 ===== API REQUEST =====")
        print("📍 \(method) \(url.absoluteString)")
        print("📋 Headers:")
        headers.forEach { key, value in
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
    
    func logResponse(statusCode: Int, data: Data, url: URL) {
        guard enableLogging else { return }
        
        print("\n✅ ===== API RESPONSE =====")
        print("📍 URL: \(url.absoluteString)")
        print("📊 Status: \(statusCode)")
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📦 Response Data:")
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
    
    func logError(_ error: Error, url: URL) {
        guard enableLogging else { return }
        
        print("\n❌ ===== API ERROR =====")
        print("📍 URL: \(url.absoluteString)")
        print("⚠️ Error: \(error.localizedDescription)")
        print("========================\n")
    }
}
