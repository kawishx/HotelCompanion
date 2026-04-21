//
//  HomeView.swift
//  HotelCompanion
//
//  File: Features/Home/Views/HomeView.swift
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    private let quickActionColumns = [
        GridItem(.flexible(), spacing: AppSpacing.medium),
        GridItem(.flexible(), spacing: AppSpacing.medium)
    ]

    init(viewModel: HomeViewModel = HomeViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xLarge) {
                heroHeader
                geofenceSection
                activeStaySection
                recommendationSection
                quickActionsSection
                upcomingBookingSection
                notificationsSection
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.large)
        }
        .background(AppColors.backgroundCream.ignoresSafeArea())
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.large)
    }
}

private extension HomeView {
    var heroHeader: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Text(viewModel.greetingTitle)
                .font(AppTypography.display)
                .foregroundStyle(AppColors.primaryText)
                .accessibilityAddTraits(.isHeader)

            Text(viewModel.greetingSubtitle)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    var geofenceSection: some View {
        GeofenceStatusCard()
    }

    var activeStaySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Text("Active Stay")
                .font(AppTypography.title)
                .foregroundStyle(AppColors.primaryText)

            SectionCard(
                title: viewModel.activeStay.hotelName,
                subtitle: viewModel.activeStay.roomType
            ) {
                VStack(alignment: .leading, spacing: AppSpacing.large) {
                    ViewThatFits(in: .vertical) {
                        HStack(alignment: .top, spacing: AppSpacing.medium) {
                            stayMetric(title: "Dates", value: viewModel.activeStay.dateRange)
                            stayMetric(title: "Booking", value: viewModel.activeStay.reservationCode)
                        }

                        VStack(alignment: .leading, spacing: AppSpacing.medium) {
                            stayMetric(title: "Dates", value: viewModel.activeStay.dateRange)
                            stayMetric(title: "Booking", value: viewModel.activeStay.reservationCode)
                        }
                    }

                    Text(viewModel.activeStay.highlight)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)

                    PrimaryButton(title: "View My Stay", systemImage: "bed.double.fill") { }
                        .accessibilityLabel("View active stay details")
                }
            }
        }
    }

    var recommendationSection: some View {
        SectionCard(
            title: viewModel.recommendation.title,
            subtitle: "Tailored for your current itinerary"
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                HStack(alignment: .top, spacing: AppSpacing.medium) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(AppColors.brandBrownDeep)
                            .frame(width: 56, height: 56)

                        Image(systemName: viewModel.recommendation.systemImage)
                            .font(.title2)
                            .foregroundStyle(AppColors.accentGoldSoft)
                    }
                    .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        Text(viewModel.recommendation.summary)
                            .font(AppTypography.headline)
                            .foregroundStyle(AppColors.primaryText)

                        Text(viewModel.recommendation.detail)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                PrimaryButton(title: viewModel.recommendation.actionTitle, systemImage: "sparkles") { }
                    .accessibilityLabel("Book recommended experience")
            }
        }
    }

    var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Text("Quick Actions")
                .font(AppTypography.title)
                .foregroundStyle(AppColors.primaryText)

            LazyVGrid(columns: quickActionColumns, spacing: AppSpacing.medium) {
                ForEach(viewModel.quickActions) { action in
                    HomeQuickActionCard(action: action) { }
                }
            }
        }
    }

    var upcomingBookingSection: some View {
        SectionCard(
            title: "Upcoming Booking",
            subtitle: viewModel.upcomingBooking.dateRange
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                Text(viewModel.upcomingBooking.title)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)

                Text(viewModel.upcomingBooking.detail)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    var notificationsSection: some View {
        SectionCard(
            title: "Notifications",
            subtitle: "Recent updates during your stay"
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                ForEach(viewModel.notifications) { notification in
                    HStack(alignment: .top, spacing: AppSpacing.medium) {
                        ZStack {
                            Circle()
                                .fill(notification.isUnread ? AppColors.accentGoldSoft.opacity(0.45) : AppColors.surfaceWarm)
                                .frame(width: 44, height: 44)

                            Image(systemName: notification.systemImage)
                                .font(.headline)
                                .foregroundStyle(AppColors.brandBrown)
                        }
                        .accessibilityHidden(true)

                        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                            HStack(alignment: .firstTextBaseline, spacing: AppSpacing.small) {
                                Text(notification.title)
                                    .font(AppTypography.headline)
                                    .foregroundStyle(AppColors.primaryText)

                                if notification.isUnread {
                                    Text("New")
                                        .font(AppTypography.footnote)
                                        .foregroundStyle(AppColors.brandBrown)
                                        .padding(.horizontal, AppSpacing.small)
                                        .padding(.vertical, AppSpacing.xSmall)
                                        .background(AppColors.accentGoldSoft.opacity(0.35))
                                        .clipShape(Capsule())
                                }
                            }

                            Text(notification.message)
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)

                            Text(notification.timeLabel)
                                .font(AppTypography.footnote)
                                .foregroundStyle(AppColors.secondaryText)
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, AppSpacing.xSmall)
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }

    func stayMetric(title: String, value: String) -> some View {
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
        .background(AppColors.surfaceWarm.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
