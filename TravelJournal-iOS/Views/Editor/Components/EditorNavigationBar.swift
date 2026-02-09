//
//  EditorNavigationBar.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/22/26.
//

import SwiftUI

struct EditorNavigationBar: View {
    @ObservedObject var viewModel: JournalEditorViewModel
    let onClose: () -> Void
    let onSave: () -> Void
    let onDone: () -> Void
    
    private var rightButtonText: String {
        switch viewModel.editorMode {
        case .edit: return "Save"
        case .preview: return "Done"
        }
    }
    
    private var rightButtonAction: () -> Void {
        switch viewModel.editorMode {
        case .edit: return onSave
        case .preview: return onDone
        }
    }

    var body: some View {
        HStack {
            // Close button (X icon)
            Button {
                onClose()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppTheme.Colors.primary)
            }

            Spacer()

            // Edit/Preview toggle
            EditorModeToggle(selectedMode: $viewModel.editorMode)

            Spacer()

            // Right button (Save/Done)
            Button {
                rightButtonAction()
            } label: {
                if viewModel.isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.primary))
                        .scaleEffect(0.8)
                } else {
                    Text(rightButtonText)
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
    EditorNavigationBar(
        viewModel: JournalEditorViewModel(trip: .previewDraft, toastManager: ToastManager()),
        onClose: {},
        onSave: {},
        onDone: {}
    )
}
