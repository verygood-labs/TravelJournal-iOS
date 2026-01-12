import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var recentTrips: [Trip] = []
    @State private var stats: UserStats?
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Welcome header
                    if let user = authManager.currentUser {
                        Text("Welcome back, \(user.displayName)!")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    // Stats cards
                    if let stats = stats {
                        StatsSection(stats: stats)
                    }
                    
                    // Recent trips
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recent Trips")
                                .font(.headline)
                            Spacer()
                            NavigationLink("See All") {
                                TripsView()
                            }
                            .font(.subheadline)
                        }
                        
                        if recentTrips.isEmpty && !isLoading {
                            EmptyTripsView()
                        } else {
                            ForEach(recentTrips) { trip in
                                NavigationLink {
                                    TripDetailView(trip: trip)
                                } label: {
                                    TripCardView(trip: trip)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Home")
            .refreshable {
                await loadData()
            }
            .task {
                await loadData()
            }
        }
    }
    
    private func loadData() async {
        isLoading = true
        
        do {
            async let tripsTask = TripService.shared.getTrips(page: 1, pageSize: 5)
            async let statsTask = ProfileService.shared.getStats()
            
            let (tripsResponse, userStats) = try await (tripsTask, statsTask)
            recentTrips = tripsResponse.items
            stats = userStats
        } catch {
            print("Failed to load data: \(error)")
        }
        
        isLoading = false
    }
}

struct StatsSection: View {
    let stats: UserStats
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            StatCard(title: "Trips", value: "\(stats.totalTrips)", icon: "map")
            StatCard(title: "Countries", value: "\(stats.totalCountries)", icon: "globe")
            StatCard(title: "Cities", value: "\(stats.totalCities)", icon: "building.2")
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct EmptyTripsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "map")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            
            Text("No trips yet")
                .font(.headline)
            
            Text("Start documenting your adventures!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            NavigationLink {
                CreateTripView()
            } label: {
                Text("Create Your First Trip")
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthManager())
}