//
//  EditorNavigationBar.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/22/26.
//


import SwiftUI

struct EditorNavigationBar: View {
    @ObservedObject var viewModel: JournalEditorViewModel
    let onCancel: () -> Void
    let onDone: () -> Void
    
    var body: some View {
        HStack {
            // Cancel button
            Button {
                onCancel()
            } label: {
                Text("Cancel")
                    .font(AppTheme.Typography.monoMedium())
                    .foregroundColor(AppTheme.Colors.primary)
            }
            
            Spacer()
            
            // Edit/Preview toggle
            EditorModeToggle(selectedMode: $viewModel.editorMode)
            
            Spacer()
            
            // Done button
            Button {
                onDone()
            } label: {
                if viewModel.isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.primary))
                        .scaleEffect(0.8)
                } else {
                    Text("Done")
                        .font(AppTheme.Typography.monoMedium())
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }
            .disabled(viewModel.isSaving)
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.backgroundDark)
    }
}

// MARK: - Preview
#Preview {
    let trip = Trip(
        id: UUID(),
        title: "Test Trip",
        description: nil,
        coverImageUrl: nil,
        status: .draft,
        startDate: Date(),
        endDate: Date(),
        createdAt: Date(),
        updatedAt: Date(),
        stops: nil
    )
    
    return EditorNavigationBar(
        viewModel: JournalEditorViewModel(trip: trip),
        onCancel: {},
        onDone: {}
    )
}