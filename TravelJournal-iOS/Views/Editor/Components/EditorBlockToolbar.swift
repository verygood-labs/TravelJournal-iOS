//
//  EditorBlockToolbar.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/22/26.
//

import SwiftUI

struct EditorBlockToolbar: View {
    @ObservedObject var viewModel: JournalEditorViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Gold accent line
            Rectangle()
                .fill(AppTheme.Colors.primary)
                .frame(height: 2)

            HStack(spacing: 0) {
                ForEach(BlockType.toolbarItems, id: \.self) { type in
                    Button {
                        viewModel.addBlock(type: type)
                    } label: {
                        VStack(spacing: AppTheme.Spacing.xxxs) {
                            Image(systemName: type.icon)
                                .font(.system(size: 20))
                                .foregroundColor(AppTheme.Colors.primary)

                            Text(type.label.uppercased())
                                .font(AppTheme.Typography.monoCaption())
                                .tracking(0.5)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppTheme.Spacing.sm)
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(AppTheme.Colors.backgroundDark)
        }
    }
}
