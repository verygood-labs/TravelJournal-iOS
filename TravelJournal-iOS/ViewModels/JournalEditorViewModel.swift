//
//  JournalEditorViewModel.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/22/26.
//

import Combine
import SwiftUI

@MainActor
final class JournalEditorViewModel: ObservableObject {
    // MARK: - Published Properties

    // Trip data
    @Published var tripTitle: String
    @Published var tripDescription: String
    @Published var coverImageUrl: String?
    @Published var selectedCoverImage: UIImage?
    @Published var loadedStops: [TripStop] = []

    /// Blocks
    @Published var blocks: [EditorBlock] = []

    // UI State
    @Published var editorMode: EditorMode = .edit
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var error: String?
    @Published var loadFailed = false

    // Sheet state
    @Published var showingBlockSheet = false
    @Published var selectedBlockType: BlockType?
    @Published var editingBlock: EditorBlock?

    // Cover image picker state
    @Published var showingCoverImagePicker = false
    @Published var showingCoverCamera = false

    // MARK: - Alert State

    @Published var showingCloseWarning = false

    // MARK: - Private Properties

    private let trip: Trip
    private let tripService = TripService.shared
    private let toastManager: ToastManager

    // MARK: - Change Tracking

    private var originalBlocks: [EditorBlock] = []
    private var originalTitle: String = ""
    private var originalDescription: String = ""
    private var originalCoverImageUrl: String?

    // MARK: - Computed Properties

    var tripId: UUID {
        trip.id
    }

    var tripStops: [TripStop] {
        loadedStops
    }

    var routeText: String? {
        guard !tripStops.isEmpty else { return nil }
        return tripStops.map { $0.place.name }.joined(separator: " → ")
    }

    var tripStartDate: Date? {
        trip.startDate
    }

    var tripEndDate: Date? {
        trip.endDate
    }

    var startDateText: String? {
        guard let start = trip.startDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: start)
    }

    var endDateText: String? {
        guard let end = trip.endDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: end)
    }

    var dateRangeText: String? {
        // Keep for compatibility - returns start date if available
        return startDateText
    }

    var hasUnsavedChanges: Bool {
        // Compare blocks
        if blocks != originalBlocks {
            return true
        }
        
        // Compare metadata
        if tripTitle != originalTitle {
            return true
        }
        
        if tripDescription != originalDescription {
            return true
        }
        
        if coverImageUrl != originalCoverImageUrl {
            return true
        }
        
        // Check if a new cover image was selected
        if selectedCoverImage != nil {
            return true
        }
        
        return false
    }

    // MARK: - Initialization

    init(trip: Trip, toastManager: ToastManager) {
        self.trip = trip
        self.toastManager = toastManager
        tripTitle = trip.title
        tripDescription = trip.description ?? ""
        coverImageUrl = trip.coverImageUrl
    }

    // MARK: - Block Management

    func addBlock(type: BlockType) {
        // Divider doesn't need a sheet - insert directly
        if type == .divider {
            let dividerBlock = EditorBlock.newDivider(order: blocks.count)
            blocks.append(dividerBlock)
            return
        }

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
        loadFailed = false

        do {
            // Fetch full trip details to get stops
            async let tripTask = tripService.getTrip(id: trip.id)
            async let draftTask = tripService.getDraft(tripId: trip.id)
            
            let (fullTrip, draft) = try await (tripTask, draftTask)
            
            loadedStops = fullTrip.stops ?? []
            blocks = draft.blocks
            
            // Snapshot original state for change tracking
            snapshotOriginalState()
        } catch {
            print("Failed to load draft: \(error)")
            toastManager.show(.error("Failed to load draft. Please try again."))
            loadFailed = true
        }

        isLoading = false
    }

    private func snapshotOriginalState() {
        originalBlocks = blocks
        originalTitle = tripTitle
        originalDescription = tripDescription
        originalCoverImageUrl = coverImageUrl
    }

    // MARK: - Close Handling

    func handleClose() -> Bool {
        if hasUnsavedChanges {
            showingCloseWarning = true
            return false // Don't dismiss yet
        }
        return true // Safe to dismiss
    }

    func discardChanges() {
        // Reset to original state (optional, since we're dismissing anyway)
        blocks = originalBlocks
        tripTitle = originalTitle
        tripDescription = originalDescription
        coverImageUrl = originalCoverImageUrl
        selectedCoverImage = nil
    }

    func saveAndClose() async -> Bool {
        let success = await saveDraft()
        return success
    }
    
    /// Saves the draft blocks and any metadata changes
    /// Returns true if save was successful
    @discardableResult
    private func saveDraft() async -> Bool {
        isSaving = true

        do {
            // Save draft blocks
            let content = EditorContent(blocks: blocks)
            try await tripService.saveDraft(tripId: trip.id, content: content)
            
            // Upload cover image if a new one was selected
            var newCoverImageUrl: String? = nil
            if let coverImage = selectedCoverImage {
                let uploadResult = try await MediaService.shared.upload(
                    image: coverImage,
                    type: .tripCover,
                    tripId: trip.id
                )
                newCoverImageUrl = uploadResult.url
            }
            
            // Update trip metadata if changed (title, description, or cover)
            let titleChanged = tripTitle != originalTitle
            let descriptionChanged = tripDescription != originalDescription
            let coverChanged = newCoverImageUrl != nil || (selectedCoverImage == nil && coverImageUrl != originalCoverImageUrl)
            
            if titleChanged || descriptionChanged || coverChanged {
                // Determine the cover URL to send
                let coverUrlToSend: String?
                if let newUrl = newCoverImageUrl {
                    coverUrlToSend = newUrl
                } else if selectedCoverImage == nil && coverImageUrl == nil {
                    // Cover was removed
                    coverUrlToSend = ""
                } else {
                    coverUrlToSend = nil // No change
                }
                
                _ = try await tripService.updateTrip(
                    id: trip.id,
                    title: titleChanged ? tripTitle : nil,
                    description: descriptionChanged ? tripDescription : nil,
                    coverImageUrl: coverUrlToSend
                )
                
                // Update local state with new cover URL
                if let newUrl = newCoverImageUrl {
                    coverImageUrl = newUrl
                    selectedCoverImage = nil
                }
            }
            
            // Update snapshot so hasUnsavedChanges becomes false
            snapshotOriginalState()
            
            toastManager.show(.success("Draft saved"))
            isSaving = false
            return true
        } catch {
            print("Failed to save draft: \(error)")
            toastManager.show(.error("Failed to save draft. Please try again."))
            isSaving = false
            return false
        }
    }

    // MARK: - Save Action

    func handleSave() {
        Task {
            await saveDraft()
        }
    }

    // MARK: - Done Action (Preview Mode)

    func handleDone() {
        print("Done button tapped - implement publish logic later")
        // TODO: Implement publish flow
    }
}

// MARK: - Editor Mode Enum

enum EditorMode: String, CaseIterable {
    case edit = "Edit"
    case preview = "Preview"
}
