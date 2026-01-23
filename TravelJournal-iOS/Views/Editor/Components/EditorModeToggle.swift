import SwiftUI

struct EditorModeToggle: View {
    @Binding var selectedMode: EditorMode
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(EditorMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.easeInOut(duration: AppTheme.Animation.fast)) {
                        selectedMode = mode
                    }
                } label: {
                    Text(mode.rawValue.uppercased())
                        .font(AppTheme.Typography.monoSmall())
                        .tracking(1)
                        .fontWeight(selectedMode == mode ? .semibold : .regular)
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .padding(.vertical, AppTheme.Spacing.xxs)
                        .background(
                            selectedMode == mode
                                ? AppTheme.Colors.primary
                                : Color.clear
                        )
                        .foregroundColor(
                            selectedMode == mode
                                ? AppTheme.Colors.backgroundDark
                                : AppTheme.Colors.primary.opacity(0.6)
                        )
                        .cornerRadius(AppTheme.CornerRadius.pill)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(AppTheme.Colors.primary.opacity(0.15))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.pill)
                .stroke(AppTheme.Colors.primary.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(AppTheme.CornerRadius.pill)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()
        
        VStack(spacing: 20) {
            EditorModeToggle(selectedMode: .constant(.edit))
            EditorModeToggle(selectedMode: .constant(.preview))
        }
    }
}