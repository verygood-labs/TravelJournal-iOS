import Combine
import Foundation

@MainActor
class JournalViewModel: ObservableObject {
    @Published var trips: [Trip] = []
    @Published var isLoading = false
    @Published var error: String?

    private let tripService = TripService.shared
    private var currentPage = 1
    private var hasMorePages = true

    func loadTrips() async {
        isLoading = true
        error = nil
        currentPage = 1

        do {
            let response = try await tripService.getTrips(page: currentPage, pageSize: 20)
            trips = response.items
            hasMorePages = response.hasNextPage
            isLoading = false
        } catch let apiError as APIError {
            self.error = apiError.localizedDescription
            isLoading = false
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }

    func loadMoreTripsIfNeeded(currentTrip: Trip) async {
        // Check if we're near the end of the list
        guard let index = trips.firstIndex(where: { $0.id == currentTrip.id }),
              index >= trips.count - 3,
              hasMorePages,
              !isLoading
        else {
            return
        }

        currentPage += 1

        do {
            let response = try await tripService.getTrips(page: currentPage, pageSize: 20)
            trips.append(contentsOf: response.items)
            hasMorePages = response.hasNextPage
        } catch {
            print("Failed to load more trips: \(error)")
            currentPage -= 1
        }
    }

    func addTrip(_ trip: Trip) async {
        // Note: This is for local additions. For API, use createTrip
        trips.insert(trip, at: 0)
    }

    func createTrip(title: String, description: String?, startDate: Date?, endDate: Date?) async -> Bool {
        do {
            let newTrip = try await tripService.createTrip(
                title: title,
                description: description,
                startDate: startDate,
                endDate: endDate
            )
            trips.insert(newTrip, at: 0)
            return true
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }

    func deleteTrip(_ trip: Trip) async -> Bool {
        do {
            try await tripService.deleteTrip(id: trip.id)
            trips.removeAll { $0.id == trip.id }
            return true
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }
}
