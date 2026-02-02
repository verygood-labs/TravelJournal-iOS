import Combine
import Foundation
import MapKit

@MainActor
class MapViewModel: ObservableObject {
    @Published var visitedLocations: [VisitedLocation] = []
    @Published var isLoading = false
    @Published var error: String?

    var countriesCount: Int {
        Set(visitedLocations.map { $0.countryCode }).count
    }

    var tripsCount: Int {
        // TODO: Get actual trip count from service
        visitedLocations.count
    }

    var locationsCount: Int {
        visitedLocations.count
    }

    func loadVisitedLocations() async {
        isLoading = true
        error = nil

        do {
            // TODO: Replace with actual service call
            // For now, simulate loading with mock data
            try await Task.sleep(for: .seconds(1))

            // Mock data - replace with actual API call
            visitedLocations = [
                VisitedLocation(
                    name: "Paris",
                    coordinate: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
                    countryCode: "FR"
                ),
                VisitedLocation(
                    name: "Tokyo",
                    coordinate: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503),
                    countryCode: "JP"
                ),
                VisitedLocation(
                    name: "New York",
                    coordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
                    countryCode: "US"
                ),
            ]

            isLoading = false
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }
}
