//
//  Toast.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/29/26.
//


//
//  Toast.swift
//  TravelJournal-iOS
//

import SwiftUI

// MARK: - Toast

/// Model representing a toast notification.
struct Toast: Equatable {
    let id: UUID
    let type: ToastType
    let message: String
    let icon: String?
    let duration: TimeInterval
    
    // MARK: - Toast Type
    
    enum ToastType {
        case success
        case error
        case warning
        case info
        
        var defaultIcon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .info: return "info.circle.fill"
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .success: return Color(hex: "4CAF50")
            case .error: return Color(hex: "F44336")
            case .warning: return Color(hex: "FF9800")
            case .info: return Color(hex: "607D8B")
            }
        }
        
        var iconColor: Color {
            .white
        }
    }
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        type: ToastType,
        message: String,
        icon: String? = nil,
        duration: TimeInterval = 3.0
    ) {
        self.id = id
        self.type = type
        self.message = message
        self.icon = icon ?? type.defaultIcon
        self.duration = duration
    }
    
    // MARK: - Convenience Initializers
    
    static func success(
        _ message: String,
        icon: String? = nil,
        duration: TimeInterval = 3.0
    ) -> Toast {
        Toast(
            type: .success,
            message: message,
            icon: icon ?? ToastType.success.defaultIcon,
            duration: duration
        )
    }
    
    static func error(
        _ message: String,
        icon: String? = nil,
        duration: TimeInterval = 3.0
    ) -> Toast {
        Toast(
            type: .error,
            message: message,
            icon: icon ?? ToastType.error.defaultIcon,
            duration: duration
        )
    }
    
    static func warning(
        _ message: String,
        icon: String? = nil,
        duration: TimeInterval = 3.0
    ) -> Toast {
        Toast(
            type: .warning,
            message: message,
            icon: icon ?? ToastType.warning.defaultIcon,
            duration: duration
        )
    }
    
    static func info(
        _ message: String,
        icon: String? = nil,
        duration: TimeInterval = 3.0
    ) -> Toast {
        Toast(
            type: .info,
            message: message,
            icon: icon ?? ToastType.info.defaultIcon,
            duration: duration
        )
    }
}