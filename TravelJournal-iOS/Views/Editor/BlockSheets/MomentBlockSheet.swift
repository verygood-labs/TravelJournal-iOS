//
//  MomentBlockSheet.swift
//  TravelJournal-iOS
//

import SwiftUI

struct MomentBlockSheet: View {
    let existingBlock: EditorBlock?
    let onSave: (EditorBlock) -> Void
    let onDelete: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var content: String = ""
    @State private var date: String = ""

    init(
        existingBlock: EditorBlock? = nil,
        onSave: @escaping (EditorBlock) -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        self.existingBlock = existingBlock
        self.onSave = onSave
        self.onDelete = onDelete

        if let block = existingBlock {
            _title = State(initialValue: block.data.title ?? "")
            _content = State(initialValue: block.data.content ?? "")
            _date = State(initialValue: block.data.date ?? "")
        }
    }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var sheetTitle: String {
        existingBlock != nil ? "Edit Moment" : "Add Moment"
    }

    var body: some View {
        VStack(spacing: 0) {
            BlockSheetNavigationBar(
                title: sheetTitle,
                isValid: isValid,
                onCancel: { dismiss() },
                onDone: { saveAndDismiss() }
            )

            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    BlockFormSection(label: "MOMENT TITLE") {
                        TextField("e.g., Sunrise at the beach", text: $title)
                            .textFieldStyle(BlockTextFieldStyle())
                    }

                    BlockFormSection(label: "DESCRIPTION") {
                        BlockTextEditor(
                            text: $content,
                            placeholder: "Describe this moment...",
                            minHeight: 100
                        )
                    }
                }
                .padding(AppTheme.Spacing.md)
            }

            Spacer()

            if existingBlock != nil, let onDelete = onDelete {
                BlockDeleteButton(onDelete: onDelete)
                    .padding(.bottom, AppTheme.Spacing.lg)
            }
        }
        .background(AppTheme.Colors.passportPageDark)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func saveAndDismiss() {
        let block = EditorBlock.newMoment(
            order: existingBlock?.order ?? 0,
            date: date.isEmpty ? nil : date,
            title: title.isEmpty ? nil : title,
            content: content.isEmpty ? nil : content
        )

        // Preserve the ID if editing
        let finalBlock = EditorBlock(
            id: existingBlock?.id ?? block.id,
            order: block.order,
            type: block.type,
            location: existingBlock?.location,
            data: block.data
        )

        onSave(finalBlock)
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    MomentBlockSheet(onSave: { _ in })
}
