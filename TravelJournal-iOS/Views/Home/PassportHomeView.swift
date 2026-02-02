import SwiftUI

struct PassportHomeView: View {
    @StateObject private var viewModel: PassportHomeViewModel
    @Binding var selectedTab: Int

    /// Default initializer for normal use
    init(selectedTab: Binding<Int>) {
        _selectedTab = selectedTab
        _viewModel = StateObject(wrappedValue: PassportHomeViewModel())
    }

    /// Preview initializer with injected view model
    init(selectedTab: Binding<Int>, previewViewModel: PassportHomeViewModel) {
        _selectedTab = selectedTab
        previewViewModel.isPreview = true
        _viewModel = StateObject(wrappedValue: previewViewModel)
    }

    var body: some View {
        ZStack {
            if viewModel.isLoadingProfile || viewModel.isLoadingStats {
                loadingView
            } else if let error = viewModel.error {
                errorView(message: error)
            } else {
                VStack(spacing: 0) {
                    // Header section (dark background)
                    headerSection
                        .frame(height: 140)

                    // Gold decorative border
                    GoldBorder()

                    // Body section (passport page background)
                    ScrollView {
                        VStack(spacing: AppTheme.Spacing.lg) {
                            // Identification section
                            IdentificationSection(viewModel: viewModel)
                                .padding(.top, AppTheme.Spacing.lg)

                            // Divider between sections
                            SectionDivider()

                            // Visas & Entries section
                            VisasSection(viewModel: viewModel) {
                                selectedTab = 2 // Journal tab index
                            }
                            .padding(.bottom, AppTheme.Spacing.xl)
                        }
                    }
                    .background(
                        PassportPageBackgroundView { Color.clear }
                            .ignoresSafeArea(edges: .bottom)
                    )
                }
            }
        }
        .sheet(isPresented: $viewModel.showingAddTrip) {
            AddTripView()
        }
        .task {
            if !viewModel.isPreview {
                await viewModel.loadData()
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Error View

    private func errorView(message: String) -> some View {
        AppBackgroundView {
            VStack(spacing: AppTheme.Spacing.lg) {
                // Error icon
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.Colors.primary.opacity(0.6))

                // Error message
                VStack(spacing: AppTheme.Spacing.xs) {
                    Text("Unable to Load Passport")
                        .font(AppTheme.Typography.serifSmall())
                        .foregroundColor(AppTheme.Colors.primary)

                    Text(message)
                        .font(AppTheme.Typography.monoSmall())
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppTheme.Spacing.xl)
                }

                // Retry button
                Button {
                    Task {
                        await viewModel.refresh()
                    }
                } label: {
                    HStack(spacing: AppTheme.Spacing.xxs) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .medium))
                        Text("TRY AGAIN")
                            .font(AppTheme.Typography.button())
                            .tracking(1)
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .frame(width: 200)
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        AppBackgroundView {
            VStack(spacing: AppTheme.Spacing.md) {
                AnimatedGlobeView(size: 80)

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.primary))
                    .scaleEffect(1.2)

                Text("Loading your passport...")
                    .font(AppTheme.Typography.monoSmall())
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        AppBackgroundView {
            VStack(spacing: AppTheme.Spacing.xs) {
                // Animated globe
                AnimatedGlobeView(size: 60)

                // "PASSPORT" text
                Text("YOUR PASSPORT")
                    .font(AppTheme.Typography.monoMedium())
                    .tracking(4)
                    .foregroundColor(AppTheme.Colors.primary)
            }
        }
    }

    // MARK: - Actions

    private func handleAddTrip() {
        print("➕ Add Trip button tapped - will open journal drafting space")
        // TODO: Navigate to journal tab or show trip creation modal
    }
}

#Preview("Empty State") {
    PassportHomeView(selectedTab: .constant(0))
}

#Preview("With Data") {
    let vm = PassportHomeViewModel()

    vm.userProfile = UserProfile(
        userId: UUID(),
        email: "traveler@example.com",
        userName: "wanderlust",
        name: "Alex Thompson",
        bio: "Adventure seeker",
        profilePictureUrl: nil,
        nationality: NationalityInfo(id: "1", name: "United States", countryCode: "US"),
        preferredLanguage: "en",
        preferredCurrency: "USD",
        createdAt: Date().addingTimeInterval(-86400 * 365),
        updatedAt: Date()
    )

    vm.userStats = UserStats(
        totalTrips: 12,
        totalEntries: 47,
        countriesVisited: 8,
        totalPhotos: 234,
        totalDistance: 45000
    )

    vm.countryStamps = [
        CountryStamp(countryCode: "JP", countryName: "Japan", visitCount: 2, stampImageUrl: nil),
        CountryStamp(countryCode: "IT", countryName: "Italy", visitCount: 1, stampImageUrl: nil),
        CountryStamp(countryCode: "KR", countryName: "Korea", visitCount: 1, stampImageUrl: nil),
        CountryStamp(countryCode: "TH", countryName: "Thailand", visitCount: 3, stampImageUrl: nil),
        CountryStamp(countryCode: "MX", countryName: "Mexico", visitCount: 1, stampImageUrl: nil),
        CountryStamp(countryCode: "FR", countryName: "France", visitCount: 2, stampImageUrl: nil),
        CountryStamp(countryCode: "ES", countryName: "Spain", visitCount: 1, stampImageUrl: nil),
        CountryStamp(countryCode: "DE", countryName: "Germany", visitCount: 1, stampImageUrl: nil),
    ]

    return PassportHomeView(selectedTab: .constant(0), previewViewModel: vm)
}
