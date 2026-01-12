import SwiftUI

struct TripCardView: View {
    let trip: Trip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Cover image
            ZStack {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .aspectRatio(16/9, contentMode: .fit)
                
                Image(systemName: "photo")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(trip.title)
                        .font(.headline)
                    
                    Spacer()
                    
                    StatusBadge(status: trip.status)
                }
                
                if let description = trip.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                if let startDate = trip.startDate {
                    HStack {
                        Image(systemName: "calendar")
                        Text(startDate, style: .date)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

#Preview {
    TripCardView(trip: Trip(
        id: UUID(),
        title: "Japan Adventure",
        description: "Two weeks exploring Tokyo, Kyoto, and Osaka",
        coverImageUrl: nil,
        status: .draft,
        startDate: Date(),
        endDate: nil,
        createdAt: Date(),
        updatedAt: Date(),
        stops: nil
    ))
    .padding()
}