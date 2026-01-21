import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Passport Tab
            PassportHomeView()
                .tabItem {
                    Label("Passport", systemImage: "book.closed.fill")
                }
                .tag(0)
            
            // Map Tab
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
                .tag(1)
            
            // Journal Tab
            JournalView()
                .tabItem {
                    Label("Journal", systemImage: "book.pages.fill")
                }
                .tag(2)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .tint(AppTheme.Colors.primary)
    }
}

#Preview {
    MainTabView()
}
