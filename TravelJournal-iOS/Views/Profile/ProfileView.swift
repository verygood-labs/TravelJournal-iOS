import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                // User Profile Section
                Section {
                    if let user = viewModel.userProfile {
                        userInfoRow(label: "Name", value: user.name)
                        userInfoRow(label: "Email", value: user.email)
                        userInfoRow(label: "Member Since", value: user.memberSince)
                    } else {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                
                // Statistics Section
                Section("Travel Statistics") {
                    if let stats = viewModel.userStats {
                        statisticRow(icon: "globe.americas.fill", label: "Countries Visited", value: "\(stats.countriesVisited)")
                        statisticRow(icon: "airplane", label: "Total Trips", value: "\(stats.totalTrips)")
                        statisticRow(icon: "mappin.and.ellipse", label: "Places Visited", value: "\(stats.totalEntries)")
                    } else {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                
                // Settings Section
                Section("Settings") {
                    NavigationLink {
                        Text("Edit Profile")
                            .navigationTitle("Edit Profile")
                    } label: {
                        settingRow(icon: "person.fill", label: "Edit Profile")
                    }
                    
                    NavigationLink {
                        Text("Notifications")
                            .navigationTitle("Notifications")
                    } label: {
                        settingRow(icon: "bell.fill", label: "Notifications")
                    }
                    
                    NavigationLink {
                        Text("Privacy")
                            .navigationTitle("Privacy")
                    } label: {
                        settingRow(icon: "lock.fill", label: "Privacy")
                    }
                }
                
                // Account Section
                Section {
                    Button(role: .destructive) {
                        showingLogoutAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Log Out")
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .task {
                await viewModel.loadUserProfile()
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
    
    // MARK: - Helper Views
    private func userInfoRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.textSecondary)
            Text(value)
                .font(AppTheme.Typography.monoMedium())
                .foregroundColor(AppTheme.Colors.textPrimary)
        }
        .padding(.vertical, 4)
    }
    
    private func statisticRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(AppTheme.Colors.primary)
                .frame(width: 24)
            
            Text(label)
                .font(AppTheme.Typography.monoMedium())
            
            Spacer()
            
            Text(value)
                .font(AppTheme.Typography.serifSmall())
                .foregroundColor(AppTheme.Colors.primary)
        }
    }
    
    private func settingRow(icon: String, label: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(AppTheme.Colors.primary)
                .frame(width: 24)
            
            Text(label)
                .font(AppTheme.Typography.monoMedium())
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthManager())
}
