//
//  EditorBlocksSection.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/22/26.
//

import SwiftUI

struct EditorBlocksSection: View {
    @ObservedObject var viewModel: JournalEditorViewModel
    
    @State private var draggingBlockId: UUID?
    @State private var dragOffset: CGFloat = 0
    @State private var initialIndex: Int?
    
    // Fixed block height for calculations
    private let blockHeight: CGFloat = 88
    private let dividerHeight: CGFloat = 44
    private let blockSpacing: CGFloat = AppTheme.Spacing.md
    
    var body: some View {
        VStack(spacing: blockSpacing) {
            if viewModel.blocks.isEmpty {
                emptyBlocksPlaceholder
            } else {
                ForEach(Array(viewModel.blocks.enumerated()), id: \.element.id) { index, block in
                    let isDragging = draggingBlockId == block.id
                    
                    Group {
                        if block.type == .divider {
                            EditorDividerRow(block: block) {
                                if draggingBlockId == nil {
                                    viewModel.editBlock(block)
                                }
                            }
                        } else {
                            EditorBlockCard(block: block) {
                                if draggingBlockId == nil {
                                    viewModel.editBlock(block)
                                }
                            }
                        }
                    }
                    .zIndex(isDragging ? 1 : 0)
                    .scaleEffect(isDragging ? 1.03 : 1.0)
                    .shadow(color: isDragging ? .black.opacity(0.2) : .clear, radius: 8, y: 4)
                    .opacity(isDragging ? 0.95 : 1.0)
                    .offset(y: offsetFor(index: index, blockId: block.id))
                    .animation(.easeInOut(duration: 0.2), value: draggingBlockId)
                    .animation(.easeInOut(duration: 0.2), value: currentTargetIndex)
                    .gesture(
                        LongPressGesture(minimumDuration: 0.15)
                            .sequenced(before: DragGesture())
                            .onChanged { value in
                                switch value {
                                case .first(true):
                                    // Long press recognized, prepare for drag
                                    break
                                case .second(true, let drag?):
                                    if draggingBlockId == nil {
                                        startDrag(block: block, at: index)
                                    }
                                    dragOffset = drag.translation.height
                                default:
                                    break
                                }
                            }
                            .onEnded { _ in
                                endDrag()
                            }
                    )
                }
            }
        }
    }
    
    // MARK: - Drag Calculations
    
    private var currentTargetIndex: Int? {
        guard let initial = initialIndex, draggingBlockId != nil else { return nil }
        
        let totalBlockHeight = blockHeight + blockSpacing
        let indexOffset = Int(round(dragOffset / totalBlockHeight))
        let newIndex = initial + indexOffset
        
        return max(0, min(viewModel.blocks.count - 1, newIndex))
    }
    
    private func offsetFor(index: Int, blockId: UUID) -> CGFloat {
        // The dragging block follows the finger
        if draggingBlockId == blockId {
            return dragOffset
        }
        
        // Other blocks shift to make room
        guard let initial = initialIndex,
              let target = currentTargetIndex,
              initial != target else {
            return 0
        }
        
        // Get the height of the dragging block
        let draggingBlockHeight = heightForBlock(at: initial) + blockSpacing
        
        // Dragging down: blocks between initial and target shift up
        if initial < target {
            if index > initial && index <= target {
                return -draggingBlockHeight
            }
        }
        
        // Dragging up: blocks between target and initial shift down
        if initial > target {
            if index >= target && index < initial {
                return draggingBlockHeight
            }
        }
        
        return 0
    }

    private func heightForBlock(at index: Int) -> CGFloat {
        guard index >= 0 && index < viewModel.blocks.count else {
            return blockHeight
        }
        return viewModel.blocks[index].type == .divider ? dividerHeight : blockHeight
    }
    
    // MARK: - Drag Actions
    
    private func startDrag(block: EditorBlock, at index: Int) {
        print("🚀 Drag started: \(block.id) at index \(index)")
        draggingBlockId = block.id
        initialIndex = index
        dragOffset = 0
    }
    
    private func endDrag() {
        guard let initial = initialIndex,
              let target = currentTargetIndex else {
            resetDragState()
            return
        }
        
        print("📦 Drag ended - initial: \(initial), target: \(target)")
        
        if initial != target {
            print("✅ Moving from \(initial) to \(target)")
            viewModel.moveBlock(fromIndex: initial, toIndex: target)
        }
        
        resetDragState()
    }
    
    private func resetDragState() {
        withAnimation(.easeOut(duration: 0.15)) {
            draggingBlockId = nil
            dragOffset = 0
            initialIndex = nil
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

#Preview("With Many Blocks") {
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
        ),
        EditorBlock.newPhoto(
            order: 2,
            caption: "Sunset at the beach"
        ),
        EditorBlock.newRecommendation(
            order: 3,
            name: "Aristocrat Restaurant",
            category: .eat
        ),
        EditorBlock.newDivider(order: 4)
    ]
    
    return ZStack {
        AppTheme.Colors.passportPageDark
            .ignoresSafeArea()
        
        ScrollView {
            EditorBlocksSection(viewModel: viewModel)
                .padding()
        }
    }
}
