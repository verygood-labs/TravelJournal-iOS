//
//  EditorBlockCard.swift
//  TravelJournal-iOS
//

import SwiftUI

struct EditorBlockCard: View {
    let block: EditorBlock
    let onTap: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
            blockNumberBadge
            
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxxs) {
                Text(block.type.rawValue.uppercased())
                    .font(AppTheme.Typography.monoCaption())
                    .tracking(1)
                    .foregroundColor(AppTheme.Colors.passportTextMuted)
                
                if let preview = blockPreviewText, !preview.isEmpty {
                    Text(preview)
                        .font(AppTheme.Typography.monoMedium())
                        .foregroundColor(AppTheme.Colors.passportTextPrimary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                } else {
                    Text("Tap to edit...")
                        .font(AppTheme.Typography.monoSmall())
                        .foregroundColor(AppTheme.Colors.passportTextPlaceholder)
                        .italic()
                }
            }
            
            Spacer()
            
            blockTypeIcon
        }
        .padding(AppTheme.Spacing.md)
        .background(
            LinearGradient(
                colors: [
                    AppTheme.Colors.passportPageLight,
                    AppTheme.Colors.passportPageDark
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .stroke(AppTheme.Colors.passportInputBorder, lineWidth: 1)
        )
        .cornerRadius(AppTheme.CornerRadius.medium)
        .onTapGesture {
            onTap()
        }
    }
    
    // MARK: - Block Preview Text

    private var blockPreviewText: String? {
        switch block.type {
        case .moment:
            return block.data.title ?? block.data.content
        case .recommendation:
            return block.data.name
        case .photo:
            return block.data.caption
        case .tip:
            return block.data.title ?? block.data.content
        case .divider:
            return "───"
        }
    }
    
    // MARK: - Block Number Badge

    private var blockNumberBadge: some View {
        Text("\(block.order + 1)")
            .font(AppTheme.Typography.monoSmall())
            .fontWeight(.semibold)
            .foregroundColor(AppTheme.Colors.backgroundDark)
            .frame(width: 28, height: 28)
            .background(AppTheme.Colors.primary)
            .clipShape(Circle())
    }

    // MARK: - Block Type Icon

    private var blockTypeIcon: some View {
        Image(systemName: block.type.icon)
            .font(.system(size: 16))
            .foregroundColor(AppTheme.Colors.primary)
            .frame(width: 32, height: 32)
            .background(AppTheme.Colors.primary.opacity(0.1))
            .cornerRadius(AppTheme.CornerRadius.small)
    }

}

// MARK: - Preview

#Preview {
    PassportPageBackgroundView {
        VStack(spacing: AppTheme.Spacing.md) {
            EditorBlockCard(
                block: EditorBlock.newMoment(
                    order: 0,
                    title: "Arrival Day",
                    content: "Landed at NAIA around 6am, groggy but excited."
                ),
                onTap: {}
            )
            
            EditorBlockCard(
                block: EditorBlock.newTip(
                    order: 1,
                    title: "Booking Tips",
                    content: "Book your island hopping tours at least 2 days in advance."
                ),
                onTap: {}
            )
            
            EditorBlockCard(
                block: EditorBlock.newRecommendation(
                    order: 2,
                    name: "Aristocrat Restaurant",
                    category: .eat
                ),
                onTap: {}
            )
        }
        .padding()
    }
}
