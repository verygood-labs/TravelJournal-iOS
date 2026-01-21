import Foundation

@MainActor
class JournalViewModel: ObservableObject {
    @Published var trips: [Trip] = []
    @Published var isLoading = false
    @Published var error: String?
    
    func loadTrips() async {
        isLoading = true
        error = nil
        
        do {
            // TODO: Replace with actual service call
            // For now, simulate loading with mock data
            try await Task.sleep(for: .seconds(1))
            
            // Mock data - replace with actual API call
            trips = [
                Trip(
                    id: UUID().uuidString,
                    destination: "Paris, France",
                    startDate: Date().addingTimeInterval(-86400 * 30),
                    endDate: Date().addingTimeInterval(-86400 * 23),
                    notes: "An amazing week exploring the city of lights. Visited the Eiffel Tower, Louvre, and countless cafés."
                ),
                Trip(
                    id: UUID().uuidString,
                    destination: "Tokyo, Japan",
                    startDate: Date().addingTimeInterval(-86400 * 90),
                    endDate: Date().addingTimeInterval(-86400 * 80),
                    notes: "Incredible cultural experience with amazing food and hospitality."
                )
            ]
            
            isLoading = false
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }
    
    func addTrip(_ trip: Trip) async {
        // TODO: Add trip through service
        trips.insert(trip, at: 0)
    }
}

// MARK: - Trip Model
struct Trip: Identifiable, Codable {
    let id: String
    let destination: String
    let startDate: Date
    let endDate: Date
    let notes: String?
    
    var dateRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        let startString = formatter.string(from: startDate)
        let endString = formatter.string(from: endDate)
        
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        let year = yearFormatter.string(from: endDate)
        
        return "\(startString) - \(endString), \(year)"
    }
}
