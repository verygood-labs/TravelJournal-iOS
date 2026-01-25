import SwiftUI

// MARK: - Option Picker Sheet
/// Reusable picker sheet for selecting from a list of options
/// Styled to match the passport page aesthetic
struct OptionPickerSheet<Option: Identifiable & Equatable>: View {
    let title: String
    let options: [Option]
    let selectedOption: Option
    let optionLabel: (Option) -> String
    let onSelect: (Option) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            Divider()
                .background(AppTheme.Colors.passportInputBorder)
            
            // Options List
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(options) { option in
                        optionRow(option)
                        
                        if option.id as AnyHashable != options.last?.id as AnyHashable {
                            Divider()
                                .background(AppTheme.Colors.passportInputBorder.opacity(0.5))
                                .padding(.leading, AppTheme.Spacing.lg)
                        }
                    }
                }
            }
        }
        .background(
            LinearGradient(
                colors: [
                    AppTheme.Colors.passportPageLight,
                    AppTheme.Colors.passportPageDark
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .font(AppTheme.Typography.monoMedium())
            .foregroundColor(AppTheme.Colors.passportTextSecondary)
            
            Spacer()
            
            Text(title)
                .font(AppTheme.Typography.monoMedium())
                .foregroundColor(AppTheme.Colors.passportTextPrimary)
            
            Spacer()
            
            // Invisible button to balance the header
            Button("Cancel") { }
                .font(AppTheme.Typography.monoMedium())
                .opacity(0)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(AppTheme.Colors.passportPageLight)
    }
    
    // MARK: - Option Row
    
    private func optionRow(_ option: Option) -> some View {
        Button {
            onSelect(option)
            dismiss()
        } label: {
            HStack {
                Text(optionLabel(option))
                    .font(AppTheme.Typography.monoMedium())
                    .foregroundColor(AppTheme.Colors.passportTextPrimary)
                
                Spacer()
                
                if option == selectedOption {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            OptionPickerSheet(
                title: "Currency",
                options: Currency.allCases,
                selectedOption: .usd,
                optionLabel: { $0.displayName },
                onSelect: { _ in }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
}
