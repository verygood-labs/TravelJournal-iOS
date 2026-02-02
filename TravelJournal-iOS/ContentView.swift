import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var toastManager: ToastManager

    /// Track if this is a new user (for different toast message)
    @State private var wasAuthenticated = false

    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainTabView()
            } else {
                SplashView()
            }
        }
        .onChange(of: authManager.isAuthenticated) { oldValue, newValue in
            if newValue && !oldValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    toastManager.success("Welcome back!")
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
        .environmentObject(ToastManager())
}
