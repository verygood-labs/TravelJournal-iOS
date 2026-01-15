import Foundation
import SwiftUI
import Combine

@MainActor
final class PassportHomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var userProfile: UserProfile?
    @Published var userStats: UserStats?
    @Published var isLoadingProfile = false
    @Published var isLoadingStats = false
    @Published var error: String?
    
    // MARK: - Services
    private let profileService = ProfileService.shared
    
    // MARK: - Computed Properties
    var displayName: String {
        userProfile?.name ?? "Traveler"
    }
    
    var username: String {
        userProfile?.userName ?? ""
    }
    
    var profileImageUrl: URL? {
        APIService.shared.fullMediaURL(for: userProfile?.profilePictureUrl)
    }

    var nationalityName: String {
    userProfile?.nationality?.name ?? "Unknown"
    }

    var countryCode: String? {
        userProfile?.nationality?.countryCode
    }
    
    var countriesCount: Int {
        userStats?.countriesVisited ?? 0
    }
    
    var entriesCount: Int {
        userStats?.totalEntries ?? 0
    }
    
    var tripsCount: Int {
        userStats?.totalTrips ?? 0
    }
    
    // MARK: - Methods
    
    func loadData() async {
        await loadProfile()
        await loadStats()
    }
    
    private func loadProfile() async {
        isLoadingProfile = true
        error = nil
        
        do {
            userProfile = try await profileService.getProfile()
        } catch {
            self.error = "Failed to load profile: \(error.localizedDescription)"
            print("Profile load error: \(error)")
        }
        
        isLoadingProfile = false
    }
    
    private func loadStats() async {
        isLoadingStats = true
        
        do {
            userStats = try await profileService.getStats()
        } catch {
            print("Stats load error: \(error)")
            // Don't set error here, stats are less critical
        }
        
        isLoadingStats = false
    }
    
    func refresh() async {
        await loadData()
    }
}
