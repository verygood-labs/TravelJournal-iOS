import Combine
import Foundation
import SwiftUI

@MainActor
final class PassportHomeViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var userProfile: UserProfile?
    @Published var userStats: UserStats?
    @Published var countryStamps: [CountryStamp] = []
    @Published var isLoadingStamps = false
    @Published var isLoadingProfile = false
    @Published var isLoadingStats = false
    @Published var showingAddTrip = false
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

    var dateIssued: String {
        guard let createdAt = userProfile?.createdAt else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: createdAt)
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

    var isPreview = false

    // MARK: - Methods

    func loadData() async {
        await loadProfile()
        await loadStats()
        await loadCountryStamps()
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

    private func loadCountryStamps() async {
        isLoadingStamps = true

        do {
            let response = try await profileService.getCountryStamps()
            countryStamps = response.countryStamps
        } catch {
            print("Country stamps load error: \(error)")
        }

        isLoadingStamps = false
    }

    func refresh() async {
        await loadData()
    }
}
