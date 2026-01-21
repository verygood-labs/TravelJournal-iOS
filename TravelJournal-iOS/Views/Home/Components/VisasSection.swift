import SwiftUI

struct VisasSection: View {
    @ObservedObject var viewModel: PassportHomeViewModel
    var onViewAllTapped: (() -> Void)? = nil
    
    @State private var currentPage = 0
    
    private let stampsPerPage = 6
    private let maxPages = 6
    
    private var totalPages: Int {
        let stampCount = viewModel.countryStamps.count
        guard stampCount > 0 else { return 0 }
        let pages = (stampCount + stampsPerPage - 1) / stampsPerPage
        return min(pages, maxPages)
    }

    private func stampsForPage(_ page: Int) -> [CountryStamp] {
        let startIndex = page * stampsPerPage
        let endIndex = min(startIndex + stampsPerPage, viewModel.countryStamps.count)
        guard startIndex < viewModel.countryStamps.count else { return [] }
        return Array(viewModel.countryStamps[startIndex..<endIndex])
    }

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Section header
            sectionHeader
                .padding(.horizontal, AppTheme.Spacing.lg)
            
            // Paginated stamps grid
            stampGrid
        }
    }

    // MARK: - Section Header
    private var sectionHeader: some View {
        SectionHeader(
            title: "VISAS & ENTRIES",
            subtitle: "Your travel stamps",
            trailingActionLabel: viewModel.countryStamps.isEmpty ? nil : "View All",
            onTrailingActionTapped: onViewAllTapped
        )
    }
    
    // MARK: - Stamp Grid
    private var stampGrid: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            if viewModel.countryStamps.isEmpty {
                emptyState
            } else {
                // Paginated stamps
                TabView(selection: $currentPage) {
                    ForEach(0..<totalPages, id: \.self) { page in
                        stampPage(for: page)
                            .tag(page)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(minHeight: 280) // minimum height, but can grow
                .fixedSize(horizontal: false, vertical: true)
                
                // Custom page indicator
                pageIndicator
            }
        }
    }
    
    // MARK: - Stamp Page
    private func stampPage(for page: Int) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: AppTheme.Spacing.xs),
                GridItem(.flexible(), spacing: AppTheme.Spacing.xs),
                GridItem(.flexible(), spacing: AppTheme.Spacing.xs)
            ],
            spacing: AppTheme.Spacing.xs
        ) {
            ForEach(stampsForPage(page)) { stamp in
                CountryStampView(stamp: stamp)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }

    // MARK: - Page Indicator
    private var pageIndicator: some View {
        HStack(spacing: AppTheme.Spacing.xxs) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage
                        ? AppTheme.Colors.passportInputBorderFocused
                        : AppTheme.Colors.passportTextMuted.opacity(0.3))
                    .frame(width: index == currentPage ? 20 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            
            Button {
                onViewAllTapped?()
            } label: {
                Text("ADD NEW JOURNAL")
                    .font(AppTheme.Typography.button())
                    .tracking(1)
            }
            .buttonStyle(PrimaryButtonStyle())
            .frame(width: 180)
        }
        .frame(height: 240)
    }
}

// MARK: - Preview
#Preview("Empty State") {
    PassportPageBackgroundView {
        VisasSection(viewModel: PassportHomeViewModel())
            .padding(.vertical, AppTheme.Spacing.lg)
    }
}

#Preview("With Stamps") {
    return PassportPageBackgroundView {
        VisasSection(viewModel: {
            let vm = PassportHomeViewModel()
            vm.countryStamps = [
                CountryStamp(countryCode: "JP", countryName: "Japan", visitCount: 2, stampImageUrl: nil),
                CountryStamp(countryCode: "IT", countryName: "Italy", visitCount: 1, stampImageUrl: nil),
                CountryStamp(countryCode: "KR", countryName: "Korea", visitCount: 1, stampImageUrl: nil),
                CountryStamp(countryCode: "TH", countryName: "Thailand", visitCount: 3, stampImageUrl: nil),
                CountryStamp(countryCode: "MX", countryName: "Mexico", visitCount: 1, stampImageUrl: nil),
                CountryStamp(countryCode: "FR", countryName: "France", visitCount: 2, stampImageUrl: nil),
                CountryStamp(countryCode: "ES", countryName: "Spain", visitCount: 1, stampImageUrl: nil),
                CountryStamp(countryCode: "DE", countryName: "Germany", visitCount: 1, stampImageUrl: nil)
            ]
            return vm
        }())
        .padding(.vertical, AppTheme.Spacing.lg)
    }
}
