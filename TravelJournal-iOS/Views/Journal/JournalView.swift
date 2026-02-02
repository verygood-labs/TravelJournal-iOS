import SwiftUI

struct JournalView: View {
    @StateObject private var viewModel = JournalViewModel()
    @State private var showingAddTrip = false
    @State private var tripToEdit: Trip?
    @State private var showingEditor = false
    @State private var viewMode: JournalViewMode = .card
    @State private var tripToDelete: Trip?
    @State private var showingDeleteConfirmation = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Main content
            AppBackgroundView {
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.error {
                    errorView(message: error)
                } else if viewModel.trips.isEmpty {
                    emptyStateView
                } else {
                    VStack(spacing: 0) {
                        // Fixed header
                        headerSection
                            .padding(.top, AppTheme.Spacing.lg)
                            .padding(.bottom, AppTheme.Spacing.md)

                        // Toggle tabs
                        JournalViewToggle(selectedMode: $viewMode)
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            .padding(.bottom, AppTheme.Spacing.md)

                        // Scrollable content
                        ScrollView {
                            tripsList
                                .padding(.bottom, AppTheme.Spacing.xxxl + 60) // Extra space for FAB
                        }
                    }
                }
            }

            // Floating Action Button
            if !viewModel.trips.isEmpty {
                floatingAddButton
                    .padding(.trailing, AppTheme.Spacing.lg)
                    .padding(.bottom, AppTheme.Spacing.lg)
            }
        }
        .sheet(isPresented: $showingAddTrip, onDismiss: {
            // After AddTripView dismisses, check if we should show editor
            if tripToEdit != nil {
                showingEditor = true
            }
        }) {
            AddTripView(onTripCreated: { trip in
                print("📥 JournalView received trip: \(trip.id)")
                tripToEdit = trip
                showingAddTrip = false // ← Dismiss by setting this to false
            })
        }
        .fullScreenCover(item: $tripToEdit, onDismiss: {
            Task {
                await viewModel.loadTrips()
            }
        }) { trip in
            let _ = print("🎯 Opening editor with trip: \(trip.id), title: \(trip.title)")
            JournalEditorView(trip: trip)
        }
        .task {
            await viewModel.loadTrips()
        }
        .refreshable {
            await viewModel.loadTrips()
        }
        .alert("Delete Trip", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                tripToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let trip = tripToDelete {
                    Task {
                        await viewModel.deleteTrip(trip)
                    }
                }
                tripToDelete = nil
            }
        } message: {
            Text("Are you sure you want to delete \"\(tripToDelete?.title ?? "")\"? This action cannot be undone.")
        }
    }

    // MARK: - Trips List

    private var tripsList: some View {
        LazyVStack(spacing: viewMode == .card ? AppTheme.Spacing.lg : AppTheme.Spacing.xs) {
            ForEach(viewModel.trips) { trip in
                Group {
                    if viewMode == .card {
                        JournalTripCard(
                            trip: trip,
                            onView: { handleViewTrip(trip) },
                            onEdit: { handleEditTrip(trip) },
                            onDelete: { handleDeleteTrip(trip) }
                        )
                    } else {
                        JournalTripRow(
                            trip: trip,
                            onView: { handleViewTrip(trip) },
                            onEdit: { handleEditTrip(trip) },
                            onDelete: { handleDeleteTrip(trip) }
                        )
                    }
                }
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Text("TRAVEL JOURNAL")
                .font(AppTheme.Typography.monoSmall())
                .tracking(3)
                .foregroundColor(AppTheme.Colors.primary.opacity(0.7))

            Text("Your Adventures")
                .font(AppTheme.Typography.serifMedium())
                .foregroundColor(AppTheme.Colors.primary)

            Text("\(viewModel.trips.count) \(viewModel.trips.count == 1 ? "journey" : "journeys") documented")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
    }

    // MARK: - Floating Add Button

    private var floatingAddButton: some View {
        Button {
            showingAddTrip = true
        } label: {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.primary)
                    .frame(width: 56, height: 56)
                    .shadow(color: AppTheme.Colors.primary.opacity(0.4), radius: 8, y: 4)

                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(AppTheme.Colors.backgroundDark)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()

            // Decorative icon
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.primary.opacity(0.1))
                    .frame(width: 120, height: 120)

                Image(systemName: "book.pages")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(AppTheme.Colors.primary.opacity(0.6))
            }

            VStack(spacing: AppTheme.Spacing.xs) {
                Text("No Journeys Yet")
                    .font(AppTheme.Typography.serifMedium())
                    .foregroundColor(AppTheme.Colors.primary)

                Text("Start documenting your adventures\nand create lasting memories")
                    .font(AppTheme.Typography.monoSmall())
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            Button {
                showingAddTrip = true
            } label: {
                HStack(spacing: AppTheme.Spacing.xxs) {
                    Text("START YOUR JOURNAL")
                        .font(AppTheme.Typography.button())
                        .tracking(1)
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, AppTheme.Spacing.xl)
            .padding(.top, AppTheme.Spacing.sm)

            Spacer()
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            AnimatedGlobeView(size: 60)

            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.primary))

            Text("Loading your journals...")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
    }

    // MARK: - Error View

    private func errorView(message: String) -> some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.Colors.primary.opacity(0.6))

            VStack(spacing: AppTheme.Spacing.xs) {
                Text("Unable to Load Journals")
                    .font(AppTheme.Typography.serifSmall())
                    .foregroundColor(AppTheme.Colors.primary)

                Text(message)
                    .font(AppTheme.Typography.monoSmall())
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.xl)
            }

            Button {
                Task {
                    await viewModel.loadTrips()
                }
            } label: {
                HStack(spacing: AppTheme.Spacing.xxs) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .medium))
                    Text("TRY AGAIN")
                        .font(AppTheme.Typography.button())
                        .tracking(1)
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .frame(width: 180)

            Spacer()
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }

    // MARK: - Actions

    private func handleViewTrip(_ trip: Trip) {
        print("👁️ View trip: \(trip.title)")
        // TODO: Navigate to trip detail view
    }

    private func handleEditTrip(_ trip: Trip) {
        tripToEdit = trip
    }

    private func handleDeleteTrip(_ trip: Trip) {
        tripToDelete = trip
        showingDeleteConfirmation = true
    }
}

#Preview {
    JournalView()
}
