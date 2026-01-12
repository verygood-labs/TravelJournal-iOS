import SwiftUI

// MARK: - Registration Progress Bar
/// Displays step progress for multi-step registration flow
struct RegistrationProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    
    private var progress: Double {
        Double(currentStep) / Double(totalSteps)
    }
    
    private var percentComplete: Int {
        Int(progress * 100)
    }
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.xxs) {
            // Step indicator and percentage
            HStack {
                Text("STEP \(currentStep) OF \(totalSteps)")
                    .font(AppTheme.Typography.monoSmall())
                    .tracking(1)
                    .foregroundColor(AppTheme.Colors.primary)
                
                Spacer()
                
                Text("\(percentComplete)% COMPLETE")
                    .font(AppTheme.Typography.monoSmall())
                    .tracking(1)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            // Progress segments
            HStack(spacing: AppTheme.Spacing.xxxs) {
                ForEach(1...totalSteps, id: \.self) { step in
                    ProgressSegment(isCompleted: step <= currentStep)
                }
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.backgroundDark)
    }
}

// MARK: - Progress Segment
private struct ProgressSegment: View {
    let isCompleted: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(isCompleted ? AppTheme.Colors.primary : AppTheme.Colors.primary.opacity(0.2))
            .frame(height: 4)
            .animation(.easeInOut(duration: AppTheme.Animation.medium), value: isCompleted)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 40) {
        RegistrationProgressBar(currentStep: 1, totalSteps: 4)
        RegistrationProgressBar(currentStep: 2, totalSteps: 4)
        RegistrationProgressBar(currentStep: 3, totalSteps: 4)
        RegistrationProgressBar(currentStep: 4, totalSteps: 4)
    }
    .background(AppTheme.Colors.backgroundDark)
}
