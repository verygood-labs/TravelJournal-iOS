import SwiftUI

struct EditTripView: View {
    let trip: Trip
    
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String
    @State private var description: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var hasStartDate: Bool
    @State private var hasEndDate: Bool
    @State private var isLoading = false
    @State private var error: String?
    
    init(trip: Trip) {
        self.trip = trip
        _title = State(initialValue: trip.title)
        _description = State(initialValue: trip.description ?? "")
        _startDate = State(initialValue: trip.startDate ?? Date())
        _endDate = State(initialValue: trip.endDate ?? Date())
        _hasStartDate = State(initialValue: trip.startDate != nil)
        _hasEndDate = State(initialValue: trip.endDate != nil)
    }
    
    var body: some View {
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
            
            Section("Visibility") {
                Picker("Status", selection: .constant(trip.status)) {
                    Text("Draft").tag(TripStatus.draft)
                    Text("Private").tag(TripStatus.private)
                    Text("Public").tag(TripStatus.public)
                }
            }
            
            if let error = error {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Edit Trip")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                        await saveTrip()
                    }
                }
                .disabled(title.isEmpty || isLoading)
            }
        }
    }
    
    private func saveTrip() async {
        isLoading = true
        error = nil
        
        do {
            _ = try await TripService.shared.updateTrip(
                id: trip.id,
                title: title,
                description: description.isEmpty ? nil : description,
                startDate: hasStartDate ? startDate : nil,
                endDate: hasEndDate ? endDate : nil
            )
            dismiss()
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = "Failed to save trip"
        }
        
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        EditTripView(trip: Trip(
            id: UUID(),
            title: "Japan Adventure",
            description: "Two weeks exploring",
            coverImageUrl: nil,
            status: .draft,
            startDate: Date(),
            endDate: nil,
            createdAt: Date(),
            updatedAt: Date(),
            stops: nil
        ))
    }
}