//
//  View+Toast.swift
//  TravelJournal-iOS
//

import SwiftUI

// MARK: - View Extension

extension View {
    /// Apply a toast overlay to this view.
    /// - Parameters:
    ///   - manager: The ToastManager instance to observe.
    ///   - position: Where to display the toast (default: .top).
    /// - Returns: A view with the toast overlay applied.
    func toastOverlay(
        manager: ToastManager,
        position: ToastPosition = .top
    ) -> some View {
        modifier(ToastModifier(manager: manager, position: position))
    }
}
