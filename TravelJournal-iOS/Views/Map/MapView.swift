import MapKit
import SwiftUI

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        AppBackgroundView {
            VStack(spacing: 0) {
                // Header section
                VStack(spacing: AppTheme.Spacing.xs) {
                    Text("DISCOVER")
                        .font(AppTheme.Typography.monoSmall())
                        .tracking(3)
                        .foregroundColor(AppTheme.Colors.primary.opacity(0.7))

                    Text("Explore Journeys")
                        .font(AppTheme.Typography.serifMedium())
                        .foregroundColor(AppTheme.Colors.primary)
                }
                .padding(.top, AppTheme.Spacing.lg)
                .padding(.bottom, AppTheme.Spacing.md)
                .transaction { $0.animation = nil }

                // Mode Toggle - isolated from animations
                modeToggle
                    .padding(.horizontal, AppTheme.Spacing.lg)
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
                .ignoresSafeArea(edges: .bottom)
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
        .background(AppTheme.Colors.primary.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .stroke(AppTheme.Colors.primary.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(AppTheme.CornerRadius.medium)
    }

    private func modeButton(_ mode: DiscoveryMode) -> some View {
        Button {
            withAnimation(.easeInOut(duration: AppTheme.Animation.fast)) {
                viewModel.selectedMode = mode
            }
        } label: {
            Text(mode.rawValue.uppercased())
                .font(AppTheme.Typography.monoCaption())
                .tracking(1)
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.xs)
                .frame(maxWidth: .infinity)
                .background(
                    viewModel.selectedMode == mode
                        ? AppTheme.Colors.primary
                        : Color.clear
                )
                .foregroundColor(
                    viewModel.selectedMode == mode
                        ? AppTheme.Colors.backgroundDark
                        : AppTheme.Colors.primary.opacity(0.6)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    MapView()
}
