import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                PassportHomeView()
            } else {
                SplashView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}