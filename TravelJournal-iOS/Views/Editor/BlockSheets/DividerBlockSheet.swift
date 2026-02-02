//
//  DividerBlockSheet.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/26/26.
//

//
//  DividerBlockSheet.swift
//  TravelJournal-iOS
//

import SwiftUI

struct DividerBlockSheet: View {
    let existingBlock: EditorBlock?
    let onSave: (EditorBlock) -> Void
    let onDelete: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    init(
        existingBlock: EditorBlock? = nil,
        onSave: @escaping (EditorBlock) -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        self.existingBlock = existingBlock
        self.onSave = onSave
        self.onDelete = onDelete
    }

    private var sheetTitle: String {
        existingBlock != nil ? "Edit Divider" : "Add Divider"
    }

    var body: some View {
        VStack(spacing: 0) {
            BlockSheetNavigationBar(
                title: sheetTitle,
                isValid: true,
                onCancel: { dismiss() },
                onDone: { saveAndDismiss() }
            )

            Spacer()

            // Preview of divider
            VStack(spacing: AppTheme.Spacing.md) {
                Text("Divider Preview")
                    .font(AppTheme.Typography.monoCaption())
                    .foregroundColor(AppTheme.Colors.passportTextMuted)

                dividerPreview
            }
            .padding(AppTheme.Spacing.xl)

            Spacer()

            if existingBlock != nil, let onDelete = onDelete {
                BlockDeleteButton(onDelete: onDelete)
                    .padding(.bottom, AppTheme.Spacing.lg)
            }
        }
        .background(AppTheme.Colors.passportPageDark)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Divider Preview

    private var dividerPreview: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Rectangle()
                .fill(AppTheme.Colors.passportInputBorder)
                .frame(height: 1)

            Image(systemName: "airplane")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.Colors.passportTextMuted)

            Rectangle()
                .fill(AppTheme.Colors.passportInputBorder)
                .frame(height: 1)
        }
        .padding(.horizontal, AppTheme.Spacing.xl)
    }

    private func saveAndDismiss() {
        let block = EditorBlock.newDivider(
            order: existingBlock?.order ?? 0
        )

        // Preserve the ID if editing
        let finalBlock = EditorBlock(
            id: existingBlock?.id ?? block.id,
            order: block.order,
            type: block.type,
            location: block.location,
            data: block.data
        )

        onSave(finalBlock)
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    DividerBlockSheet(onSave: { _ in })
}
