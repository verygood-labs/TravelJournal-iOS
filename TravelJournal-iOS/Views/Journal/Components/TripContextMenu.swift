//
//  TripContextMenu.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/21/26.
//

import Foundation
import SwiftUI

struct TripContextMenu: ViewModifier {
    let trip: TripSummary
    let onView: () -> Void
    let onEdit: () -> Void
    let onChangeVisibility: () -> Void
    let onDelete: () -> Void

    private var isDraft: Bool {
        trip.status == .draft
    }

    func body(content: Content) -> some View {
        content
            .contextMenu {
                if isDraft {
                    // Draft context menu: Edit, Delete
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
                } else {
                    // Published context menu: View, Edit, Change Visibility, Delete
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

                    Button {
                        onChangeVisibility()
                    } label: {
                        Label("Change Visibility", systemImage: "eye.slash")
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
}

extension View {
    func tripContextMenu(
        trip: TripSummary,
        onView: @escaping () -> Void,
        onEdit: @escaping () -> Void,
        onChangeVisibility: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) -> some View {
        modifier(TripContextMenu(
            trip: trip,
            onView: onView,
            onEdit: onEdit,
            onChangeVisibility: onChangeVisibility,
            onDelete: onDelete
        ))
    }
}
