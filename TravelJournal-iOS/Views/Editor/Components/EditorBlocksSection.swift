//
//  EditorBlocksSection.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/22/26.
//


import SwiftUI

struct EditorBlocksSection: View {
    @ObservedObject var viewModel: JournalEditorViewModel
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            if viewModel.blocks.isEmpty {
                emptyBlocksPlaceholder
            } else {
                ForEach(viewModel.blocks) { block in
                    JournalBlockCard(block: block) {
                        viewModel.editBlock(block)
                    }
                }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyBlocksPlaceholder: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "square.stack.3d.up")
                .font(.system(size: 36))
                .foregroundColor(AppTheme.Colors.passportTextMuted.opacity(0.5))
            
            Text("Start adding content")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.passportTextMuted)
            
            Text("Use the toolbar below to add\nmoments, photos, and more")
                .font(AppTheme.Typography.monoCaption())
                .foregroundColor(AppTheme.Colors.passportTextMuted.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(AppTheme.Spacing.xxl)
    }
}

// MARK: - Preview
#Preview("Empty") {
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
    
    return ZStack {
        AppTheme.Colors.passportPageDark
            .ignoresSafeArea()
        
        EditorBlocksSection(viewModel: JournalEditorViewModel(trip: trip))
    }
}

#Preview("With Blocks") {
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
    
    let viewModel = JournalEditorViewModel(trip: trip)
    viewModel.blocks = [
        EditorBlock.newMoment(
            order: 0,
            title: "Arrival",
            content: "Arrived at the airport, ready for adventure!"
        ),
        EditorBlock.newTip(
            order: 1,
            title: "Getting Around",
            content: "Use Grab for easy transportation."
        )
    ]
    
    return ZStack {
        AppTheme.Colors.passportPageDark
            .ignoresSafeArea()
        
        EditorBlocksSection(viewModel: viewModel)
            .padding()
    }
}
