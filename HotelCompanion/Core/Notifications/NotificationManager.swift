//
//  NotificationManager.swift
//  HotelCompanion
//
//  File: Core/Notifications/NotificationManager.swift
//

import Combine
import Foundation
import UserNotifications

final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private let notificationCenter: UNUserNotificationCenter

    init(notificationCenter: UNUserNotificationCenter = .current()) {
        self.notificationCenter = notificationCenter
        refreshAuthorizationStatus()
    }

    var notificationsEnabled: Bool {
        authorizationStatus == .authorized ||
        authorizationStatus == .provisional ||
        authorizationStatus == .ephemeral
    }

    func requestNotificationPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] _, _ in
            DispatchQueue.main.async {
                self?.refreshAuthorizationStatus()
            }
        }
    }

    func refreshAuthorizationStatus() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.authorizationStatus = settings.authorizationStatus
            }
        }
    }

    func scheduleLocalNotification(
        identifier: String = UUID().uuidString,
        title: String,
        body: String,
        timeInterval: TimeInterval = 1,
        userInfo: [AnyHashable: Any] = [:]
    ) {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.authorizationStatus = settings.authorizationStatus

                guard
                    settings.authorizationStatus == .authorized ||
                    settings.authorizationStatus == .provisional ||
                    settings.authorizationStatus == .ephemeral
                else {
                    return
                }

                let content = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = .default
                content.userInfo = userInfo

                let safeTimeInterval = max(1, timeInterval)
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: safeTimeInterval, repeats: false)
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

                self?.notificationCenter.add(request)
            }
        }
    }

    func scheduleBookingReminderNotification(
        bookingTitle: String,
        reminderBody: String,
        timeInterval: TimeInterval = 5
    ) {
        scheduleLocalNotification(
            identifier: "booking-reminder-\(UUID().uuidString)",
            title: "Booking Reminder",
            body: "\(bookingTitle): \(reminderBody)",
            timeInterval: timeInterval,
            userInfo: ["type": "bookingReminder"]
        )
    }

    func scheduleFoodOrderStatusNotification(
        orderTitle: String,
        statusMessage: String,
        timeInterval: TimeInterval = 3
    ) {
        scheduleLocalNotification(
            identifier: "food-order-status-\(UUID().uuidString)",
            title: "Food Order Update",
            body: "\(orderTitle): \(statusMessage)",
            timeInterval: timeInterval,
            userInfo: ["type": "foodOrderStatus"]
        )
    }

    func scheduleGeofenceWelcomeNotification(hotelName: String) {
        scheduleLocalNotification(
            identifier: "geofence-welcome-\(UUID().uuidString)",
            title: "Welcome to \(hotelName)",
            body: "You're at the hotel. Open Cinnamon Companion to complete check-in and view your stay.",
            timeInterval: 1,
            userInfo: ["type": "geofenceWelcome"]
        )
    }

    func scheduleGeofenceExitNotification(hotelName: String) {
        scheduleLocalNotification(
            identifier: "geofence-exit-\(UUID().uuidString)",
            title: "Need help before you go?",
            body: "Leaving \(hotelName)? Open Cinnamon Companion for concierge support, transport help, or a smooth checkout.",
            timeInterval: 1,
            userInfo: ["type": "geofenceExit"]
        )
    }

    func mockNotifications() -> [AppNotificationItem] {
        [
            AppNotificationItem(
                title: "Booking Reminder",
                message: "Oceanfront Suite check-in begins at 2:00 PM tomorrow.",
                timeLabel: "Just now",
                category: .booking,
                isUnread: true
            ),
            AppNotificationItem(
                title: "Food Order Update",
                message: "Your in-room dinner order is being prepared by the kitchen.",
                timeLabel: "12 min ago",
                category: .foodOrder,
                isUnread: true
            ),
            AppNotificationItem(
                title: "Welcome Nearby",
                message: "You are approaching Cinnamon Thiya. Complete check-in when you arrive.",
                timeLabel: "28 min ago",
                category: .geofence,
                isUnread: false
            ),
            AppNotificationItem(
                title: "Guest Services",
                message: "Housekeeping completed your evening refresh request.",
                timeLabel: "1 hr ago",
                category: .service,
                isUnread: false
            )
        ]
    }
}
