//
//  RecommendationBlockSheet.swift
//  TravelJournal-iOS
//

import SwiftUI

struct RecommendationBlockSheet: View {
    let existingBlock: EditorBlock?
    let onSave: (EditorBlock) -> Void
    let onDelete: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var category: RecommendationCategory = .eat
    @State private var rating: Rating? = nil
    @State private var priceLevel: Int? = nil
    @State private var note: String = ""

    init(
        existingBlock: EditorBlock? = nil,
        onSave: @escaping (EditorBlock) -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        self.existingBlock = existingBlock
        self.onSave = onSave
        self.onDelete = onDelete

        if let block = existingBlock {
            _name = State(initialValue: block.data.name ?? "")
            _category = State(initialValue: block.data.category ?? .eat)
            _rating = State(initialValue: block.data.rating)
            _priceLevel = State(initialValue: block.data.priceLevel)
            _note = State(initialValue: block.data.note ?? "")
        }
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var sheetTitle: String {
        existingBlock != nil ? "Edit Recommendation" : "Add Recommendation"
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
                    BlockFormSection(label: "PLACE NAME") {
                        TextField("e.g., Cafe de Flore", text: $name)
                            .textFieldStyle(BlockTextFieldStyle())
                    }

                    BlockFormSection(label: "CATEGORY") {
                        CategoryPicker(selection: $category)
                    }

                    BlockFormSection(label: "RATING (OPTIONAL)") {
                        RatingPicker(selection: $rating)
                    }

                    BlockFormSection(label: "WHY YOU RECOMMEND IT") {
                        BlockTextEditor(
                            text: $note,
                            placeholder: "Share why others should visit...",
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
        let block = EditorBlock.newRecommendation(
            order: existingBlock?.order ?? 0,
            name: name,
            category: category,
            rating: rating,
            priceLevel: priceLevel,
            note: note.isEmpty ? nil : note
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

// MARK: - Category Picker

private struct CategoryPicker: View {
    @Binding var selection: RecommendationCategory

    var body: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            ForEach(RecommendationCategory.allCases, id: \.self) { category in
                CategoryButton(
                    category: category,
                    isSelected: selection == category
                ) {
                    selection = category
                }
            }
        }
    }
}

private struct CategoryButton: View {
    let category: RecommendationCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.system(size: 16))
                Text(category.displayName)
                    .font(AppTheme.Typography.monoCaption())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(isSelected ? AppTheme.Colors.primary.opacity(0.2) : AppTheme.Colors.passportInputBackground)
            .foregroundColor(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.passportTextSecondary)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.passportInputBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Rating Picker

private struct RatingPicker: View {
    @Binding var selection: Rating?

    var body: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            ForEach(Rating.allCases, id: \.self) { rating in
                RatingButton(
                    rating: rating,
                    isSelected: selection == rating
                ) {
                    if selection == rating {
                        selection = nil
                    } else {
                        selection = rating
                    }
                }
            }
        }
    }
}

private struct RatingButton: View {
    let rating: Rating
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(rating.displayName)
                .font(AppTheme.Typography.monoSmall())
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(isSelected ? rating.color.opacity(0.2) : AppTheme.Colors.passportInputBackground)
                .foregroundColor(isSelected ? rating.color : AppTheme.Colors.passportTextSecondary)
                .cornerRadius(AppTheme.CornerRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .stroke(isSelected ? rating.color : AppTheme.Colors.passportInputBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    RecommendationBlockSheet(onSave: { _ in })
}
