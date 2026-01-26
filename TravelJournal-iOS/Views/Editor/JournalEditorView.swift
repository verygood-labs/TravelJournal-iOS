import SwiftUI

struct JournalEditorView: View {
    // ViewModel
    @StateObject private var viewModel: JournalEditorViewModel
    
    // Environment
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Initialization
    
    init(trip: Trip) {
        _viewModel = StateObject(wrappedValue: JournalEditorViewModel(trip: trip))
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Top navigation bar
            EditorNavigationBar(
                viewModel: viewModel,
                onCancel: { dismiss() },
                onDone: { handleDone() }
            )
            
            // Main content based on mode
            if viewModel.editorMode == .edit {
                editModeContent
            } else {
                previewModeContent
            }
            
            // Bottom toolbar (only in edit mode)
            if viewModel.editorMode == .edit {
                EditorBlockToolbar(viewModel: viewModel)
            }
        }
        .background(AppTheme.Colors.passportPageDark)
        .navigationBarHidden(true)
        .task {
            await viewModel.loadDraft()
        }
        .sheet(isPresented: $viewModel.showingBlockSheet) {
            if let blockType = viewModel.selectedBlockType {
                BlockEditorSheet(
                    blockType: blockType,
                    existingBlock: viewModel.editingBlock,
                    onSave: { block in
                        viewModel.saveBlock(block)
                    },
                    onDelete: viewModel.editingBlock != nil ? {
                        if let block = viewModel.editingBlock {
                            viewModel.deleteBlock(block)
                        }
                    } : nil
                )
            }
        }
    }
    
    // MARK: - Edit Mode Content
    
    private var editModeContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Cover image section
                EditorCoverSection(viewModel: viewModel)
                
                // Trip header card
                EditorTripHeaderCard(
                    viewModel: viewModel,
                    onDatesTapped: { handleDatesTapped() },
                    onLocationTapped: { handleLocationTapped() }
                )
                .padding(.horizontal, AppTheme.Spacing.md)
                .offset(y: -40)
                
                // Journal blocks
                EditorBlocksSection(viewModel: viewModel)
                    .padding(.horizontal, AppTheme.Spacing.md)
                
                // Bottom spacing for toolbar
                Spacer()
                    .frame(height: 100)
            }
        }
    }
    
    // MARK: - Preview Mode Content
    
    private var previewModeContent: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.md) {
                Text("Preview Mode")
                    .font(AppTheme.Typography.monoMedium())
                    .foregroundColor(AppTheme.Colors.passportTextSecondary)
                
                // TODO: Implement preview rendering
            }
            .padding()
        }
    }
    
    // MARK: - Actions
    
    private func handleDone() {
        Task {
            let success = await viewModel.saveAndClose()
            if success {
                dismiss()
            }
        }
    }
    
    private func handleDatesTapped() {
        // TODO: Show date picker
        print("Dates tapped")
    }
    
    private func handleLocationTapped() {
        // TODO: Show location picker
        print("Location tapped")
    }
}

// MARK: - Preview

#Preview("Empty") {
    let sampleTrip = Trip(
        id: UUID(),
        title: "Two Weeks in the Philippines",
        description: "Island hopping adventure",
        coverImageUrl: nil,
        status: .draft,
        tripMode: .live,
        startDate: Date(),
        endDate: Date().addingTimeInterval(86400 * 14),
        createdAt: Date(),
        updatedAt: Date(),
        stops: [
            TripStop(id: UUID(), order: 0, arrivalDate: nil, place: TripStopPlace(id: UUID(), name: "Manila", displayName: "Manila, Philippines", placeType: .city, countryCode: "PH")),
            TripStop(id: UUID(), order: 1, arrivalDate: nil, place: TripStopPlace(id: UUID(), name: "Palawan", displayName: "Palawan, Philippines", placeType: .city, countryCode: "PH")),
            TripStop(id: UUID(), order: 2, arrivalDate: nil, place: TripStopPlace(id: UUID(), name: "Cebu", displayName: "Cebu, Philippines", placeType: .city, countryCode: "PH")),
            TripStop(id: UUID(), order: 3, arrivalDate: nil, place: TripStopPlace(id: UUID(), name: "Siargao", displayName: "Siargao, Philippines", placeType: .city, countryCode: "PH"))
        ]
    )
    
    JournalEditorView(trip: sampleTrip)
}

