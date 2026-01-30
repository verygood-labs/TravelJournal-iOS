//
//  ToastPosition.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/29/26.
//


//
//  ToastModifier.swift
//  TravelJournal-iOS
//

import SwiftUI

// MARK: - Toast Position

/// Position for toast display.
enum ToastPosition {
    case top
    case bottom
    
    var alignment: Alignment {
        switch self {
        case .top: return .top
        case .bottom: return .bottom
        }
    }
    
    var edge: Edge.Set {
        switch self {
        case .top: return .top
        case .bottom: return .bottom
        }
    }
    
    var transitionEdge: Edge {
        switch self {
        case .top: return .top
        case .bottom: return .bottom
        }
    }
}

// MARK: - Toast Modifier

/// View modifier to overlay toast notifications on any view.
struct ToastModifier: ViewModifier {
    @ObservedObject var manager: ToastManager
    let position: ToastPosition
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: position.alignment) {
                if let toast = manager.currentToast {
                    ToastView(toast: toast) {
                        manager.dismiss()
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(position.edge, safeAreaPadding)
                    .transition(
                        .move(edge: position.transitionEdge)
                        .combined(with: .opacity)
                    )
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: manager.currentToast?.id)
    }
    
    // MARK: - Private
    
    private var safeAreaPadding: CGFloat {
        switch position {
        case .top: return AppTheme.Spacing.xl
        case .bottom: return AppTheme.Spacing.xxl
        }
    }
}