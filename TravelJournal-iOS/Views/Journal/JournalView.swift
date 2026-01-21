import SwiftUI

struct JournalView: View {
    @StateObject private var viewModel = JournalViewModel()
    @State private var showingAddTrip = false
    
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
                    tripsList
                }
            }
            
            // Floating Action Button
            if !viewModel.trips.isEmpty {
                floatingAddButton
                    .padding(.trailing, AppTheme.Spacing.lg)
                    .padding(.bottom, AppTheme.Spacing.lg)
            }
        }
        .sheet(isPresented: $showingAddTrip) {
            AddTripView { trip in
                Task {
                    await viewModel.addTrip(trip)
                }
            }
        }
        .task {
            await viewModel.loadTrips()
        }
        .refreshable {
            await viewModel.loadTrips()
        }
    }
    
    // MARK: - Trips List
    private var tripsList: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                headerSection
                    .padding(.top, AppTheme.Spacing.lg)
                    .padding(.bottom, AppTheme.Spacing.md)
                
                // Trip Cards
                LazyVStack(spacing: AppTheme.Spacing.lg) {
                    ForEach(viewModel.trips) { trip in
                        JournalTripCard(
                            trip: trip,
                            onView: {
                                handleViewTrip(trip)
                            },
                            onEdit: {
                                handleEditTrip(trip)
                            }
                        )
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.bottom, AppTheme.Spacing.xxxl + 60) // Extra space for FAB
            }
        }
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
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .medium))
                    Text("CREATE YOUR FIRST JOURNAL")
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
        print("✏️ Edit trip: \(trip.title)")
        // TODO: Navigate to trip edit view
    }
}

#Preview {
    JournalView()
}
