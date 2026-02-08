import SwiftUI

struct JournalEditorView: View {
    /// ViewModel
    @StateObject private var viewModel: JournalEditorViewModel

    /// Environment
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var toastManager: ToastManager

    // MARK: - Initialization

    init(trip: Trip, toastManager: ToastManager) {
        _viewModel = StateObject(wrappedValue: JournalEditorViewModel(trip: trip, toastManager: toastManager))
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Top navigation bar
            EditorNavigationBar(
                viewModel: viewModel,
                onClose: { handleClose() },
                onSave: { viewModel.handleSave() },
                onDone: { viewModel.handleDone() }
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
        .onChange(of: viewModel.editorMode) { _, newMode in
            if newMode == .preview {
                Task {
                    await viewModel.loadThemes()
                }
            }
        }
        .onChange(of: viewModel.loadFailed) { _, failed in
            if failed {
                dismiss()
            }
        }
        .sheet(isPresented: $viewModel.showingBlockSheet) {
            if let blockType = viewModel.selectedBlockType {
                BlockEditorSheet(
                    blockType: blockType,
                    existingBlock: viewModel.editingBlock,
                    tripId: viewModel.tripId,
                    tripCountryCode: viewModel.tripCountryCode,
                    tripLatitude: viewModel.tripLatitude,
                    tripLongitude: viewModel.tripLongitude,
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
        .alert("Unsaved Changes", isPresented: $viewModel.showingCloseWarning) {
            Button("Discard", role: .destructive) {
                viewModel.discardChanges()
                dismiss()
            }
            Button("Save & Close") {
                Task {
                    if await viewModel.saveAndClose() {
                        dismiss()
                    }
                }
            }
            Button("Continue Editing", role: .cancel) { }
        } message: {
            Text("You have unsaved changes. What would you like to do?")
        }
        .sheet(isPresented: $viewModel.showingPublishSheet) {
            PublishSettingsSheet(
                selectedVisibility: $viewModel.selectedVisibility,
                isPublishing: viewModel.isPublishing,
                onPublish: {
                    Task {
                        await viewModel.publishJournal()
                    }
                }
            )
            .presentationDetents([.medium])
        }
        .onChange(of: viewModel.publishSucceeded) { _, succeeded in
            if succeeded {
                dismiss()
            }
        }
        .modifier(ToastModifier(manager: toastManager, position: .bottom))
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
        JournalPreviewView(
            title: viewModel.tripTitle,
            description: viewModel.tripDescription.isEmpty ? nil : viewModel.tripDescription,
            coverImageUrl: viewModel.coverImageUrl,
            startDate: viewModel.tripStartDate,
            endDate: viewModel.tripEndDate,
            stops: viewModel.tripStops,
            blocks: viewModel.blocks,
            availableThemes: viewModel.availableThemes,
            selectedTheme: $viewModel.selectedTheme,
            isLoadingThemes: viewModel.isLoadingThemes,
            onThemeSelected: { theme in
                viewModel.selectTheme(theme)
            }
        )
    }

    // MARK: - Actions

    private func handleClose() {
        if viewModel.handleClose() {
            dismiss()
        }
        // If false, the viewModel will show the alert
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
            TripStop(id: UUID(), order: 0, arrivalDate: nil, place: TripStopPlace(id: UUID(), name: "Manila", displayName: "Manila, Philippines", placeType: .city, countryCode: "PH", latitude: 14.5995, longitude: 120.9842)),
            TripStop(id: UUID(), order: 1, arrivalDate: nil, place: TripStopPlace(id: UUID(), name: "Palawan", displayName: "Palawan, Philippines", placeType: .city, countryCode: "PH", latitude: 9.8349, longitude: 118.7384)),
            TripStop(id: UUID(), order: 2, arrivalDate: nil, place: TripStopPlace(id: UUID(), name: "Cebu", displayName: "Cebu, Philippines", placeType: .city, countryCode: "PH", latitude: 10.3157, longitude: 123.8854)),
            TripStop(id: UUID(), order: 3, arrivalDate: nil, place: TripStopPlace(id: UUID(), name: "Siargao", displayName: "Siargao, Philippines", placeType: .city, countryCode: "PH", latitude: 9.8482, longitude: 126.0458)),
        ]
    )

    JournalEditorView(trip: sampleTrip, toastManager: ToastManager())
        .environmentObject(ToastManager())
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
            TripStop(id: UUID(), order: 0, arrivalDate: nil, place: TripStopPlace(id: UUID(), name: "Manila", displayName: "Manila, Philippines", placeType: .city, countryCode: "PH", latitude: 14.5995, longitude: 120.9842)),
            TripStop(id: UUID(), order: 1, arrivalDate: nil, place: TripStopPlace(id: UUID(), name: "Palawan", displayName: "Palawan, Philippines", placeType: .city, countryCode: "PH", latitude: 9.8349, longitude: 118.7384)),
            TripStop(id: UUID(), order: 2, arrivalDate: nil, place: TripStopPlace(id: UUID(), name: "Cebu", displayName: "Cebu, Philippines", placeType: .city, countryCode: "PH", latitude: 10.3157, longitude: 123.8854)),
            TripStop(id: UUID(), order: 3, arrivalDate: nil, place: TripStopPlace(id: UUID(), name: "Siargao", displayName: "Siargao, Philippines", placeType: .city, countryCode: "PH", latitude: 9.8482, longitude: 126.0458)),
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
        let vm = JournalEditorViewModel(trip: trip, toastManager: ToastManager())
        vm.blocks = [
            EditorBlock.newMoment(
                order: 0,
                title: "Arrival & Intramuros",
                content: "Landed at NAIA around 6am, groggy but excited. The humidity hit immediately..."
            ),
            EditorBlock.newPhoto(
                order: 1,
                caption: "First glimpse of Manila skyline"
            ),
            EditorBlock.newTip(
                order: 2,
                title: "Getting Around",
                content: "Use Grab for affordable transportation. Much cheaper and safer than regular taxis, especially from the airport."
            ),
            EditorBlock.newRecommendation(
                order: 3,
                name: "Aristocrat Restaurant",
                category: .eat,
                note: "Best chicken barbecue in Manila! A must-visit institution since 1936."
            ),
            EditorBlock.newMoment(
                order: 4,
                content: "The street food scene here is incredible. Every corner has something new to try - from fish balls to balut (if you're brave enough!)."
            ),
        ]
        _viewModel = StateObject(wrappedValue: vm)
    }

    var body: some View {
        VStack(spacing: 0) {
            EditorNavigationBar(
                viewModel: viewModel,
                onClose: { dismiss() },
                onSave: {},
                onDone: {}
            )

            if viewModel.editorMode == .edit {
                ScrollView {
                    VStack(spacing: 0) {
                        EditorCoverSection(viewModel: viewModel)

                        EditorTripHeaderCard(
                            viewModel: viewModel,
                            onDatesTapped: {},
                            onLocationTapped: {}
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
                    tripId: viewModel.tripId,
                    tripCountryCode: viewModel.tripCountryCode,
                    tripLatitude: viewModel.tripLatitude,
                    tripLongitude: viewModel.tripLongitude,
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
