//
//  TripContextMenu.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/21/26.
//

import Foundation
import SwiftUI

struct TripContextMenu: ViewModifier {
    let onView: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    func body(content: Content) -> some View {
        content
            .contextMenu {
                Button {
                    onView()
                } label: {
                    Label("View", systemImage: "eye")
                }

                Button {
                    onEdit()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }

                Divider()

                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
    }
}

extension View {
    func tripContextMenu(
        onView: @escaping () -> Void,
        onEdit: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) -> some View {
        modifier(TripContextMenu(onView: onView, onEdit: onEdit, onDelete: onDelete))
    }
}
