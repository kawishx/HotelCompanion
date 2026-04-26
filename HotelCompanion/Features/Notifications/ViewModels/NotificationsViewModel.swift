//
//  NotificationsViewModel.swift
//  HotelCompanion
//
//  File: Features/Notifications/ViewModels/NotificationsViewModel.swift
//

import Combine
import Foundation
import UserNotifications

@MainActor
final class NotificationsViewModel: ObservableObject {
    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published private(set) var notifications: [AppNotificationItem] = []
    @Published private(set) var statusMessage = "Enable notifications to stay updated on bookings, dining, and arrivals."

    private let notificationManager: NotificationManager
    private var cancellables: Set<AnyCancellable> = []

    init(notificationManager: NotificationManager = .shared) {
        self.notificationManager = notificationManager
        bind()
        loadMockNotifications()
        refresh()
    }

    var notificationsEnabled: Bool {
        authorizationStatus == .authorized ||
        authorizationStatus == .provisional ||
        authorizationStatus == .ephemeral
    }

    func refresh() {
        notificationManager.refreshAuthorizationStatus()
        loadMockNotifications()
    }

    func requestPermission() {
        notificationManager.requestNotificationPermission()
    }

    func scheduleBookingReminderPreview() {
        notificationManager.scheduleBookingReminderNotification(
            bookingTitle: "Oceanfront Suite",
            reminderBody: "Check-in begins tomorrow at 2:00 PM.",
            timeInterval: 2
        )
    }

    func scheduleFoodOrderPreview() {
        notificationManager.scheduleFoodOrderStatusNotification(
            orderTitle: "In-Room Dinner",
            statusMessage: "Your order is on the way to your suite.",
            timeInterval: 2
        )
    }

    func scheduleGeofenceWelcomePreview() {
        notificationManager.scheduleGeofenceWelcomeNotification(hotelName: "Cinnamon Thiya")
    }

    private func bind() {
        notificationManager.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.authorizationStatus = status
                self?.updateStatusMessage(for: status)
            }
            .store(in: &cancellables)
    }

    private func loadMockNotifications() {
        notifications = notificationManager.mockNotifications()
    }

    private func updateStatusMessage(for status: UNAuthorizationStatus) {
        switch status {
        case .authorized, .provisional, .ephemeral:
            statusMessage = "Notifications are active. You'll receive updates for bookings, food orders, and hotel arrivals."
        case .denied:
            statusMessage = "Notifications are turned off. Enable them in Settings to receive stay updates."
        case .notDetermined:
            statusMessage = "Enable notifications to stay updated on bookings, dining, and arrivals."
        @unknown default:
            statusMessage = "Notification status is currently unavailable."
        }
    }
}

