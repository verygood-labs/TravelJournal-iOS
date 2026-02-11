//
//  JournalMapView.swift
//  TravelJournal-iOS
//
//  Map mode view showing journal locations
//

import MapKit
import SwiftUI

struct JournalMapView: View {
    @ObservedObject var viewModel: MapViewModel
    @Binding var cameraPosition: MapCameraPosition
    let onJournalTap: (JournalPreview) -> Void

    @State private var currentRegion: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 80, longitudeDelta: 80)
    )

    var body: some View {
        ZStack {
            if viewModel.isLoadingLocations && viewModel.journalLocations.isEmpty {
                loadingView
            } else if viewModel.journalLocations.isEmpty {
                emptyView
            } else {
                // Map
                mapView

                // Controls overlay
                controlsOverlay
            }
        }
        .task {
            await viewModel.loadJournalLocations()
        }
    }

    // MARK: - Controls Overlay

    private var controlsOverlay: some View {
        VStack(spacing: 0) {
            Spacer()

            // Map controls at bottom right
            HStack {
                Spacer()

                MapControlsView(
                    onZoomIn: zoomIn,
                    onZoomOut: zoomOut,
                    onCenterLocation: centerToFitAll
                )
                .padding(.trailing, AppTheme.Spacing.sm)
                .padding(.bottom, 100) // Above tab bar
            }
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.primary))
                .scaleEffect(1.5)

            Text("Loading journals...")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.backgroundDark)
    }

    // MARK: - Empty View

    private var emptyView: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "map")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.Colors.textSecondary.opacity(0.5))

            VStack(spacing: AppTheme.Spacing.xxs) {
                Text("No Journals Yet")
                    .font(AppTheme.Typography.serifSmall())
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text("Be the first to share your travels!")
                    .font(AppTheme.Typography.monoSmall())
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }

            Button {
                Task {
                    await viewModel.loadJournalLocations()
                }
            } label: {
                Text("REFRESH")
                    .font(AppTheme.Typography.button())
                    .tracking(1)
                    .foregroundColor(AppTheme.Colors.primary)
            }
            .padding(.top, AppTheme.Spacing.xs)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.backgroundDark)
    }

    // MARK: - Map View

    private var mapView: some View {
        Map(position: $cameraPosition) {
            ForEach(viewModel.journalLocations) { location in
                Annotation(
                    location.name,
                    coordinate: location.coordinate,
                    anchor: .bottom
                ) {
                    JournalPinView(
                        journalCount: location.journalCount,
                        isSelected: viewModel.selectedLocation?.id == location.id
                    )
                    .onTapGesture {
                        Task {
                            await viewModel.selectLocation(location)
                            // Offset the center down so pin appears below the sheet
                            let offsetCenter = CLLocationCoordinate2D(
                                latitude: location.coordinate.latitude + 1.5,
                                longitude: location.coordinate.longitude
                            )
                            let newRegion = MKCoordinateRegion(
                                center: offsetCenter,
                                span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
                            )
                            currentRegion = newRegion
                            withAnimation {
                                cameraPosition = .region(newRegion)
                            }
                        }
                    }
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControlVisibility(.hidden)
        .safeAreaPadding(.bottom, 100) // Above tab bar for Apple Maps attribution
    }

    // MARK: - Map Controls

    private func zoomIn() {
        let newSpan = MKCoordinateSpan(
            latitudeDelta: max(currentRegion.span.latitudeDelta / 2, 0.01),
            longitudeDelta: max(currentRegion.span.longitudeDelta / 2, 0.01)
        )
        currentRegion = MKCoordinateRegion(
            center: currentRegion.center,
            span: newSpan
        )
        withAnimation {
            cameraPosition = .region(currentRegion)
        }
    }

    private func zoomOut() {
        let newSpan = MKCoordinateSpan(
            latitudeDelta: min(currentRegion.span.latitudeDelta * 2, 180),
            longitudeDelta: min(currentRegion.span.longitudeDelta * 2, 360)
        )
        currentRegion = MKCoordinateRegion(
            center: currentRegion.center,
            span: newSpan
        )
        withAnimation {
            cameraPosition = .region(currentRegion)
        }
    }

    private func centerToFitAll() {
        guard !viewModel.journalLocations.isEmpty else { return }

        let coordinates = viewModel.journalLocations.map { $0.coordinate }
        let minLat = coordinates.map { $0.latitude }.min() ?? 0
        let maxLat = coordinates.map { $0.latitude }.max() ?? 0
        let minLon = coordinates.map { $0.longitude }.min() ?? 0
        let maxLon = coordinates.map { $0.longitude }.max() ?? 0

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )

        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.5 + 10,
            longitudeDelta: (maxLon - minLon) * 1.5 + 10
        )

        currentRegion = MKCoordinateRegion(center: center, span: span)
        withAnimation {
            cameraPosition = .region(currentRegion)
        }
    }
}

// MARK: - Preview

#Preview {
    JournalMapView(
        viewModel: MapViewModel(),
        cameraPosition: .constant(.automatic),
        onJournalTap: { _ in }
    )
}
