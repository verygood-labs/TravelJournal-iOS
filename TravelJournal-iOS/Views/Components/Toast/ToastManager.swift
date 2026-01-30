//
//  ToastManager.swift
//  TravelJournal-iOS
//

import SwiftUI
import Combine

// MARK: - Toast Manager

/// Observable manager for toast notifications.
/// Inject as an environment object to trigger toasts from any view.
@MainActor
final class ToastManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var currentToast: Toast?
    
    // MARK: - Private Properties
    
    private var dismissTask: Task<Void, Never>?
    
    // MARK: - Public Methods
    
    /// Show a toast notification.
    /// - Parameter toast: The toast to display.
    func show(_ toast: Toast) {
        // Cancel any pending dismiss
        dismissTask?.cancel()
        
        // Show new toast with animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            currentToast = toast
        }
        
        // Schedule auto-dismiss
        dismissTask = Task {
            try? await Task.sleep(for: .seconds(toast.duration))
            if !Task.isCancelled {
                dismiss()
            }
        }
    }
    
    /// Dismiss the current toast.
    func dismiss() {
        dismissTask?.cancel()
        withAnimation(.easeOut(duration: 0.2)) {
            currentToast = nil
        }
    }
    
    // MARK: - Convenience Methods
    
    /// Show a success toast.
    func success(_ message: String, icon: String? = nil) {
        show(.success(message, icon: icon))
    }
    
    /// Show an error toast.
    func error(_ message: String, icon: String? = nil) {
        show(.error(message, icon: icon))
    }
    
    /// Show a warning toast.
    func warning(_ message: String, icon: String? = nil) {
        show(.warning(message, icon: icon))
    }
    
    /// Show an info toast.
    func info(_ message: String, icon: String? = nil) {
        show(.info(message, icon: icon))
    }
}
