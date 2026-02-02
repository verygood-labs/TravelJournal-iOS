import Combine
import Foundation
import SwiftUI

/// ViewModel for the multi-step registration flow
/// Handles all registration business logic, state management, and API calls
@MainActor
final class RegistrationViewModel: ObservableObject {
    private let authManager: AuthManager

    // MARK: - Step 1: Account Credentials (passed from previous view)

    let email: String
    let password: String

    // MARK: - Step 2: Traveler Details

    @Published var fullName = ""
    @Published var username = ""
    @Published var selectedCountry: PlaceSummaryDTO? = nil

    // MARK: - Username Validation

    @Published var isCheckingUsername = false
    @Published var usernameError: String? = nil
    @Published var isUsernameAvailable: Bool? = nil
    private var lastCheckedUsername: String = ""

    // MARK: - Country Selection

    @Published var allCountries: [PlaceSummaryDTO] = []
    @Published var isLoadingCountries = false
    @Published var countrySearchText = ""
    @Published var showCountryDropdown = false

    // MARK: - Step 3: Passport Photo

    @Published var selectedImage: UIImage? = nil

    // MARK: - Navigation State

    @Published var showingPassportPhoto = false
    @Published var showingPassportPreview = false
    @Published var showingPassportIssued = false

    // MARK: - Submission State

    @Published var isSubmitting = false
    @Published var registrationError: String? = nil

    // MARK: - Computed Properties

    var currentStep: Int {
        if showingPassportPreview {
            return 4
        } else if showingPassportPhoto {
            return 3
        } else {
            return 2
        }
    }

    var isFormValid: Bool {
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty &&
            !username.trimmingCharacters(in: .whitespaces).isEmpty &&
            isValidUsername(username) &&
            isUsernameAvailable == true &&
            selectedCountry != nil
    }

    var hasPhoto: Bool {
        selectedImage != nil
    }

    var isContinueDisabled: Bool {
        if isSubmitting { return true }
        if showingPassportPreview { return false }
        if showingPassportPhoto { return !hasPhoto }
        return !isFormValid
    }

    var filteredCountries: [PlaceSummaryDTO] {
        let trimmed = countrySearchText.trimmingCharacters(in: .whitespaces).lowercased()
        if trimmed.isEmpty {
            return allCountries
        }
        return allCountries.filter { $0.name.lowercased().contains(trimmed) }
    }

    // MARK: - Initialization

    init(email: String, password: String, authManager: AuthManager) {
        self.email = email
        self.password = password
        self.authManager = authManager
    }

    // MARK: - Validation

    func isValidUsername(_ username: String) -> Bool {
        let pattern = "^[a-zA-Z0-9_]+$"
        return username.range(of: pattern, options: .regularExpression) != nil
    }

    func onUsernameChanged() {
        usernameError = nil
        isUsernameAvailable = nil
    }

    // MARK: - API Calls

    func loadCountries() async {
        guard allCountries.isEmpty else { return }

        isLoadingCountries = true

        do {
            let countries = try await PlaceService.shared.getAllCountries()
            allCountries = countries.sorted { $0.name < $1.name }
        } catch {
            print("Failed to load countries: \(error)")
        }

        isLoadingCountries = false
    }

    func checkUsernameAvailability() async {
        let trimmedUsername = username.trimmingCharacters(in: .whitespaces)
        guard !trimmedUsername.isEmpty else { return }
        guard isValidUsername(trimmedUsername) else { return }
        guard trimmedUsername != lastCheckedUsername else { return }

        isCheckingUsername = true
        usernameError = nil
        isUsernameAvailable = nil

        do {
            let response = try await AuthService.shared.checkUsername(userName: trimmedUsername)
            lastCheckedUsername = trimmedUsername

            if response.available {
                isUsernameAvailable = true
            } else {
                isUsernameAvailable = false
                usernameError = response.message ?? "This username is already taken."
            }
        } catch {
            isUsernameAvailable = nil
            usernameError = "Unable to verify username. Please try again."
        }

        isCheckingUsername = false
    }

    func submitRegistration() async {
        guard let country = selectedCountry else { return }

        isSubmitting = true
        registrationError = nil

        do {
            let response = try await AuthService.shared.register(
                email: email,
                password: password,
                name: fullName.trimmingCharacters(in: .whitespaces),
                userName: username.trimmingCharacters(in: .whitespaces),
                nationalityId: country.id,
                profilePicture: selectedImage
            )

            // Update AuthManager with the response
            authManager.currentUser = response.user
            authManager.isAuthenticated = true

            showingPassportIssued = true
        } catch let error as APIError {
            registrationError = error.userMessage
            print("Registration failed: \(error)")
        } catch {
            registrationError = "Registration failed. Please try again."
            print("Registration failed: \(error)")
        }

        isSubmitting = false
    }

    // MARK: - Navigation

    func handleBack() -> Bool {
        if showingPassportPreview {
            showingPassportPreview = false
            return false
        } else if showingPassportPhoto {
            showingPassportPhoto = false
            return false
        } else {
            // Signal to dismiss the view
            return true
        }
    }

    func handleContinue() async {
        if showingPassportPreview {
            await submitRegistration()
        } else if showingPassportPhoto {
            proceedFromPhotoStep()
        } else {
            await proceedToNextStep()
        }
    }

    private func proceedFromPhotoStep() {
        guard hasPhoto else { return }
        showingPassportPreview = true
    }

    private func proceedToNextStep() async {
        guard let country = selectedCountry else { return }
        print("Selected country: \(country.name) with ID: \(country.id)")
        showingPassportPhoto = true
    }

    // MARK: - Country Selection

    func selectCountry(_ country: PlaceSummaryDTO) {
        selectedCountry = country
        countrySearchText = ""
        showCountryDropdown = false
    }

    func clearSelectedCountry() {
        selectedCountry = nil
        countrySearchText = ""
    }
}

// MARK: - APIError Extension

extension APIError {
    var userMessage: String {
        switch self {
        case .networkError:
            return "Network error. Please check your connection."
        case .unauthorized:
            return "Session expired. Please try again."
        case let .validationError(errors):
            // Return first validation error message
            if let firstError = errors.values.first?.first {
                return firstError
            }
            return "Please check your information and try again."
        case let .serverError(message):
            return message
        default:
            return "Something went wrong. Please try again."
        }
    }
}
