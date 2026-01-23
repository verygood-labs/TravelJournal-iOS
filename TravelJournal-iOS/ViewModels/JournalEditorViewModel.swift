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
    @Published var blocks: [JournalBlock] = []
    
    // UI State
    @Published var editorMode: EditorMode = .edit
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var error: String?
    
    // Sheet state
    @Published var showingBlockSheet = false
    @Published var selectedBlockType: BlockType?
    @Published var editingBlock: JournalBlock?
    
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
        return tripStops.map { $0.placeName }.joined(separator: " → ")
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
    
    func editBlock(_ block: JournalBlock) {
        selectedBlockType = block.type
        editingBlock = block
        showingBlockSheet = true
    }
    
    func saveBlock(_ block: JournalBlock) {
        if let index = blocks.firstIndex(where: { $0.id == block.id }) {
            // Update existing block
            blocks[index] = block
        } else {
            // Add new block with correct order
            var newBlock = block
            // Create new block with updated order
            let updatedBlock = JournalBlock(
                id: newBlock.id,
                type: newBlock.type,
                content: newBlock.content,
                imageUrl: newBlock.imageUrl,
                order: blocks.count,
                createdAt: newBlock.createdAt
            )
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
    
    func deleteBlock(_ block: JournalBlock) {
        blocks.removeAll { $0.id == block.id }
        
        // Reorder remaining blocks
        for (index, _) in blocks.enumerated() {
            let existingBlock = blocks[index]
            blocks[index] = JournalBlock(
                id: existingBlock.id,
                type: existingBlock.type,
                content: existingBlock.content,
                imageUrl: existingBlock.imageUrl,
                order: index,
                createdAt: existingBlock.createdAt
            )
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
            // TODO: Save all changes to API
            // - Upload cover image if changed
            // - Save blocks
            // - Update trip metadata
            
            isSaving = false
            return true
        } catch {
            self.error = error.localizedDescription
            isSaving = false
            return false
        }
    }
}

// MARK: - Editor Mode Enum

enum EditorMode: String, CaseIterable {
    case edit = "Edit"
    case preview = "Preview"
}