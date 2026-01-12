import SwiftUI

struct TripDetailView: View {
    let trip: Trip
    
    @State private var fullTrip: Trip?
    @State private var isLoading = true
    
    var displayTrip: Trip {
        fullTrip ?? trip
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Cover image
                ZStack {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .aspectRatio(16/9, contentMode: .fit)
                    
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }
                .cornerRadius(12)
                
                // Trip info
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(displayTrip.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        StatusBadge(status: displayTrip.status)
                    }
                    
                    if let description = displayTrip.description {
                        Text(description)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Dates
                    if displayTrip.startDate != nil || displayTrip.endDate != nil {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundStyle(.secondary)
                            
                            if let start = displayTrip.startDate {
                                Text(start, style: .date)
                            }
                            
                            if displayTrip.startDate != nil && displayTrip.endDate != nil {
                                Text("-")
                            }
                            
                            if let end = displayTrip.endDate {
                                Text(end, style: .date)
                            }
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                }
                
                Divider()
                
                // Stops section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Stops")
                        .font(.headline)
                    
                    if let stops = displayTrip.stops, !stops.isEmpty {
                        ForEach(stops) { stop in
                            StopRowView(stop: stop)
                        }
                    } else {
                        Text("No stops added yet")
                            .foregroundStyle(.secondary)
                            .padding(.vertical)
                    }
                }
                
                Divider()
                
                // Actions
                VStack(spacing: 12) {
                    NavigationLink {
                        EditTripView(trip: displayTrip)
                    } label: {
                        Label("Edit Trip", systemImage: "pencil")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    NavigationLink {
                        TripJournalView(tripId: displayTrip.id)
                    } label: {
                        Label("View Journal", systemImage: "book")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadFullTrip()
        }
    }
    
    private func loadFullTrip() async {
        do {
            fullTrip = try await TripService.shared.getTrip(id: trip.id)
        } catch {
            print("Failed to load trip: \(error)")
        }
        isLoading = false
    }
}

struct StopRowView: View {
    let stop: TripStop
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.blue)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading) {
                Text(stop.placeName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let arrived = stop.arrivedAt {
                    Text(arrived, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationStack {
        TripDetailView(trip: Trip(
            id: UUID(),
            title: "Japan Adventure",
            description: "Two weeks exploring Tokyo, Kyoto, and Osaka",
            coverImageUrl: nil,
            status: .draft,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 14),
            createdAt: Date(),
            updatedAt: Date(),
            stops: []
        ))
    }
}