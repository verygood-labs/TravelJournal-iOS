import SwiftUI

struct ThemedDatePicker: View {
    let label: String?
    @Binding var date: Date
    var minDate: Date? = nil
    var maxDate: Date? = nil
    
    @State private var showingPicker = false
    
    var body: some View {
        Button {
            showingPicker = true
        } label: {
            HStack {
                if let label = label {
                    Text(label)
                        .font(AppTheme.Typography.monoCaption())
                        .tracking(1)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .frame(width: 50, alignment: .leading)
                    
                    Spacer()
                }
                
                dateButton
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingPicker) {
            datePickerSheet
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Date Button
    private var dateButton: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            Text(formatDate(date))
                .font(AppTheme.Typography.monoMedium())
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Image(systemName: "chevron.down")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(AppTheme.Colors.primary.opacity(0.7))
        }
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, AppTheme.Spacing.xs)
        .background(AppTheme.Colors.inputBackground)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                .stroke(AppTheme.Colors.primary.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(AppTheme.CornerRadius.small)
    }
    
    // MARK: - Date Picker Sheet
    private var datePickerSheet: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Cancel") {
                    showingPicker = false
                }
                .font(AppTheme.Typography.monoMedium())
                .foregroundColor(AppTheme.Colors.passportTextSecondary)
                
                Spacer()
                
                Text(label ?? "Select Date")
                    .font(AppTheme.Typography.monoMedium())
                    .foregroundColor(AppTheme.Colors.passportTextPrimary)
                
                Spacer()
                
                Button("Done") {
                    showingPicker = false
                }
                .font(AppTheme.Typography.monoMedium())
                .foregroundColor(AppTheme.Colors.passportInputBorderFocused)
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.Colors.passportPageLight)
            
            Divider()
                .background(AppTheme.Colors.passportInputBorder)
            
            // Date Picker
            Group {
                if let minDate = minDate, let maxDate = maxDate {
                    DatePicker(
                        "",
                        selection: $date,
                        in: minDate...maxDate,
                        displayedComponents: .date
                    )
                } else if let minDate = minDate {
                    DatePicker(
                        "",
                        selection: $date,
                        in: minDate...,
                        displayedComponents: .date
                    )
                } else if let maxDate = maxDate {
                    DatePicker(
                        "",
                        selection: $date,
                        in: ...maxDate,
                        displayedComponents: .date
                    )
                } else {
                    DatePicker(
                        "",
                        selection: $date,
                        displayedComponents: .date
                    )
                }
            }
            .datePickerStyle(.wheel)
            .labelsHidden()
            .tint(AppTheme.Colors.passportInputBorderFocused)
            .colorScheme(.light)
            .padding(.horizontal, AppTheme.Spacing.md)
            
            Spacer()
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
    
    // MARK: - Helpers
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Preview
#Preview("With Label") {
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()
        
        VStack(spacing: AppTheme.Spacing.md) {
            ThemedDatePicker(
                label: "FROM",
                date: .constant(Date())
            )
            
            ThemedDatePicker(
                label: "TO",
                date: .constant(Date().addingTimeInterval(86400 * 3)),
                minDate: Date()
            )
        }
        .padding()
    }
}

#Preview("Without Label") {
    ZStack {
        AppTheme.Colors.backgroundDark
            .ignoresSafeArea()
        
        ThemedDatePicker(
            label: nil,
            date: .constant(Date())
        )
        .padding()
    }
}
