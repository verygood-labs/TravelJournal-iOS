import SwiftUI

// MARK: - Settings Divider
/// Divider used between settings rows, indented to align with text after icon
struct SettingsDivider: View {
    var body: some View {
        Divider()
            .background(AppTheme.Colors.backgroundDark)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        AppTheme.Colors.cardBackground
        
        VStack(spacing: 0) {
            Text("Row 1")
                .padding()
            SettingsDivider()
            Text("Row 2")
                .padding()
        }
    }
    .frame(height: 150)
}
