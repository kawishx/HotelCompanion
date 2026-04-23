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

                SectionCard(
                    title: "Settings",
                    subtitle: "Security and app preferences"
                ) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        HStack(spacing: AppSpacing.medium) {
                            Image(systemName: "gearshape.fill")
                                .font(.headline)
                                .foregroundStyle(AppColors.brandBrown)
                                .frame(width: 32, height: 32)
                                .background(AppColors.accentGoldSoft.opacity(0.35))
                                .clipShape(Circle())
                                .accessibilityHidden(true)

                            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                                Text("Open Settings")
                                    .font(AppTypography.headline)
                                    .foregroundStyle(AppColors.primaryText)

                                Text("Manage biometric login and future app preferences.")
                                    .font(AppTypography.body)
                                    .foregroundStyle(AppColors.secondaryText)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundStyle(AppColors.secondaryText)
                                .accessibilityHidden(true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(minHeight: AppSpacing.minimumTouchTarget)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Open settings")
                    .accessibilityHint("Manage biometric login preferences")
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
