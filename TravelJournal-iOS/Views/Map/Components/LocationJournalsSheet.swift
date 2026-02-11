//
//  LocationJournalsSheet.swift
//  TravelJournal-iOS
//
//  Bottom sheet showing journals at a selected location
//

import CoreLocation
import SwiftUI

struct LocationJournalsSheet: View {
    let location: JournalLocation
    let journals: [JournalPreview]
    let isLoading: Bool
    let onJournalTap: (JournalPreview) -> Void
    let onDismiss: () -> Void

    @State private var dragOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            // Location header
            locationHeader

            // Journals list
            if isLoading {
                loadingView
            } else if journals.isEmpty {
                emptyView
            } else {
                journalsScrollView
            }
            
            // Drag handle at bottom
            dragHandle
        }
        .padding(.top, AppTheme.Spacing.sm)
        .padding(.bottom, AppTheme.Spacing.xs)
        .background(
            ZStack {
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 20,
                    bottomTrailingRadius: 20,
                    topTrailingRadius: 0
                )
                .fill(
                    LinearGradient(
                        colors: [
                            AppTheme.Colors.passportPageLight,
                            AppTheme.Colors.passportPageDark
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Subtle grid pattern
                PassportGridPatternView()
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 0,
                            bottomLeadingRadius: 20,
                            bottomTrailingRadius: 20,
                            topTrailingRadius: 0
                        )
                    )
            }
            .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
        )
        .offset(y: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Only allow dragging up (negative direction to dismiss)
                    if value.translation.height < 0 {
                        dragOffset = value.translation.height
                    }
                }
                .onEnded { value in
                    if value.translation.height < -80 {
                        onDismiss()
                    } else {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            dragOffset = 0
                        }
                    }
                }
        )
    }

    // MARK: - Drag Handle

    private var dragHandle: some View {
        RoundedRectangle(cornerRadius: 2.5)
            .fill(AppTheme.Colors.passportTextMuted)
            .frame(width: 40, height: 5)
            .padding(.top, AppTheme.Spacing.sm)
    }

    // MARK: - Location Header

    private var locationHeader: some View {
        VStack(spacing: AppTheme.Spacing.xxxs) {
            Text(location.displayName)
                .font(AppTheme.Typography.serifSmall())
                .foregroundColor(AppTheme.Colors.passportTextPrimary)

            Text(location.countSubtitle)
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.passportTextSecondary)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.bottom, AppTheme.Spacing.sm)
        .padding(.bottom, AppTheme.Spacing.sm)
    }

    // MARK: - Journals Scroll View

    private var journalsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(journals) { journal in
                    JournalPreviewCard(journal: journal) {
                        onJournalTap(journal)
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            ForEach(0..<3, id: \.self) { _ in
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                        .fill(AppTheme.Colors.passportInputBackground)
                        .frame(width: 116, height: 80)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppTheme.Colors.passportInputBackground)
                        .frame(width: 100, height: 12)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppTheme.Colors.passportInputBackground)
                        .frame(width: 60, height: 10)
                }
                .frame(width: 140)
                .padding(AppTheme.Spacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .fill(Color.white.opacity(0.5))
                )
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .shimmer()
    }

    // MARK: - Empty View

    private var emptyView: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Image(systemName: "book.closed")
                .font(.system(size: 28))
                .foregroundColor(AppTheme.Colors.passportTextMuted)

            Text("No journals here yet")
                .font(AppTheme.Typography.monoSmall())
                .foregroundColor(AppTheme.Colors.passportTextSecondary)
        }
        .padding(.vertical, AppTheme.Spacing.lg)
    }
}

// MARK: - Shimmer Modifier

extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

struct ShimmerModifier: ViewModifier {
    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.2),
                            Color.white.opacity(0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 0.5)
                    .offset(x: isAnimating ? geometry.size.width : -geometry.size.width * 0.5)
                    .animation(
                        .linear(duration: 1.5)
                        .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
                }
            )
            .clipped()
            .onAppear {
                isAnimating = true
            }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.gray
            .ignoresSafeArea()

        VStack {
            Spacer()

            LocationJournalsSheet(
                location: JournalLocation(
                    id: UUID(),
                    name: "Paris",
                    countryName: "France",
                    countryCode: "FR",
                    coordinate: .init(latitude: 48.8566, longitude: 2.3522),
                    journalCount: 12
                ),
                journals: MapViewModel.mockJournals,
                isLoading: false,
                onJournalTap: { _ in },
                onDismiss: {}
            )
        }
    }
}
