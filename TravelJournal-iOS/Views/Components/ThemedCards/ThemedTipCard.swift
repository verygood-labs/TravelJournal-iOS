//
//  ThemedTipCard.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 2/5/26.
//

import SwiftUI

// MARK: - Themed Tip Card

/// A themed card for displaying tip blocks in preview mode.
struct ThemedTipCard: View {
    let block: EditorBlock
    var actionConfig: CardActionConfig?
    @Environment(\.journalTheme) private var theme

    // MARK: - Computed Properties

    private var tipStyle: TipBlockStyle {
        theme.blocks.tip
    }

    private var data: EditorBlockData {
        block.data
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                // Icon
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 18))
                    .foregroundColor(tipStyle.iconSwiftUIColor)
                    .frame(width: 24)

                // Content
                VStack(alignment: .leading, spacing: 6) {
                    // Title
                    if let title = data.title, !title.isEmpty {
                        Text(title)
                            .font(theme.typography.headingFont(size: 15, weight: .semibold))
                            .foregroundColor(theme.colors.textPrimaryColor)
                    }

                    // Content
                    if let content = data.content, !content.isEmpty {
                        Text(content)
                            .font(theme.typography.bodyFont(size: 14))
                            .foregroundColor(theme.colors.textSecondaryColor)
                            .lineSpacing(3)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(14)

            // Action bar
            if let config = actionConfig {
                ThemedCardActionBar(config: config)
            }
        }
        .background(tipStyle.backgroundColor)
        .cornerRadius(theme.style.borderRadius)
        .overlay(
            RoundedRectangle(cornerRadius: theme.style.borderRadius)
                .stroke(tipStyle.borderSwiftUIColor, lineWidth: theme.style.borderRadius == 0 ? 2 : 2)
        )
    }
}

// MARK: - Preview

#Preview("Default Theme") {
    ScrollView {
        VStack(spacing: 16) {
            ThemedTipCard(block: .sampleTip)
            ThemedTipCard(block: .sampleTipNoTitle)
        }
        .padding()
    }
    .background(Color(hex: "#f5f5f5"))
    .journalTheme(.default)
}

#Preview("Passport Theme") {
    ScrollView {
        VStack(spacing: 16) {
            ThemedTipCard(block: .sampleTip)
            ThemedTipCard(block: .sampleTipNoTitle)
        }
        .padding()
    }
    .background(Color(hex: "#f5f1e8"))
    .journalTheme(.passport)
}

#Preview("Retro Theme") {
    ScrollView {
        VStack(spacing: 16) {
            ThemedTipCard(block: .sampleTip)
            ThemedTipCard(block: .sampleTipNoTitle)
        }
        .padding()
    }
    .background(Color(hex: "#C0C0C0"))
    .journalTheme(.retro)
}

// MARK: - Sample Data

private extension EditorBlock {
    static let sampleTip = EditorBlock.newTip(
        order: 0,
        title: "Getting Around",
        content: "Use Grab for affordable transportation. Much cheaper and safer than regular taxis, especially from the airport."
    )

    static let sampleTipNoTitle = EditorBlock.newTip(
        order: 1,
        content: "Don't forget to bring sunscreen and stay hydrated - the tropical heat is no joke!"
    )
}
