import MapKit
import SwiftUI

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        ZStack {
            AppTheme.Colors.backgroundDark
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Mode Toggle (acts as handle) - isolated from animations
                modeToggle
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.top, AppTheme.Spacing.xs)
                    .padding(.bottom, AppTheme.Spacing.sm)
                    .transaction { $0.animation = nil }

                // Map content area - clipped so animations stay within bounds
                ZStack(alignment: .top) {
                    // Content based on mode (map as background)
                    switch viewModel.selectedMode {
                    case .journals:
                        JournalMapView(
                            viewModel: viewModel,
                            cameraPosition: $cameraPosition,
                            onJournalTap: { journal in
                                // TODO: Navigate to journal detail
                                print("Navigate to journal: \(journal.title)")
                            }
                        )
                        .transaction { $0.animation = nil }
                    case .travelers:
                        TravelersSearchView(
                            viewModel: viewModel,
                            onTravelerTap: { traveler in
                                // TODO: Navigate to traveler passport
                                print("Navigate to traveler: \(traveler.name)")
                            }
                        )
                        .transaction { $0.animation = nil }
                    }

                    // Carousel overlays the map when location selected
                    if viewModel.selectedMode == .journals,
                       let location = viewModel.selectedLocation {
                        JournalCarousel(
                            location: location,
                            journals: viewModel.journalsAtLocation,
                            isLoading: viewModel.isLoadingJournals,
                            onJournalTap: { journal in
                                // TODO: Navigate to journal detail
                                print("Navigate to journal: \(journal.title)")
                            },
                            onDismiss: {
                                viewModel.dismissLocationSheet()
                            }
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .clipped()
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.selectedLocation?.id)
            }
        }
    }

    // MARK: - Mode Toggle

    private var modeToggle: some View {
        HStack(spacing: 0) {
            ForEach(DiscoveryMode.allCases, id: \.self) { mode in
                modeButton(mode)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .fill(AppTheme.Colors.cardBackground)
        )
    }

    private func modeButton(_ mode: DiscoveryMode) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectedMode = mode
            }
        } label: {
            HStack(spacing: AppTheme.Spacing.xxs) {
                Image(systemName: mode == .journals ? "map" : "person.2")
                    .font(.system(size: 14, weight: .medium))

                Text(mode.rawValue.uppercased())
                    .font(AppTheme.Typography.monoSmall())
                    .tracking(1)
            }
            .foregroundColor(
                viewModel.selectedMode == mode
                    ? AppTheme.Colors.backgroundDark
                    : AppTheme.Colors.textSecondary
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .fill(
                        viewModel.selectedMode == mode
                            ? AppTheme.Colors.primary
                            : Color.clear
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    MapView()
}
