import SwiftUI

struct AddTripView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddTripViewModel()
    
    @State private var showingPreview = false
    
    var body: some View {
        AppBackgroundView {
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Content
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        // Search field
                        searchSection
                        
                        // Added stops
                        if !viewModel.stops.isEmpty {
                            stopsSection
                        }
                        
                        // Bottom padding for button
                        Spacer()
                            .frame(height: 100)
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.top, AppTheme.Spacing.md)
                }
                
                // Bottom button
                if !viewModel.stops.isEmpty {
                    bottomButton
                }
            }
        }
        .onChange(of: viewModel.searchText) { _, _ in
            viewModel.onSearchTextChanged()
        }
        .fullScreenCover(isPresented: $showingPreview) {
            TripPreviewView(
                viewModel: viewModel,
                onTripCreated: {
                    showingPreview = false
                    dismiss()
                }
            )
        }
        .alert("Error", isPresented: .init(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.error = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.error ?? "")
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Text("← Back")
            }
            .buttonStyle(BackButtonStyle())
            
            Spacer()
            
            Text("NEW JOURNAL")
                .font(AppTheme.Typography.monoSmall())
                .tracking(2)
                .foregroundColor(AppTheme.Colors.primary)
            
            Spacer()
            
            // Invisible button for balance
            Text("← Back")
                .opacity(0)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.md)
    }
    
    // MARK: - Search Section
    private var searchSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text("DESTINATIONS")
                .font(AppTheme.Typography.monoCaption())
                .tracking(1)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            CitySearchField(
                searchText: $viewModel.searchText,
                searchResults: viewModel.searchResults,
                isSearching: viewModel.isSearching,
                onCitySelected: { city in
                    viewModel.addStop(city: city)
                }
            )
        }
    }
    
    // MARK: - Stops Section
    private var stopsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("YOUR STOPS")
                .font(AppTheme.Typography.monoCaption())
                .tracking(1)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            ForEach(Array(viewModel.stops.enumerated()), id: \.element.id) { index, stop in
                TripStopCard(
                    stopNumber: index + 1,
                    stop: $viewModel.stops[index],
                    onRemove: {
                        withAnimation(.easeInOut(duration: AppTheme.Animation.fast)) {
                            viewModel.removeStop(at: index)
                        }
                    }
                )
            }
        }
    }
    
    // MARK: - Bottom Button
    private var bottomButton: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Button {
                showingPreview = true
            } label: {
                HStack(spacing: AppTheme.Spacing.xxs) {
                    Text("CONTINUE")
                        .font(AppTheme.Typography.button())
                        .tracking(1)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .medium))
                }
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(AppTheme.Colors.backgroundDark)
    }
}

// MARK: - Preview
#Preview {
    AddTripView()
}
