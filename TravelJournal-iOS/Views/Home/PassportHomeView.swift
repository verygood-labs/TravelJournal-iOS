import SwiftUI

struct PassportHomeView: View {
    @StateObject private var viewModel = PassportHomeViewModel()
    @State private var showingAddTrip = false

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
                        .frame(height: 160)
                    
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
                            VisasSection(viewModel: viewModel)
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
        .task {
            await viewModel.loadData()
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
                Spacer()
                
                // Animated globe
                AnimatedGlobeView(size: 60)
                
                // "PASSPORT" text
                Text("YOUR PASSPORT")
                    .font(AppTheme.Typography.monoMedium())
                    .tracking(4)
                    .foregroundColor(AppTheme.Colors.primary)
                
                Spacer()
            }
            .overlay(
                // Add trip button (top right)
                HStack {
                    Spacer()
                    Button {
                        handleAddTrip()
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(AppTheme.Colors.primary)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .stroke(AppTheme.Colors.primary.opacity(0.4), lineWidth: 1.5)
                            )
                    }
                    .padding(.trailing, AppTheme.Spacing.lg)
                    .padding(.top, AppTheme.Spacing.lg)
                }
                , alignment: .topTrailing
            )
        }
    }
    
    // MARK: - Actions
    private func handleAddTrip() {
        print("➕ Add Trip button tapped - will open journal drafting space")
        // TODO: Navigate to journal tab or show trip creation modal
    }
}

#Preview {
    PassportHomeView()
}
