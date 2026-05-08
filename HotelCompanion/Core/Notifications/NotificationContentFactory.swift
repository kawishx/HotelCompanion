//
//  NotificationContentFactory.swift
//  HotelCompanion
//
//  File: Core/Notifications/NotificationContentFactory.swift
//

import Foundation

struct LocalNotificationPayload: Equatable {
    let identifier: String
    let title: String
    let body: String
    let timeInterval: TimeInterval
    let userInfo: [String: String]
}

enum NotificationContentFactory {
    static func bookingReminder(
        bookingTitle: String,
        reminderBody: String,
        timeInterval: TimeInterval
    ) -> LocalNotificationPayload {
        LocalNotificationPayload(
            identifier: "booking-reminder-\(UUID().uuidString)",
            title: "Booking Reminder",
            body: "\(bookingTitle): \(reminderBody)",
            timeInterval: sanitizedTimeInterval(timeInterval),
            userInfo: ["type": "bookingReminder"]
        )
    }

    static func foodOrderStatus(
        orderTitle: String,
        statusMessage: String,
        timeInterval: TimeInterval
    ) -> LocalNotificationPayload {
        LocalNotificationPayload(
            identifier: "food-order-status-\(UUID().uuidString)",
            title: "Food Order Update",
            body: "\(orderTitle): \(statusMessage)",
            timeInterval: sanitizedTimeInterval(timeInterval),
            userInfo: ["type": "foodOrderStatus"]
        )
    }

    static func geofenceWelcome(hotelName: String) -> LocalNotificationPayload {
        LocalNotificationPayload(
            identifier: "geofence-welcome-\(UUID().uuidString)",
            title: "Welcome to \(hotelName)",
            body: "You're at the hotel. Open Cinnamon Companion to complete check-in and view your stay.",
            timeInterval: 1,
            userInfo: ["type": "geofenceWelcome"]
        )
    }

    static func geofenceExit(hotelName: String) -> LocalNotificationPayload {
        LocalNotificationPayload(
            identifier: "geofence-exit-\(UUID().uuidString)",
            title: "Need help before you go?",
            body: "Leaving \(hotelName)? Open Cinnamon Companion for concierge support, transport help, or a smooth checkout.",
            timeInterval: 1,
            userInfo: ["type": "geofenceExit"]
        )
    }

    static func sanitizedTimeInterval(_ timeInterval: TimeInterval) -> TimeInterval {
        max(1, timeInterval)
    }
}
