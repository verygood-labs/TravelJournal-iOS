import SwiftUI

@main
struct TravelJournal_iOSApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var toastManager = ToastManager()  // Add this
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(toastManager)  // Add this
                .toastOverlay(manager: toastManager)  // Add this
        }
    }
}
