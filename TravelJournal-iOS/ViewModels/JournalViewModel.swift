import Foundation
import Combine

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
            let now = Date()
            trips = [
                Trip(
                    id: UUID(),
                    title: "Paris, France",
                    description: "An amazing week exploring the city of lights. Visited the Eiffel Tower, Louvre, and countless cafés.",
                    coverImageUrl: nil,
                    status: .public,
                    startDate: now.addingTimeInterval(-86400 * 30),
                    endDate: now.addingTimeInterval(-86400 * 23),
                    createdAt: now.addingTimeInterval(-86400 * 30),
                    updatedAt: now.addingTimeInterval(-86400 * 23),
                    stops: nil
                ),
                Trip(
                    id: UUID(),
                    title: "Tokyo, Japan",
                    description: "Incredible cultural experience with amazing food and hospitality.",
                    coverImageUrl: nil,
                    status: .public,
                    startDate: now.addingTimeInterval(-86400 * 90),
                    endDate: now.addingTimeInterval(-86400 * 80),
                    createdAt: now.addingTimeInterval(-86400 * 90),
                    updatedAt: now.addingTimeInterval(-86400 * 80),
                    stops: nil
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

