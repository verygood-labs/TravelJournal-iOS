import SwiftUI

struct AddTripView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: JournalViewModel
    
    @State private var title = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var description = ""
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Trip Details") {
                    TextField("Title (e.g., Paris, France)", text: $title)
                    
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
                
                Section("Description") {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(AppTheme.Typography.monoSmall())
                    }
                }
            }
            .navigationTitle("New Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await saveTrip()
                        }
                    }
                    .disabled(title.isEmpty || isSaving)
                }
            }
            .interactiveDismissDisabled(isSaving)
        }
    }
    
    private func saveTrip() async {
        isSaving = true
        errorMessage = nil
        
        let success = await viewModel.createTrip(
            title: title,
            description: description.isEmpty ? nil : description,
            startDate: startDate,
            endDate: endDate
        )
        
        isSaving = false
        
        if success {
            dismiss()
        } else {
            errorMessage = viewModel.error ?? "Failed to create trip. Please try again."
        }
    }
}

#Preview {
    AddTripView(viewModel: JournalViewModel())
}
