import Foundation
import SwiftUI
import Combine

// MARK: - Edit Profile ViewModel
@MainActor
final class EditProfileViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    // Form fields
    @Published var name: String = ""
    @Published var username: String = ""
    @Published var selectedImage: UIImage? = nil
    @Published var selectedCountry: PlaceSummaryDTO? = nil
    
    // Country search
    @Published var countrySearchText: String = ""
    @Published var allCountries: [PlaceSummaryDTO] = []
    @Published var isLoadingCountries = false
    @Published var showCountryDropdown = false
    
    // Username validation
    @Published var isCheckingUsername = false
    @Published var isUsernameAvailable: Bool? = nil
    @Published var usernameError: String? = nil
    
    // State
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var error: String?
    @Published var saveSuccess = false
    
    // MARK: - Private Properties
    
    private var originalProfile: UserProfile?
    private var originalName: String = ""
    private var originalUsername: String = ""
    private var originalNationalityId: String?
    private let profileService = ProfileService.shared
    private let placeService = PlaceService.shared
    private var usernameCheckTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    var hasChanges: Bool {
        return name != originalName ||
               username != originalUsername ||
               selectedImage != nil ||
               selectedCountry?.id != originalNationalityId
    }
    
    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !username.trimmingCharacters(in: .whitespaces).isEmpty &&
        usernameError == nil &&
        !isSaving
    }
    
    var profileImageUrl: URL? {
        APIService.shared.fullMediaURL(for: originalProfile?.profilePictureUrl)
    }
    
    var filteredCountries: [PlaceSummaryDTO] {
        if countrySearchText.isEmpty {
            return allCountries
        }
        return allCountries.filter {
            $0.name.localizedCaseInsensitiveContains(countrySearchText)
        }
    }
    
    // Image picker state
    @Published var showingImagePicker = false
    @Published var showingCamera = false
    
    // MARK: - Initialization
    
    init(userProfile: UserProfile? = nil) {
        self.originalProfile = userProfile
        
        // Populate form with existing data if provided at init
        if let profile = userProfile {
            self.name = profile.name
            self.username = profile.userName
            self.originalName = profile.name
            self.originalUsername = profile.userName
            self.originalNationalityId = profile.nationality?.id
            
            if let nationality = profile.nationality {
                self.selectedCountry = PlaceSummaryDTO(
                    id: nationality.id,
                    name: nationality.name,
                    countryCode: nationality.countryCode
                )
            }
        }
        
        setupUsernameValidation()
    }
    
    /// Initialize the form with profile data (called from view's .task)
    func initialize(with profile: UserProfile) {
        // Only initialize if not already set
        guard name.isEmpty else { return }
        
        self.originalProfile = profile
        self.name = profile.name
        self.username = profile.userName
        self.originalName = profile.name
        self.originalUsername = profile.userName
        self.originalNationalityId = profile.nationality?.id
        
        if let nationality = profile.nationality {
            self.selectedCountry = PlaceSummaryDTO(
                id: nationality.id,
                name: nationality.name,
                countryCode: nationality.countryCode
            )
        }
    }
    
    // MARK: - Setup
    
    private func setupUsernameValidation() {
        $username
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] newUsername in
                guard let self = self else { return }
                
                // Skip if username hasn't changed from original
                if newUsername == self.originalProfile?.userName {
                    self.usernameError = nil
                    self.isUsernameAvailable = true
                    return
                }
                
                Task {
                    await self.validateUsername(newUsername)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    
    func loadCountries() async {
        guard allCountries.isEmpty else { return }
        
        isLoadingCountries = true
        
        do {
            allCountries = try await placeService.getAllCountries()
        } catch {
            print("Failed to load countries: \(error)")
        }
        
        isLoadingCountries = false
    }
    
    // MARK: - Validation
    
    private func validateUsername(_ username: String) async {
        let trimmed = username.trimmingCharacters(in: .whitespaces).lowercased()
        
        // Basic validation
        guard !trimmed.isEmpty else {
            usernameError = nil
            isUsernameAvailable = nil
            return
        }
        
        guard trimmed.count >= 3 else {
            usernameError = "Username must be at least 3 characters"
            isUsernameAvailable = false
            return
        }
        
        guard trimmed.count <= 30 else {
            usernameError = "Username must be 30 characters or less"
            isUsernameAvailable = false
            return
        }
        
        // Check for valid characters (alphanumeric and underscore only)
        let validCharacterSet = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
        guard trimmed.unicodeScalars.allSatisfy({ validCharacterSet.contains($0) }) else {
            usernameError = "Only letters, numbers, and underscores allowed"
            isUsernameAvailable = false
            return
        }
        
        // Check availability with API
        isCheckingUsername = true
        usernameError = nil
        
        do {
            let response = try await AuthService.shared.checkUsername(userName: trimmed)
            isUsernameAvailable = response.available
            if !response.available {
                usernameError = "This username is already taken"
            }
        } catch {
            isUsernameAvailable = nil
            usernameError = "Unable to verify username"
        }
        
        isCheckingUsername = false
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
    
    // MARK: - Save
    
    func saveProfile() async -> Bool {
        guard canSave else { return false }
        
        isSaving = true
        error = nil
        
        do {
            // TODO: Handle image upload if selectedImage is set
            // For now, just update text fields
            
            _ = try await profileService.updateProfile(
                name: name.trimmingCharacters(in: .whitespaces),
                nationalityId: selectedCountry?.id
            )
            
            saveSuccess = true
            isSaving = false
            return true
        } catch {
            self.error = "Failed to save profile. Please try again."
            print("Profile save error: \(error)")
            isSaving = false
            return false
        }
    }
}
