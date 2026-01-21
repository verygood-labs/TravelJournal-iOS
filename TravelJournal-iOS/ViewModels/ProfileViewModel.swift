import Foundation
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var userStats: UserStats?
    
    func loadUserProfile() async {
        // TODO: Replace with actual service call
        // Simulate loading
        try? await Task.sleep(for: .seconds(0.5))
        
        // Mock data - replace with actual API call
        let now = Date()
        userProfile = UserProfile(
            userId: UUID(),
            email: "explorer@example.com",
            userName: "explorer",
            name: "Travel Explorer",
            bio: nil,
            profilePictureUrl: nil,
            nationality: nil,
            preferredLanguage: "en",
            preferredCurrency: "USD",
            createdAt: now.addingTimeInterval(-86400 * 365),
            updatedAt: now
        )
        
        // Mock statistics - replace with actual API call
        userStats = UserStats(
            totalTrips: 25,
            totalEntries: 47,
            countriesVisited: 12,
            totalPhotos: 125,
            totalDistance: 50000
        )
    }
}

