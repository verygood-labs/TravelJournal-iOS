import SwiftUI

struct ExploreView: View {
    @State private var searchText = ""
    @State private var places: [Place] = []
    @State private var isSearching = false
    
    var body: some View {
        NavigationStack {
            Group {
                if places.isEmpty && searchText.isEmpty {
                    ContentUnavailableView {
                        Label("Search Places", systemImage: "magnifyingglass")
                    } description: {
                        Text("Search for places to add to your trips")
                    }
                } else if places.isEmpty && !searchText.isEmpty && !isSearching {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List(places) { place in
                        PlaceRowView(place: place)
                    }
                }
            }
            .navigationTitle("Explore")
            .searchable(text: $searchText, prompt: "Search places...")
            .onChange(of: searchText) { _, newValue in
                Task {
                    await search(query: newValue)
                }
            }
        }
    }
    
    private func search(query: String) async {
        guard !query.isEmpty else {
            places = []
            return
        }
        
        // Debounce
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        guard query == searchText else { return }
        
        isSearching = true
        
        do {
            places = try await PlaceService.shared.search(query: query)
        } catch {
            print("Search failed: \(error)")
        }
        
        isSearching = false
    }
}

struct PlaceRowView: View {
    let place: Place
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(place.name)
                .font(.headline)
            
            Text(place.displayName)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            
            if let country = place.country {
                HStack {
                    Image(systemName: "mappin.circle")
                    Text(country)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ExploreView()
}