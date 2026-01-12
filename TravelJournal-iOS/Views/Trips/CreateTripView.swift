import SwiftUI

struct CreateTripView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var hasStartDate = false
    @State private var hasEndDate = false
    @State private var isLoading = false
    @State private var error: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Trip Title", text: $title)
                    
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Dates") {
                    Toggle("Start Date", isOn: $hasStartDate)
                    
                    if hasStartDate {
                        DatePicker("Start", selection: $startDate, displayedComponents: .date)
                    }
                    
                    Toggle("End Date", isOn: $hasEndDate)
                    
                    if hasEndDate {
                        DatePicker("End", selection: $endDate, displayedComponents: .date)
                    }
                }
                
                if let error = error {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
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
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        Task {
                            await createTrip()
                        }
                    }
                    .disabled(title.isEmpty || isLoading)
                }
            }
        }
    }
    
    private func createTrip() async {
        isLoading = true
        error = nil
        
        do {
            _ = try await TripService.shared.createTrip(
                title: title,
                description: description.isEmpty ? nil : description,
                startDate: hasStartDate ? startDate : nil,
                endDate: hasEndDate ? endDate : nil
            )
            dismiss()
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = "Failed to create trip"
        }
        
        isLoading = false
    }
}

#Preview {
    CreateTripView()
}