//
//  NotificationsView.swift
//  HotelCompanion
//
//  File: Features/Notifications/Views/NotificationsView.swift
//

import SwiftUI

struct NotificationsView: View {
    @StateObject private var viewModel: NotificationsViewModel

    init(viewModel: NotificationsViewModel = NotificationsViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                permissionSection
                previewActionsSection
                notificationsListSection
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.large)
        }
        .background(AppColors.backgroundCream.ignoresSafeArea())
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.large)
        .task {
            viewModel.refresh()
        }
    }
}

private extension NotificationsView {
    var permissionSection: some View {
        SectionCard(
            title: "Stay Updates",
            subtitle: "Booking, dining, and arrival notifications"
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                Text(viewModel.statusMessage)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                if !viewModel.notificationsEnabled {
                    PrimaryButton(title: "Enable Notifications", systemImage: "bell.badge.fill") {
                        viewModel.requestPermission()
                    }
                    .accessibilityLabel("Enable notifications")
                }
            }
        }
    }

    var previewActionsSection: some View {
        SectionCard(
            title: "Preview Alerts",
            subtitle: "Sample local notifications for this build"
        ) {
            VStack(spacing: AppSpacing.medium) {
                PrimaryButton(title: "Preview Booking Reminder", systemImage: "calendar.badge.clock") {
                    viewModel.scheduleBookingReminderPreview()
                }
                .accessibilityLabel("Preview booking reminder notification")

                PrimaryButton(title: "Preview Food Order Update", systemImage: "fork.knife.circle") {
                    viewModel.scheduleFoodOrderPreview()
                }
                .accessibilityLabel("Preview food order update notification")

                PrimaryButton(title: "Preview Welcome Alert", systemImage: "location.circle") {
                    viewModel.scheduleGeofenceWelcomePreview()
                }
                .accessibilityLabel("Preview geofence welcome notification")
            }
        }
    }

    var notificationsListSection: some View {
        SectionCard(
            title: "Recent Notifications",
            subtitle: "Mock data for UI preview and layout"
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                ForEach(viewModel.notifications) { notification in
                    NotificationRowCard(notification: notification)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
    }
}

