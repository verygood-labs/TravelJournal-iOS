//
//  JournalEditorViewModel.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/22/26.
//


import SwiftUI
import Combine

@MainActor
final class JournalEditorViewModel: ObservableObject {
    // MARK: - Published Properties
    
    // Trip data
    @Published var tripTitle: String
    @Published var tripDescription: String
    @Published var coverImageUrl: String?
    @Published var selectedCoverImage: UIImage?
    
    // Blocks
    @Published var blocks: [EditorBlock] = []
    
    // UI State
    @Published var editorMode: EditorMode = .edit
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var error: String?
    
    // Sheet state
    @Published var showingBlockSheet = false
    @Published var selectedBlockType: BlockType?
    @Published var editingBlock: EditorBlock?
    
    // Cover image picker state
    @Published var showingCoverImagePicker = false
    @Published var showingCoverCamera = false
    
    // MARK: - Private Properties
    
    private let trip: Trip
    private let tripService = TripService.shared
    
    // MARK: - Computed Properties
    
    var tripId: UUID {
        trip.id
    }
    
    var tripStops: [TripStop] {
        trip.stops ?? []
    }
    
    var routeText: String? {
        guard !tripStops.isEmpty else { return nil }
        return tripStops.map { $0.place.name }.joined(separator: " → ")
    }
    
    var hasUnsavedChanges: Bool {
        // TODO: Implement change tracking
        false
    }
    
    // MARK: - Initialization
    
    init(trip: Trip) {
        self.trip = trip
        self.tripTitle = trip.title
        self.tripDescription = trip.description ?? ""
        self.coverImageUrl = trip.coverImageUrl
    }
    
    // MARK: - Block Management
    
    func addBlock(type: BlockType) {
        selectedBlockType = type
        editingBlock = nil
        showingBlockSheet = true
    }
    
    func editBlock(_ block: EditorBlock) {
        selectedBlockType = block.type
        editingBlock = block
        showingBlockSheet = true
    }
    
    func saveBlock(_ block: EditorBlock) {
        if let index = blocks.firstIndex(where: { $0.id == block.id }) {
            // Update existing block
            blocks[index] = block
        } else {
            // Add new block with correct order
            var updatedBlock = block
            updatedBlock.order = blocks.count
            blocks.append(updatedBlock)
        }
        
        // Reset sheet state
        showingBlockSheet = false
        selectedBlockType = nil
        editingBlock = nil
        
        // TODO: Save to API
        Task {
            await saveDraftToAPI()
        }
    }
    
    func deleteBlock(_ block: EditorBlock) {
        blocks.removeAll { $0.id == block.id }
        
        // Reorder remaining blocks
        for index in blocks.indices {
            blocks[index].order = index
        }
        
        // Reset sheet state
        showingBlockSheet = false
        selectedBlockType = nil
        editingBlock = nil
        
        // TODO: Delete from API
        Task {
            await saveDraftToAPI()
        }
    }
    
    func moveBlock(fromIndex: Int, toIndex: Int) {
        guard fromIndex != toIndex,
              fromIndex >= 0,
              fromIndex < blocks.count,
              toIndex >= 0,
              toIndex < blocks.count else { return }
        
        withAnimation(.default) {
            let block = blocks.remove(at: fromIndex)
            blocks.insert(block, at: toIndex)
            
            for index in blocks.indices {
                blocks[index].order = index
            }
        }
    }
    
    // MARK: - Cover Image
    
    func selectCoverFromLibrary() {
        showingCoverImagePicker = true
    }
    
    func selectCoverFromCamera() {
        showingCoverCamera = true
    }
    
    func removeCoverImage() {
        selectedCoverImage = nil
        coverImageUrl = nil
    }
    
    // MARK: - API Operations
    
    func loadDraft() async {
        isLoading = true
        error = nil
        
        do {
            let draft = try await tripService.getDraft(tripId: trip.id)
            blocks = draft.blocks
        } catch {
            print("Failed to load draft: \(error)")
            // Not critical - just means no existing blocks
        }
        
        isLoading = false
    }
    
    private func saveDraftToAPI() async {
        // TODO: Implement API save
        print("Saving draft with \(blocks.count) blocks")
    }
    
    func saveAndClose() async -> Bool {
        isSaving = true
        error = nil
        
        do {
            // TODO: Implement actual API save
            // - Upload cover image if changed
            // - Save blocks
            // - Update trip metadata
            
            // This will throw when implemented
            try await saveTripToAPI()
            
            isSaving = false
            return true
        } catch {
            self.error = error.localizedDescription
            isSaving = false
            return false
        }
    }

    private func saveTripToAPI() async throws {
        // TODO: Implement - this will throw errors when real API calls are added
        try? await Task.sleep(nanoseconds: 500_000_000)
    }
}

// MARK: - Editor Mode Enum

enum EditorMode: String, CaseIterable {
    case edit = "Edit"
    case preview = "Preview"
}
