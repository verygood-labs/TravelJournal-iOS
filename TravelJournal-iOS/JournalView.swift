import SwiftUI

struct JournalView: View {
    @StateObject private var viewModel = JournalViewModel()
    @State private var showingAddTrip = false
    
    var body: some View {
        NavigationStack {
            ZStack {
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
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddTrip = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                }
            }
            .sheet(isPresented: $showingAddTrip) {
                AddTripView(onSave: { trip in
                    Task {
                        await viewModel.addTrip(trip)
                    }
                })
            }
            .task {
                await viewModel.loadTrips()
            }
            .refreshable {
                await viewModel.loadTrips()
            }
        }
    }
    
    // MARK: - Trips List
    private var tripsList: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.Spacing.md) {
                ForEach(viewModel.trips) { trip in
                    TripCard(trip: trip)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                }
            }
            .padding(.vertical, AppTheme.Spacing.md)
        }
        .background(AppTheme.Colors.backgroundLight)
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "book.pages")
                .font(.system(size: 70))
                .foregroundColor(AppTheme.Colors.primary.opacity(0.4))
            
            VStack(spacing: AppTheme.Spacing.xs) {
                Text("No Trips Yet")
                    .font(AppTheme.Typography.serifMedium())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text("Start documenting your adventures")
                    .font(AppTheme.Typography.monoSmall())
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            Button {
                showingAddTrip = true
            } label: {
                HStack(spacing: AppTheme.Spacing.xxs) {
                    Image(systemName: "plus")
                    Text("ADD YOUR FIRST TRIP")
                        .font(AppTheme.Typography.button())
                        .tracking(1)
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top, AppTheme.Spacing.sm)
        }
        .padding(.horizontal, AppTheme.Spacing.xl)
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            AnimatedGlobeView(size: 60)
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.primary))
            
            Text("Loading journal...")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
    }
    
    // MARK: - Error View
    private func errorView(message: String) -> some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.Colors.primary.opacity(0.6))
            
            Text("Unable to Load Journal")
                .font(AppTheme.Typography.serifSmall())
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text(message)
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.xl)
            
            Button {
                Task {
                    await viewModel.loadTrips()
                }
            } label: {
                HStack(spacing: AppTheme.Spacing.xxs) {
                    Image(systemName: "arrow.clockwise")
                    Text("RETRY")
                        .font(AppTheme.Typography.button())
                        .tracking(1)
                }
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
}

// MARK: - Trip Card
struct TripCard: View {
    let trip: Trip
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            // Trip header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                    Text(trip.destination)
                        .font(AppTheme.Typography.serifMedium())
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text(trip.dateRange)
                        .font(AppTheme.Typography.monoSmall())
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.primary.opacity(0.5))
            }
            
            // Trip notes preview (if available)
            if let notes = trip.notes, !notes.isEmpty {
                Text(notes)
                    .font(AppTheme.Typography.bodySmall())
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .lineLimit(2)
                    .padding(.top, AppTheme.Spacing.xxs)
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
        )
    }
}

#Preview {
    JournalView()
}