#Preview("With Blocks") {
    let sampleTrip = Trip(
        id: UUID(),
        title: "Two Weeks in the Philippines",
        description: "Island hopping adventure",
        coverImageUrl: nil,
        status: .draft,
        tripMode: .live,
        startDate: Date(),
        endDate: Date().addingTimeInterval(86400 * 14),
        createdAt: Date(),
        updatedAt: Date(),
        stops: [
            TripStop(id: UUID(), order: 0, arrivalDate: nil, place: TripStopPlace(id: UUID(), name: "Manila", displayName: "Manila, Philippines", placeType: .city, countryCode: "PH")),
            TripStop(id: UUID(), order: 1, arrivalDate: nil, place: TripStopPlace(id: UUID(), name: "Palawan", displayName: "Palawan, Philippines", placeType: .city, countryCode: "PH")),
            TripStop(id: UUID(), order: 2, arrivalDate: nil, place: TripStopPlace(id: UUID(), name: "Cebu", displayName: "Cebu, Philippines", placeType: .city, countryCode: "PH")),
            TripStop(id: UUID(), order: 3, arrivalDate: nil, place: TripStopPlace(id: UUID(), name: "Siargao", displayName: "Siargao, Philippines", placeType: .city, countryCode: "PH"))
        ]
    )
    
    JournalEditorViewPreview(trip: sampleTrip)
}

// MARK: - Preview Helper

/// Preview wrapper that allows injecting sample data into the view model
private struct JournalEditorViewPreview: View {
    let trip: Trip
    
    var body: some View {
        JournalEditorViewWithBlocks(trip: trip)
    }
}

private struct JournalEditorViewWithBlocks: View {
    @StateObject private var viewModel: JournalEditorViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(trip: Trip) {
        let vm = JournalEditorViewModel(trip: trip)
        vm.blocks = [
            JournalBlock(
                id: UUID(),
                type: .moment,
                content: "Arrival & Intramuros\n\nLanded at NAIA around 6am, groggy but excited. The humidity hit immediately...",
                imageUrl: nil,
                order: 0,
                createdAt: Date()
            ),
            JournalBlock(
                id: UUID(),
                type: .image,
                content: "First glimpse of Manila skyline",
                imageUrl: nil,
                order: 1,
                createdAt: Date()
            ),
            JournalBlock(
                id: UUID(),
                type: .tip,
                content: "Getting Around\n\nUse Grab for affordable transportation. Much cheaper and safer than regular taxis, especially from the airport.",
                imageUrl: nil,
                order: 2,
                createdAt: Date()
            ),
            JournalBlock(
                id: UUID(),
                type: .recommendation,
                content: "Aristocrat Restaurant\n\nBest chicken barbecue in Manila! A must-visit institution since 1936.",
                imageUrl: nil,
                order: 3,
                createdAt: Date()
            ),
            JournalBlock(
                id: UUID(),
                type: .text,
                content: "The street food scene here is incredible. Every corner has something new to try - from fish balls to balut (if you're brave enough!).",
                imageUrl: nil,
                order: 4,
                createdAt: Date()
            )
        ]
        _viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            EditorNavigationBar(
                viewModel: viewModel,
                onCancel: { dismiss() },
                onDone: { }
            )
            
            if viewModel.editorMode == .edit {
                ScrollView {
                    VStack(spacing: 0) {
                        EditorCoverSection(viewModel: viewModel)
                        
                        EditorTripHeaderCard(
                            viewModel: viewModel,
                            onDatesTapped: { },
                            onLocationTapped: { }
                        )
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .offset(y: -40)
                        
                        EditorBlocksSection(viewModel: viewModel)
                            .padding(.horizontal, AppTheme.Spacing.md)
                        
                        Spacer()
                            .frame(height: 100)
                    }
                }
            } else {
                ScrollView {
                    Text("Preview Mode")
                        .font(AppTheme.Typography.monoMedium())
                        .foregroundColor(AppTheme.Colors.passportTextSecondary)
                        .padding()
                }
            }
            
            if viewModel.editorMode == .edit {
                EditorBlockToolbar(viewModel: viewModel)
            }
        }
        .background(AppTheme.Colors.passportPageDark)
        .sheet(isPresented: $viewModel.showingBlockSheet) {
            if let blockType = viewModel.selectedBlockType {
                BlockEditorSheet(
                    blockType: blockType,
                    existingBlock: viewModel.editingBlock,
                    onSave: { block in
                        viewModel.saveBlock(block)
                    },
                    onDelete: viewModel.editingBlock != nil ? {
                        if let block = viewModel.editingBlock {
                            viewModel.deleteBlock(block)
                        }
                    } : nil
                )
            }
        }
    }
}
