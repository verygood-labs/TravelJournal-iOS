import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    
    @State private var profile: UserProfile?
    @State private var stats: UserStats?
    @State private var isLoading = true
    @State private var showingEditProfile = false
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                // Profile header
                Section {
                    HStack(spacing: 16) {
                        Circle()
                            .fill(Color(.systemGray4))
                            .frame(width: 70, height: 70)
                            .overlay {
                                Text(profile?.displayName.prefix(1).uppercased() ?? "?")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(profile?.displayName ?? "Loading...")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text(profile?.email ?? "")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Stats
                if let stats = stats {
                    Section("Travel Stats") {
                        StatRow(icon: "map", title: "Total Trips", value: "\(stats.totalTrips)")
                        StatRow(icon: "globe", title: "Countries Visited", value: "\(stats.totalCountries)")
                        StatRow(icon: "building.2", title: "Cities Explored", value: "\(stats.totalCities)")
                    }
                }
                
                // Settings
                Section("Settings") {
                    Button {
                        showingEditProfile = true
                    } label: {
                        Label("Edit Profile", systemImage: "person.circle")
                    }
                    
                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        Label("Notifications", systemImage: "bell")
                    }
                    
                    NavigationLink {
                        PrivacySettingsView()
                    } label: {
                        Label("Privacy", systemImage: "lock")
                    }
                }
                
                // About
                Section("About") {
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("About Travel Journal", systemImage: "info.circle")
                    }
                    
                    Link(destination: URL(string: "https://traveljournal.app/help")!) {
                        Label("Help & Support", systemImage: "questionmark.circle")
                    }
                }
                
                // Logout
                Section {
                    Button(role: .destructive) {
                        showingLogoutAlert = true
                    } label: {
                        Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Profile")
            .refreshable {
                await loadProfile()
            }
            .task {
                await loadProfile()
            }
            .sheet(isPresented: $showingEditProfile) {
                if let profile = profile {
                    EditProfileView(profile: profile)
                }
            }
            .alert("Log Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Log Out", role: .destructive) {
                    Task {
                        await authManager.logout()
                    }
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }
    
    private func loadProfile() async {
        isLoading = true
        
        do {
            async let profileTask = ProfileService.shared.getProfile()
            async let statsTask = ProfileService.shared.getStats()
            
            let (userProfile, userStats) = try await (profileTask, statsTask)
            profile = userProfile
            stats = userStats
        } catch {
            print("Failed to load profile: \(error)")
        }
        
        isLoading = false
    }
}

struct StatRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
        }
    }
}

// Placeholder views
struct NotificationSettingsView: View {
    var body: some View {
        Text("Notification Settings")
            .navigationTitle("Notifications")
    }
}

struct PrivacySettingsView: View {
    var body: some View {
        Text("Privacy Settings")
            .navigationTitle("Privacy")
    }
}

struct AboutView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("About")
    }
}

struct EditProfileView: View {
    let profile: UserProfile
    
    @Environment(\.dismiss) var dismiss
    
    @State private var displayName: String
    @State private var bio: String
    @State private var isLoading = false
    
    init(profile: UserProfile) {
        self.profile = profile
        _displayName = State(initialValue: profile.displayName)
        _bio = State(initialValue: profile.bio ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Display Name", text: $displayName)
                }
                
                Section("Bio") {
                    TextEditor(text: $bio)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await saveProfile()
                        }
                    }
                    .disabled(displayName.isEmpty || isLoading)
                }
            }
        }
    }
    
    private func saveProfile() async {
        isLoading = true
        
        do {
            _ = try await ProfileService.shared.updateProfile(
                displayName: displayName,
                bio: bio.isEmpty ? nil : bio
            )
            dismiss()
        } catch {
            print("Failed to save profile: \(error)")
        }
        
        isLoading = false
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthManager())
}