//
//  ProfileView.swift
//  HotelCompanion
//
//  File: Features/Profile/Views/ProfileView.swift
//

import SwiftUI

@MainActor
struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? ProfileViewModel())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                contentSection
                guestRecordsSection
                hospitalityServicesSection

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
        .task {
            await viewModel.loadProfile()
        }
    }
}

private extension ProfileView {
    var guestRecordsSection: some View {
        SectionCard(
            title: "Guest Records",
            subtitle: "Timeline, billing, and synced stay history"
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                profileNavigationRow(
                    title: "Activity Timeline",
                    subtitle: "Bookings, dining, services, and stay events",
                    systemImage: "clock.arrow.circlepath"
                ) {
                    ActivityTimelineView()
                }

                profileNavigationRow(
                    title: "Billing Summary",
                    subtitle: "Review room, dining, experience, and extra service charges",
                    systemImage: "creditcard.fill"
                ) {
                    BillingSummaryView()
                }
            }
        }
    }

    var hospitalityServicesSection: some View {
        SectionCard(
            title: "Hospitality Services",
            subtitle: "Concierge planning and guest support"
        ) {
            profileNavigationRow(
                title: "Concierge Requests",
                subtitle: "Transport, reservations, celebrations, and local arrangements",
                systemImage: "message.fill"
            ) {
                ConciergeRequestsView()
            }
        }
    }

    @ViewBuilder
    var contentSection: some View {
        if viewModel.isLoading {
            SectionCard(title: "Loading Profile", subtitle: "Syncing your guest details") {
                HStack(spacing: AppSpacing.medium) {
                    ProgressView()
                        .tint(AppColors.brandBrown)

                    Text("Your profile is being prepared.")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)
                }
                .frame(minHeight: AppSpacing.minimumTouchTarget)
                .accessibilityElement(children: .combine)
            }
        } else if let errorMessage = viewModel.errorMessage {
            SectionCard(title: "Unable to Load Profile", subtitle: "Please try again in a moment") {
                VStack(alignment: .leading, spacing: AppSpacing.medium) {
                    Text(errorMessage)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)

                    PrimaryButton(title: "Retry", systemImage: "arrow.clockwise") {
                        Task {
                            await viewModel.loadProfile()
                        }
                    }
                    .accessibilityLabel("Retry loading profile")
                }
            }
        } else if viewModel.isEmpty {
            SectionCard(title: "No Synced Profile", subtitle: "Sign in to load your guest details") {
                Text("Profile details, loyalty information, and synced preferences will appear here after account sign-in and Firestore setup.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        } else {
            SectionCard(
                title: viewModel.memberName,
                subtitle: viewModel.membershipTier
            ) {
                VStack(alignment: .leading, spacing: AppSpacing.medium) {
                    if let emailText = viewModel.emailText {
                        profileMetric(title: "Email", value: emailText)
                    }

                    if let phoneText = viewModel.phoneText {
                        profileMetric(title: "Phone", value: phoneText)
                    }

                    if let preferredHotelText = viewModel.preferredHotelText {
                        profileMetric(title: "Preferred Hotel", value: preferredHotelText)
                    }
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Guest profile for \(viewModel.memberName)")
            .accessibilityValue(viewModel.membershipTier)

            SectionCard(title: "Guest preferences") {
                Text(viewModel.preferenceSummary)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Guest preferences")
            .accessibilityValue(viewModel.preferenceSummary)
        }
    }

    func profileMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
            Text(title)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.secondaryText)

            Text(value)
                .font(AppTypography.bodyEmphasized)
                .foregroundStyle(AppColors.primaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.medium)
        .background(AppColors.surfaceWarm.opacity(0.35))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(value)
    }

    func profileNavigationRow<Destination: View>(
        title: String,
        subtitle: String,
        systemImage: String,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: AppSpacing.medium) {
                Image(systemName: systemImage)
                    .font(.headline)
                    .foregroundStyle(AppColors.brandBrown)
                    .frame(width: 32, height: 32)
                    .background(AppColors.accentGoldSoft.opacity(0.35))
                    .clipShape(Circle())
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                    Text(title)
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.primaryText)

                    Text(subtitle)
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
        .accessibilityLabel(title)
        .accessibilityHint(subtitle)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}
