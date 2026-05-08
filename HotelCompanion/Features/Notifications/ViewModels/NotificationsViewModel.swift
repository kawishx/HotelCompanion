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
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let notificationManager: NotificationManager
    private let notificationFeedService: NotificationFeedServicing
    private var cancellables: Set<AnyCancellable> = []
    private var notificationRecordsByID: [String: NotificationRecord] = [:]

    init(
        notificationManager: NotificationManager? = nil,
        notificationFeedService: NotificationFeedServicing? = nil
    ) {
        self.notificationManager = notificationManager ?? .shared
        self.notificationFeedService = notificationFeedService ?? NotificationFeedService.shared
        bind()
        refresh()
    }

    var notificationsEnabled: Bool {
        authorizationStatus == .authorized ||
        authorizationStatus == .provisional ||
        authorizationStatus == .ephemeral
    }

    var isEmpty: Bool {
        !isLoading && notifications.isEmpty && errorMessage == nil
    }

    func refresh() {
        notificationManager.refreshAuthorizationStatus()
        Task {
            await loadNotificationFeed()
        }
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

    func markAsRead(_ item: AppNotificationItem) async {
        guard let record = backingRecord(for: item) else { return }

        do {
            let updated = try await notificationFeedService.markNotificationAsRead(record)
            replaceNotification(with: updated)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadNotificationFeed() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let records = try await notificationFeedService.fetchCurrentUserNotifications()
            notifications = records.map(AppNotificationItem.init(record:))
            notificationRecordsByID = Dictionary(uniqueKeysWithValues: records.map { ($0.id, $0) })
        } catch {
            notifications = []
            errorMessage = error.localizedDescription
        }
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

    private func updateStatusMessage(for status: UNAuthorizationStatus) {
        switch status {
        case .authorized, .provisional, .ephemeral:
            statusMessage = "Notifications are active. You'll receive updates for bookings, dining, concierge, and billing."
        case .denied:
            statusMessage = "Notifications are turned off. Enable them in Settings to receive stay updates."
        case .notDetermined:
            statusMessage = "Enable notifications to stay updated on bookings, dining, and arrivals."
        @unknown default:
            statusMessage = "Notification status is currently unavailable."
        }
    }

    private func backingRecord(for item: AppNotificationItem) -> NotificationRecord? {
        notificationRecordsByID[item.id]
    }

    private func replaceNotification(with record: NotificationRecord) {
        notificationRecordsByID[record.id] = record
        notifications.removeAll { $0.id == record.id }
        notifications.append(AppNotificationItem(record: record))
        notifications.sort { lhs, rhs in
            let lhsDate = notificationRecordsByID[lhs.id]?.sentAt ?? .distantPast
            let rhsDate = notificationRecordsByID[rhs.id]?.sentAt ?? .distantPast
            return lhsDate > rhsDate
        }
    }
}

private extension AppNotificationItem {
    init(record: NotificationRecord) {
        self.init(
            id: record.id,
            title: record.title,
            message: record.body,
            timeLabel: record.sentAt.formatted(date: .abbreviated, time: .shortened),
            category: record.type.notificationCategory,
            isUnread: !record.isRead
        )
    }
}

private extension NotificationType {
    var notificationCategory: AppNotificationCategory {
        switch self {
        case .booking:
            return .booking
        case .dining:
            return .foodOrder
        case .service:
            return .service
        case .concierge:
            return .concierge
        case .billing:
            return .billing
        case .geofence:
            return .geofence
        case .system:
            return .general
        }
    }
}
