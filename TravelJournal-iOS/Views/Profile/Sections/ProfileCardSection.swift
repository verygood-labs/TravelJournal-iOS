//
//  ProfileCardSection.swift
//  TravelJournal-iOS
//
//  Created by John Apale on 1/24/26.
//

import SwiftUI

// MARK: - Profile Card Section

/// Tappable profile card that navigates to Edit Profile
struct ProfileCardSection: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        NavigationLink {
            EditProfileView(viewModel: viewModel)
        } label: {
            ProfileCardView(
                name: viewModel.displayName,
                username: viewModel.username,
                profileImageUrl: viewModel.profileImageUrl,
                isLoading: viewModel.isLoadingProfile
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    ProfileCardSection(viewModel: ProfileViewModel())
}
