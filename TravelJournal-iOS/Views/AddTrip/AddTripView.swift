import SwiftUI

struct AddTripView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (Trip) -> Void
    
    @State private var title = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var description = ""
    
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
                    Button("Save") {
                        saveTrip()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveTrip() {
        let now = Date()
        let trip = Trip(
            id: UUID(),
            title: title,
            description: description.isEmpty ? nil : description,
            coverImageUrl: nil,
            status: .draft,
            startDate: startDate,
            endDate: endDate,
            createdAt: now,
            updatedAt: now,
            stops: nil
        )
        
        onSave(trip)
        dismiss()
    }
}

#Preview {
    AddTripView { _ in }
}
