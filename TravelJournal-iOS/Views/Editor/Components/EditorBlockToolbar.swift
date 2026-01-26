//
//  EditorBlockToolbar.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/22/26.
//


import SwiftUI

struct EditorBlockToolbar: View {
    @ObservedObject var viewModel: JournalEditorViewModel
    
    // Toolbar items based on existing BlockType enum
    private let toolbarItems: [(type: BlockType, icon: String, label: String)] = [
        (.text, "doc.text", "Text"),
        (.moment, "sparkles", "Moment"),
        (.image, "camera.fill", "Photo"),
        (.recommendation, "star.fill", "Rec"),
        (.tip, "lightbulb.fill", "Tip")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Gold accent line
            Rectangle()
                .fill(AppTheme.Colors.primary)
                .frame(height: 2)
            
            HStack(spacing: 0) {
                ForEach(toolbarItems, id: \.type) { item in
                    Button {
                        viewModel.addBlock(type: item.type)
                    } label: {
                        VStack(spacing: AppTheme.Spacing.xxxs) {
                            Image(systemName: item.icon)
                                .font(.system(size: 20))
                                .foregroundColor(AppTheme.Colors.primary)
                            
                            Text(item.label.uppercased())
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

// MARK: - Preview
#Preview {
    let trip = Trip(
        id: UUID(),
        title: "Test Trip",
        description: nil,
        coverImageUrl: nil,
        status: .draft,
        tripMode: .live,
        startDate: Date(),
        endDate: Date(),
        createdAt: Date(),
        updatedAt: Date(),
        stops: nil
    )
    
    return VStack {
        Spacer()
        EditorBlockToolbar(viewModel: JournalEditorViewModel(trip: trip))
    }
}
