//
//  HomeView.swift
//  HotelCompanion
//
//  File: Features/Home/Views/HomeView.swift
//

import SwiftUI

struct HomeView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
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
                serviceRequestSection
                conciergeSection
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
                        .accessibilityLabel("Stay highlight. \(viewModel.activeStay.highlight)")

                    NavigationLink {
                        MyStayView()
                    } label: {
                        HStack(spacing: AppSpacing.small) {
                            Image(systemName: "bed.double.fill")
                                .font(.headline)

                            Text("View My Stay")
                                .font(AppTypography.button)
                                .multilineTextAlignment(.center)
                        }
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: AppSpacing.minimumTouchTarget)
                        .padding(.horizontal, AppSpacing.large)
                        .background(AppColors.brandBrown)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius)
                                .stroke(AppColors.accentGoldSoft, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius, style: .continuous))
                        .shadow(color: AppColors.shadow, radius: 12, y: 6)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("View active stay details")
                    .accessibilityHint("Opens your room, booking, and stay timing details")
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Active stay at \(viewModel.activeStay.hotelName)")
        }
    }

    var recommendationSection: some View {
        SectionCard(
            title: viewModel.recommendation.title,
            subtitle: "Tailored for your current itinerary"
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .top, spacing: AppSpacing.medium) {
                        recommendationIcon
                        recommendationText
                    }

                    VStack(alignment: .leading, spacing: AppSpacing.medium) {
                        recommendationIcon
                        recommendationText
                    }
                }

                PrimaryButton(title: viewModel.recommendation.actionTitle, systemImage: "sparkles") { }
                    .accessibilityLabel("Book recommended experience")
                    .accessibilityHint("Starts the recommended experience booking flow")
            }
            .accessibilityElement(children: .contain)
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

    var serviceRequestSection: some View {
        SectionCard(
            title: "Service Request",
            subtitle: "Report maintenance issues with a photo"
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                Text("Capture a maintenance issue and send a clearer request to the hotel team with supporting photos.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                NavigationLink {
                    ServiceRequestView()
                } label: {
                    HStack(spacing: AppSpacing.small) {
                        Text("Open Service Request")
                            .font(AppTypography.bodyEmphasized)
                            .foregroundStyle(AppColors.brandBrown)

                        Image(systemName: "chevron.right.circle.fill")
                            .foregroundStyle(AppColors.brandBrown)
                            .accessibilityHidden(true)
                    }
                    .frame(minHeight: AppSpacing.minimumTouchTarget)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open service request")
                .accessibilityHint("Upload a maintenance issue photo")
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
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Upcoming booking")
            .accessibilityValue("\(viewModel.upcomingBooking.title), \(viewModel.upcomingBooking.dateRange)")
        }
    }

    var conciergeSection: some View {
        SectionCard(
            title: "Concierge",
            subtitle: "Arrange transport, dining, and local experiences"
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                Text("Contact the hotel concierge for reservations, transfers, and special celebration planning.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                NavigationLink {
                    ConciergeRequestsView()
                } label: {
                    HStack(spacing: AppSpacing.small) {
                        Text("Open Concierge")
                            .font(AppTypography.bodyEmphasized)
                            .foregroundStyle(AppColors.brandBrown)

                        Image(systemName: "chevron.right.circle.fill")
                            .foregroundStyle(AppColors.brandBrown)
                            .accessibilityHidden(true)
                    }
                    .frame(minHeight: AppSpacing.minimumTouchTarget)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open concierge requests")
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
                    NotificationRowCard(notification: notification)
                }

                NavigationLink {
                    NotificationsView()
                } label: {
                    HStack(spacing: AppSpacing.small) {
                        Text("View All Notifications")
                            .font(AppTypography.bodyEmphasized)
                            .foregroundStyle(AppColors.brandBrown)

                        Image(systemName: "chevron.right.circle.fill")
                            .foregroundStyle(AppColors.brandBrown)
                            .accessibilityHidden(true)
                    }
                    .frame(minHeight: AppSpacing.minimumTouchTarget)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("View all notifications")
                .accessibilityHint("Opens the notifications screen")
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
        .accessibilityLabel(title)
        .accessibilityValue(value)
    }

    var recommendationIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColors.brandBrownDeep)
                .frame(width: 56, height: 56)

            Image(systemName: viewModel.recommendation.systemImage)
                .font(.title2)
                .foregroundStyle(AppColors.accentGoldSoft)
        }
        .accessibilityHidden(true)
    }

    var recommendationText: some View {
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
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
