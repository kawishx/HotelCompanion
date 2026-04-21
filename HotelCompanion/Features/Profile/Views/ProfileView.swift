//
//  ProfileView.swift
//  HotelCompanion
//
//  File: Features/Profile/Views/ProfileView.swift
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel = ProfileViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                SectionCard(
                    title: viewModel.memberName,
                    subtitle: viewModel.membershipTier
                ) {
                    Text("Your profile foundation is ready for authentication, loyalty syncing, and preference management.")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)
                }

                SectionCard(title: "Guest preferences") {
                    Text(viewModel.preferenceSummary)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.primaryText)
                }

                PrimaryButton(title: "Edit Profile", systemImage: "person.crop.circle.badge.plus") { }
                    .accessibilityLabel("Edit guest profile")
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.large)
        }
        .background(AppColors.backgroundCream.ignoresSafeArea())
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}
