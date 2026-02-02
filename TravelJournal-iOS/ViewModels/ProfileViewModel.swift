import Combine
import Foundation
import SwiftUI

// MARK: - Profile View Model

/// Handles all state and logic for the Profile/Settings screen
@MainActor
final class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties

    // User Profile Data
    @Published var userProfile: UserProfile?
    @Published var isLoadingProfile = false

    // Preferences
    @Published var selectedCurrency: Currency = .usd
    @Published var selectedDistanceUnit: DistanceUnit = .miles

    // Sheet States
    @Published var showingCurrencyPicker = false
    @Published var showingDistanceUnitPicker = false

    // Alert States
    @Published var showingLogoutAlert = false
    @Published var showingDeleteAccountAlert = false
    @Published var showingDeleteConfirmation = false
    @Published var deleteConfirmationText = ""

    // Loading States
    @Published var isLoggingOut = false
    @Published var isDeletingAccount = false

    /// Error State
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

    var email: String {
        userProfile?.email ?? ""
    }

    var nationalityName: String {
        userProfile?.nationality?.name ?? "Not set"
    }

    var profileImageUrl: URL? {
        APIService.shared.fullMediaURL(for: userProfile?.profilePictureUrl)
    }

    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "v\(version) (Build \(build))"
    }

    var canDeleteAccount: Bool {
        deleteConfirmationText.uppercased() == "DELETE"
    }

    // MARK: - Initialization

    init() {
        loadSavedPreferences()
    }

    // MARK: - Data Loading

    func loadProfile() async {
        isLoadingProfile = true
        error = nil

        do {
            userProfile = try await profileService.getProfile()
        } catch {
            self.error = "Failed to load profile"
            print("Profile load error: \(error)")
        }

        isLoadingProfile = false
    }

    // MARK: - Preferences

    private func loadSavedPreferences() {
        // Load from UserDefaults
        if let currencyRaw = UserDefaults.standard.string(forKey: "selectedCurrency"),
           let currency = Currency(rawValue: currencyRaw)
        {
            selectedCurrency = currency
        }

        if let unitRaw = UserDefaults.standard.string(forKey: "selectedDistanceUnit"),
           let unit = DistanceUnit(rawValue: unitRaw)
        {
            selectedDistanceUnit = unit
        }
    }

    func updateCurrency(_ currency: Currency) {
        selectedCurrency = currency
        UserDefaults.standard.set(currency.rawValue, forKey: "selectedCurrency")
        showingCurrencyPicker = false
    }

    func updateDistanceUnit(_ unit: DistanceUnit) {
        selectedDistanceUnit = unit
        UserDefaults.standard.set(unit.rawValue, forKey: "selectedDistanceUnit")
        showingDistanceUnitPicker = false
    }

    // MARK: - Account Actions

    func logout() async {
        isLoggingOut = true
        // Actual logout is handled by AuthManager in the view
        // This is just for loading state
        try? await Task.sleep(for: .milliseconds(500))
        isLoggingOut = false
    }

    func deleteAccount() async {
        guard canDeleteAccount else { return }

        isDeletingAccount = true
        error = nil

        // TODO: Implement actual account deletion API call
        // For now, just simulate
        do {
            try await Task.sleep(for: .seconds(1))
            // After successful deletion, logout will be triggered
        } catch {
            self.error = "Failed to delete account"
        }

        isDeletingAccount = false
    }

    func resetDeleteConfirmation() {
        deleteConfirmationText = ""
        showingDeleteConfirmation = false
    }
}

// MARK: - Currency Enum

enum Currency: String, CaseIterable, Identifiable {
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case jpy = "JPY"
    case cad = "CAD"
    case aud = "AUD"
    case chf = "CHF"
    case cny = "CNY"
    case inr = "INR"
    case mxn = "MXN"
    case brl = "BRL"
    case krw = "KRW"

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .usd: return "USD ($)"
        case .eur: return "EUR (€)"
        case .gbp: return "GBP (£)"
        case .jpy: return "JPY (¥)"
        case .cad: return "CAD ($)"
        case .aud: return "AUD ($)"
        case .chf: return "CHF (Fr)"
        case .cny: return "CNY (¥)"
        case .inr: return "INR (₹)"
        case .mxn: return "MXN ($)"
        case .brl: return "BRL (R$)"
        case .krw: return "KRW (₩)"
        }
    }

    var symbol: String {
        switch self {
        case .usd, .cad, .aud, .mxn: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .jpy, .cny: return "¥"
        case .chf: return "Fr"
        case .inr: return "₹"
        case .brl: return "R$"
        case .krw: return "₩"
        }
    }
}

// MARK: - Distance Unit Enum

enum DistanceUnit: String, CaseIterable, Identifiable {
    case miles
    case kilometers

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .miles: return "Miles"
        case .kilometers: return "Kilometers"
        }
    }

    var abbreviation: String {
        switch self {
        case .miles: return "mi"
        case .kilometers: return "km"
        }
    }
}
