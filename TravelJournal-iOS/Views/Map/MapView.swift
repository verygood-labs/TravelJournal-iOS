import MapKit
import SwiftUI

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.error {
                    errorView(message: error)
                } else {
                    mapContent
                }
            }
            .navigationTitle("Travel Map")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Map Content

    private var mapContent: some View {
        Map(position: $position) {
            // Plot visited countries/locations
            ForEach(viewModel.visitedLocations) { location in
                Marker(location.name, coordinate: location.coordinate)
                    .tint(AppTheme.Colors.primary)
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .overlay(alignment: .bottom) {
            statsOverlay
        }
        .task {
            await viewModel.loadVisitedLocations()
        }
    }

    // MARK: - Stats Overlay

    private var statsOverlay: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            HStack(spacing: AppTheme.Spacing.lg) {
                statItem(
                    icon: "globe.americas.fill",
                    value: "\(viewModel.countriesCount)",
                    label: "Countries"
                )

                Divider()
                    .frame(height: 30)
                    .background(AppTheme.Colors.primary.opacity(0.3))

                statItem(
                    icon: "airplane",
                    value: "\(viewModel.tripsCount)",
                    label: "Trips"
                )

                Divider()
                    .frame(height: 30)
                    .background(AppTheme.Colors.primary.opacity(0.3))

                statItem(
                    icon: "mappin.and.ellipse",
                    value: "\(viewModel.locationsCount)",
                    label: "Places"
                )
            }
            .padding(.vertical, AppTheme.Spacing.md)
            .padding(.horizontal, AppTheme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
            )
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.bottom, AppTheme.Spacing.lg)
    }

    private func statItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: AppTheme.Spacing.xxs) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppTheme.Colors.primary)

            Text(value)
                .font(AppTheme.Typography.serifMedium())
                .foregroundColor(AppTheme.Colors.textPrimary)

            Text(label)
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            AnimatedGlobeView(size: 60)

            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.primary))

            Text("Loading map...")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
    }

    // MARK: - Error View

    private func errorView(message: String) -> some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.Colors.primary.opacity(0.6))

            Text("Unable to Load Map")
                .font(AppTheme.Typography.serifSmall())
                .foregroundColor(AppTheme.Colors.textPrimary)

            Text(message)
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.xl)

            Button {
                Task {
                    await viewModel.loadVisitedLocations()
                }
            } label: {
                HStack(spacing: AppTheme.Spacing.xxs) {
                    Image(systemName: "arrow.clockwise")
                    Text("RETRY")
                        .font(AppTheme.Typography.button())
                        .tracking(1)
                }
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
}

// MARK: - Supporting Types

struct VisitedLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let countryCode: String
}

#Preview {
    MapView()
}
