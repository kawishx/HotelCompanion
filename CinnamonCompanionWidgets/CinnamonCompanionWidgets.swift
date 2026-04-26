//
//  CinnamonCompanionWidgets.swift
//  CinnamonCompanionWidgets
//
//  File: CinnamonCompanionWidgets/CinnamonCompanionWidgets.swift
//

import SwiftUI
import WidgetKit

struct UpcomingBookingWidget: Widget {
    let kind = "UpcomingBookingWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CinnamonCompanionTimelineProvider()) { entry in
            UpcomingBookingWidgetView(entry: entry)
        }
        .configurationDisplayName("Upcoming Booking")
        .description("Shows your next hotel booking at a glance.")
        .supportedFamilies([.systemSmall])
    }
}

struct StaySummaryWidget: Widget {
    let kind = "StaySummaryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CinnamonCompanionTimelineProvider()) { entry in
            StaySummaryWidgetView(entry: entry)
        }
        .configurationDisplayName("Stay Summary")
        .description("Shows your current stay and a timely recommendation.")
        .supportedFamilies([.systemMedium])
    }
}

struct StayDetailsWidget: Widget {
    let kind = "StayDetailsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CinnamonCompanionTimelineProvider()) { entry in
            StayDetailsWidgetView(entry: entry)
        }
        .configurationDisplayName("Stay Details")
        .description("Shows stay details, dining promotion, and your next booking.")
        .supportedFamilies([.systemLarge])
    }
}

private struct UpcomingBookingWidgetView: View {
    let entry: CinnamonCompanionWidgetEntry

    var body: some View {
        ZStack {
            CinnamonWidgetBackground()

            VStack(alignment: .leading, spacing: 10) {
                CinnamonWidgetTag(title: "Cinnamon Companion")

                Text(entry.upcomingBookingTitle)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(CinnamonWidgetTheme.brandBrown)
                    .lineLimit(2)

                Text(entry.upcomingBookingSubtitle)
                    .font(.caption)
                    .foregroundStyle(CinnamonWidgetTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.propertyName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(CinnamonWidgetTheme.warmBrown)

                    Text(entry.confirmationCode)
                        .font(.caption2)
                        .foregroundStyle(CinnamonWidgetTheme.secondaryText)
                }
            }
            .padding(16)
        }
        .containerBackground(for: .widget) {
            CinnamonWidgetBackground()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(entry.upcomingBookingTitle). \(entry.upcomingBookingSubtitle). \(entry.propertyName). Confirmation code \(entry.confirmationCode).")
    }
}

private struct StaySummaryWidgetView: View {
    let entry: CinnamonCompanionWidgetEntry

    var body: some View {
        ZStack {
            CinnamonWidgetBackground()

            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 10) {
                    CinnamonWidgetTag(title: "Stay Summary")

                    Text("Welcome back, \(entry.guestName)")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(CinnamonWidgetTheme.brandBrown)
                        .lineLimit(2)

                    Text(entry.roomType)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(CinnamonWidgetTheme.warmBrown)

                    Text(entry.stayDateRange)
                        .font(.caption)
                        .foregroundStyle(CinnamonWidgetTheme.secondaryText)

                    Spacer(minLength: 0)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(entry.recommendationTitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(CinnamonWidgetTheme.warmBrown)

                    Text(entry.recommendationSubtitle)
                        .font(.caption)
                        .foregroundStyle(CinnamonWidgetTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(4)

                    Spacer(minLength: 0)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .background(CinnamonWidgetTheme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(CinnamonWidgetTheme.border, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(16)
        }
        .containerBackground(for: .widget) {
            CinnamonWidgetBackground()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Stay summary for \(entry.guestName). \(entry.roomType). Stay dates \(entry.stayDateRange). Recommendation: \(entry.recommendationSubtitle)")
    }
}

private struct StayDetailsWidgetView: View {
    let entry: CinnamonCompanionWidgetEntry

    var body: some View {
        ZStack {
            CinnamonWidgetBackground()

            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        CinnamonWidgetTag(title: "Current Stay")

                        Text(entry.propertyName)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(CinnamonWidgetTheme.brandBrown)
                            .lineLimit(2)

                        Text("\(entry.roomType) • \(entry.stayDateRange)")
                            .font(.caption)
                            .foregroundStyle(CinnamonWidgetTheme.secondaryText)
                            .lineLimit(2)
                    }

                    Spacer(minLength: 8)

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Confirmation")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(CinnamonWidgetTheme.warmBrown)

                        Text(entry.confirmationCode)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(CinnamonWidgetTheme.secondaryText)
                    }
                }

                HStack(spacing: 12) {
                    detailCard(
                        title: "Dining Promo",
                        subtitle: entry.diningPromoTitle,
                        body: entry.diningPromoSubtitle
                    )

                    detailCard(
                        title: "Next Booking",
                        subtitle: entry.nextBookingTitle,
                        body: entry.nextBookingSubtitle
                    )
                }
            }
            .padding(16)
        }
        .containerBackground(for: .widget) {
            CinnamonWidgetBackground()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(entry.propertyName). \(entry.roomType). Stay dates \(entry.stayDateRange). Dining promotion: \(entry.diningPromoSubtitle). Next booking: \(entry.nextBookingSubtitle).")
    }

    private func detailCard(title: String, subtitle: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(CinnamonWidgetTheme.warmBrown)

            Text(subtitle)
                .font(.caption.weight(.semibold))
                .foregroundStyle(CinnamonWidgetTheme.brandBrown)
                .lineLimit(2)

            Text(body)
                .font(.caption2)
                .foregroundStyle(CinnamonWidgetTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(4)

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(CinnamonWidgetTheme.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(CinnamonWidgetTheme.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

