import Combine
import Foundation

@MainActor
class JournalViewModel: ObservableObject {
    @Published var trips: [TripSummary] = []
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

    func loadMoreTripsIfNeeded(currentTrip: TripSummary) async {
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

    func deleteTrip(_ trip: TripSummary) async -> Bool {
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
