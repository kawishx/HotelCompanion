//
//  NotificationRowCard.swift
//  HotelCompanion
//
//  File: Features/Notifications/Views/NotificationRowCard.swift
//

import SwiftUI

struct NotificationRowCard: View {
    let notification: AppNotificationItem

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            ZStack {
                Circle()
                    .fill(notification.isUnread ? AppColors.accentGoldSoft.opacity(0.45) : AppColors.surfaceWarm)
                    .frame(width: 44, height: 44)

                Image(systemName: notification.category.systemImage)
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
                        StatusChip(title: "New", tone: .accent, size: .compact)
                    }
                }

                Text(notification.message)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: AppSpacing.small) {
                    Text(notification.category.title)
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.brandBrown)

                    Text("•")
                        .foregroundStyle(AppColors.secondaryText)
                        .accessibilityHidden(true)

                    Text(notification.timeLabel)
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.secondaryText)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, AppSpacing.xSmall)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NotificationRowCard(
        notification: AppNotificationItem(
            title: "Booking Reminder",
            message: "Your suite check-in begins tomorrow at 2:00 PM.",
            timeLabel: "Just now",
            category: .booking,
            isUnread: true
        )
    )
    .padding()
    .background(AppColors.backgroundCream)
}
