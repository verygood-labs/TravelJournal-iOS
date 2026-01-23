import SwiftUI

struct JournalBlockCard: View {
    let block: JournalBlock
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                // Block number indicator
                blockNumberBadge
                
                // Block content
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xxxs) {
                    // Block type label
                    Text(block.type.rawValue.uppercased())
                        .font(AppTheme.Typography.monoCaption())
                        .tracking(1)
                        .foregroundColor(AppTheme.Colors.passportTextMuted)
                    
                    // Block title/content preview
                    if let content = block.content, !content.isEmpty {
                        Text(content)
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
                
                // Block type icon
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
        }
        .buttonStyle(.plain)
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
        Image(systemName: iconForBlockType(block.type))
            .font(.system(size: 16))
            .foregroundColor(AppTheme.Colors.primary)
            .frame(width: 32, height: 32)
            .background(AppTheme.Colors.primary.opacity(0.1))
            .cornerRadius(AppTheme.CornerRadius.small)
    }
    
    private func iconForBlockType(_ type: BlockType) -> String {
        switch type {
        case .text:
            return "doc.text"
        case .moment:
            return "sparkles"
        case .image:
            return "camera.fill"
        case .recommendation:
            return "star.fill"
        case .tip:
            return "lightbulb.fill"
        }
    }
}

// MARK: - Preview
#Preview {
    PassportPageBackgroundView {
        VStack(spacing: AppTheme.Spacing.md) {
            JournalBlockCard(
                block: JournalBlock(
                    id: UUID(),
                    type: .moment,
                    content: "Landed at NAIA around 6am, groggy but excited. The humidity hit immediately...",
                    imageUrl: nil,
                    order: 0,
                    createdAt: Date()
                ),
                onTap: {}
            )
            
            JournalBlockCard(
                block: JournalBlock(
                    id: UUID(),
                    type: .tip,
                    content: "Book your island hopping tours at least 2 days in advance during peak season.",
                    imageUrl: nil,
                    order: 1,
                    createdAt: Date()
                ),
                onTap: {}
            )
            
            JournalBlockCard(
                block: JournalBlock(
                    id: UUID(),
                    type: .image,
                    content: nil,
                    imageUrl: nil,
                    order: 2,
                    createdAt: Date()
                ),
                onTap: {}
            )
        }
        .padding()
    }
}
