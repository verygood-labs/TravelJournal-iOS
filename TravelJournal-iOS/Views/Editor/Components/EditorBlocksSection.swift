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
        JournalBlock(
            id: UUID(),
            type: .moment,
            content: "Arrived at the airport, ready for adventure!",
            imageUrl: nil,
            order: 0,
            createdAt: Date()
        ),
        JournalBlock(
            id: UUID(),
            type: .tip,
            content: "Getting Around\n\nUse Grab for easy transportation.",
            imageUrl: nil,
            order: 1,
            createdAt: Date()
        )
    ]
    
    return ZStack {
        AppTheme.Colors.passportPageDark
            .ignoresSafeArea()
        
        EditorBlocksSection(viewModel: viewModel)
            .padding()
    }
}
