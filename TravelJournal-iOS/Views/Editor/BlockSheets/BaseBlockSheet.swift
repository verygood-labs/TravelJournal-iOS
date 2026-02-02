//
//  BaseBlockSheet.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/22/26.
//

import Foundation
import SwiftUI

// MARK: - Block Sheet Navigation Bar

/// Reusable navigation bar for all block editor sheets
struct BlockSheetNavigationBar: View {
    let title: String
    let isValid: Bool
    let onCancel: () -> Void
    let onDone: () -> Void

    var body: some View {
        HStack {
            Button {
                onCancel()
            } label: {
                Text("Cancel")
                    .font(AppTheme.Typography.monoMedium())
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }

            Spacer()

            Text(title)
                .font(AppTheme.Typography.monoMedium())
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.Colors.textPrimary)

            Spacer()

            Button {
                onDone()
            } label: {
                Text("Done")
                    .font(AppTheme.Typography.monoMedium())
                    .fontWeight(.semibold)
                    .foregroundColor(isValid ? AppTheme.Colors.primary : AppTheme.Colors.primary.opacity(0.3))
            }
            .disabled(!isValid)
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.top, AppTheme.Spacing.xl)
        .padding(.bottom, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.backgroundDark)
    }
}

// MARK: - Block Form Section

/// Reusable form section with label
struct BlockFormSection<Content: View>: View {
    let label: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
            Text(label)
                .font(AppTheme.Typography.inputLabel())
                .tracking(1)
                .foregroundColor(AppTheme.Colors.passportTextMuted)

            content
        }
    }
}

// MARK: - Block Text Editor

/// Styled text editor for block forms
struct BlockTextEditor: View {
    @Binding var text: String
    let placeholder: String
    var minHeight: CGFloat = 120

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .font(AppTheme.Typography.monoMedium())
                .foregroundColor(AppTheme.Colors.passportTextPrimary)
                .scrollContentBackground(.hidden)
                .frame(minHeight: minHeight)
                .padding(AppTheme.Spacing.xs)
                .background(AppTheme.Colors.passportInputBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .stroke(AppTheme.Colors.passportInputBorder, lineWidth: 1)
                )
                .cornerRadius(AppTheme.CornerRadius.medium)

            if text.isEmpty {
                Text(placeholder)
                    .font(AppTheme.Typography.monoMedium())
                    .foregroundColor(AppTheme.Colors.passportTextPlaceholder)
                    .padding(AppTheme.Spacing.sm)
                    .allowsHitTesting(false)
            }
        }
    }
}

// MARK: - Block TextField Style

struct BlockTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(AppTheme.Typography.monoMedium())
            .foregroundColor(AppTheme.Colors.passportTextPrimary)
            .padding(AppTheme.Spacing.sm)
            .background(AppTheme.Colors.passportInputBackground)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(AppTheme.Colors.passportInputBorder, lineWidth: 1)
            )
            .cornerRadius(AppTheme.CornerRadius.medium)
    }
}

// MARK: - Block Delete Button

struct BlockDeleteButton: View {
    let onDelete: () -> Void

    var body: some View {
        Button {
            onDelete()
        } label: {
            Text("Delete Block")
                .font(AppTheme.Typography.monoMedium())
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.sm)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: AppTheme.Spacing.lg) {
        BlockSheetNavigationBar(
            title: "Add Tip",
            isValid: true,
            onCancel: {},
            onDone: {}
        )

        VStack(spacing: AppTheme.Spacing.md) {
            BlockFormSection(label: "TITLE") {
                TextField("Enter title", text: .constant(""))
                    .textFieldStyle(BlockTextFieldStyle())
            }

            BlockFormSection(label: "CONTENT") {
                BlockTextEditor(text: .constant(""), placeholder: "Write something...")
            }
        }
        .padding()

        Spacer()

        BlockDeleteButton(onDelete: {})
    }
    .background(AppTheme.Colors.passportPageDark)
}
