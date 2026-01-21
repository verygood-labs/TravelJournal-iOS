import Foundation

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: UserProfile?
    @Published var countriesVisited = 0
    @Published var totalTrips = 0
    @Published var placesVisited = 0
    
    func loadUserProfile() async {
        // TODO: Replace with actual service call
        // Simulate loading
        try? await Task.sleep(for: .seconds(0.5))
        
        // Mock data - replace with actual API call
        user = UserProfile(
            id: UUID().uuidString,
            fullName: "Travel Explorer",
            email: "explorer@example.com",
            joinDate: Date().addingTimeInterval(-86400 * 365)
        )
        
        // Mock statistics - replace with actual API call
        countriesVisited = 12
        totalTrips = 25
        placesVisited = 47
    }
}

// MARK: - User Profile Model
struct UserProfile: Identifiable, Codable {
    let id: String
    let fullName: String
    let email: String
    let joinDate: Date
    
    var memberSince: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: joinDate)
    }
}
