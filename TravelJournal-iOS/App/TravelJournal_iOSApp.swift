import SwiftUI

@main
struct TravelJournal_iOSApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var toastManager = ToastManager()

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(authManager)
                    .environmentObject(toastManager)

                // Toast overlay on top of everything
                if let toast = toastManager.currentToast {
                    VStack {
                        ToastView(toast: toast) {
                            toastManager.dismiss()
                        }
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .padding(.top, AppTheme.Spacing.xl)
                        .transition(.move(edge: .top).combined(with: .opacity))

                        Spacer()
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: toastManager.currentToast?.id)
                    .zIndex(999)
                }
            }
        }
    }
}
