import SwiftUI

struct TripsView: View {
    @State private var trips: [Trip] = []
    @State private var isLoading = true
    @State private var currentPage = 1
    @State private var hasMorePages = true
    @State private var showingCreateTrip = false
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading && trips.isEmpty {
                    ProgressView()
                } else if trips.isEmpty {
                    ContentUnavailableView {
                        Label("No Trips", systemImage: "map")
                    } description: {
                        Text("Create your first trip to get started")
                    } actions: {
                        Button("Create Trip") {
                            showingCreateTrip = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach(trips) { trip in
                            NavigationLink {
                                TripDetailView(trip: trip)
                            } label: {
                                TripRowView(trip: trip)
                            }
                        }
                        .onDelete(perform: deleteTrips)
                        
                        if hasMorePages {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .onAppear {
                                    Task {
                                        await loadMoreTrips()
                                    }
                                }
                        }
                    }
                }
            }
            .navigationTitle("My Trips")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingCreateTrip = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .refreshable {
                await refreshTrips()
            }
            .task {
                if trips.isEmpty {
                    await loadTrips()
                }
            }
            .sheet(isPresented: $showingCreateTrip) {
                CreateTripView()
            }
        }
    }
    
    private func loadTrips() async {
        isLoading = true
        currentPage = 1
        
        do {
            let response = try await TripService.shared.getTrips(page: 1)
            trips = response.items
            hasMorePages = response.hasNextPage
        } catch {
            print("Failed to load trips: \(error)")
        }
        
        isLoading = false
    }
    
    private func loadMoreTrips() async {
        guard hasMorePages else { return }
        
        currentPage += 1
        
        do {
            let response = try await TripService.shared.getTrips(page: currentPage)
            trips.append(contentsOf: response.items)
            hasMorePages = response.hasNextPage
        } catch {
            print("Failed to load more trips: \(error)")
            currentPage -= 1
        }
    }
    
    private func refreshTrips() async {
        await loadTrips()
    }
    
    private func deleteTrips(at offsets: IndexSet) {
        let tripsToDelete = offsets.map { trips[$0] }
        
        Task {
            for trip in tripsToDelete {
                do {
                    try await TripService.shared.deleteTrip(id: trip.id)
                    if let index = trips.firstIndex(where: { $0.id == trip.id }) {
                        trips.remove(at: index)
                    }
                } catch {
                    print("Failed to delete trip: \(error)")
                }
            }
        }
    }
}

struct TripRowView: View {
    let trip: Trip
    
    var body: some View {
        HStack(spacing: 12) {
            // Cover image placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
                .frame(width: 60, height: 60)
                .overlay {
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(trip.title)
                    .font(.headline)
                
                if let description = trip.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                HStack {
                    StatusBadge(status: trip.status)
                    
                    if let startDate = trip.startDate {
                        Text(startDate, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatusBadge: View {
    let status: TripStatus
    
    var color: Color {
        switch status {
        case .draft: return .orange
        case .private: return .gray
        case .public: return .green
        }
    }
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .cornerRadius(4)
    }
}

#Preview {
    TripsView()
}