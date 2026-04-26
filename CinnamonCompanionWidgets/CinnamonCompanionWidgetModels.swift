//
//  CinnamonCompanionWidgetModels.swift
//  CinnamonCompanionWidgets
//
//  File: CinnamonCompanionWidgets/CinnamonCompanionWidgetModels.swift
//

import Foundation
import WidgetKit

struct CinnamonCompanionWidgetEntry: TimelineEntry {
    let date: Date
    let guestName: String
    let propertyName: String
    let roomType: String
    let stayDateRange: String
    let confirmationCode: String
    let upcomingBookingTitle: String
    let upcomingBookingSubtitle: String
    let recommendationTitle: String
    let recommendationSubtitle: String
    let diningPromoTitle: String
    let diningPromoSubtitle: String
    let nextBookingTitle: String
    let nextBookingSubtitle: String

    static let mock = CinnamonCompanionWidgetEntry(
        date: .now,
        guestName: "Kawish",
        propertyName: "Cinnamon Bentota Beach",
        roomType: "Oceanfront Suite",
        stayDateRange: "12 May - 15 May",
        confirmationCode: "CC48291",
        upcomingBookingTitle: "Upcoming Booking",
        upcomingBookingSubtitle: "Oceanfront Suite • 12 May at 2:00 PM",
        recommendationTitle: "Tonight's Recommendation",
        recommendationSubtitle: "Reserve a sunset river cruise before 5:30 PM.",
        diningPromoTitle: "Dining Highlight",
        diningPromoSubtitle: "Lagoon Grill tasting menu with a complimentary dessert.",
        nextBookingTitle: "Next Reservation",
        nextBookingSubtitle: "Airport transfer • 15 May at 11:00 AM"
    )
}

struct CinnamonCompanionTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> CinnamonCompanionWidgetEntry {
        .mock
    }

    func getSnapshot(in context: Context, completion: @escaping (CinnamonCompanionWidgetEntry) -> Void) {
        completion(.mock)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CinnamonCompanionWidgetEntry>) -> Void) {
        let currentDate = Date()
        let entries = [
            CinnamonCompanionWidgetEntry.mock,
            CinnamonCompanionWidgetEntry(
                date: Calendar.current.date(byAdding: .hour, value: 2, to: currentDate) ?? currentDate,
                guestName: "Kawish",
                propertyName: "Cinnamon Bentota Beach",
                roomType: "Oceanfront Suite",
                stayDateRange: "12 May - 15 May",
                confirmationCode: "CC48291",
                upcomingBookingTitle: "Arrival Today",
                upcomingBookingSubtitle: "Suite check-in begins at 2:00 PM.",
                recommendationTitle: "Wellness Recommendation",
                recommendationSubtitle: "Secure the spa ritual before evening slots close.",
                diningPromoTitle: "Dining Highlight",
                diningPromoSubtitle: "Private beachfront dinner available tonight.",
                nextBookingTitle: "Next Reservation",
                nextBookingSubtitle: "Airport transfer • 15 May at 11:00 AM"
            )
        ]

        let refreshDate = Calendar.current.date(byAdding: .hour, value: 4, to: currentDate) ?? currentDate
        completion(Timeline(entries: entries, policy: .after(refreshDate)))
    }
}

