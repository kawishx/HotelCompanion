//
//  NotificationFeedService.swift
//  HotelCompanion
//
//  File: Core/Firebase/Firestore/Notifications/NotificationFeedService.swift
//

import Foundation

protocol NotificationFeedServicing {
    func fetchCurrentUserNotifications() async throws -> [NotificationRecord]
    func markNotificationAsRead(_ notification: NotificationRecord) async throws -> NotificationRecord
}

final class NotificationFeedService: NotificationFeedServicing {
    static let shared = NotificationFeedService()

    private let remoteStore: FirestoreRemoteStoring
    private let sessionCoordinator: FirebaseSessionCoordinating
    private let dateProvider: DateProviding
    private var fallbackNotificationsByUserID: [String: [NotificationRecord]] = [:]

    init(
        remoteStore: FirestoreRemoteStoring = FirestoreRemoteStore.shared,
        sessionCoordinator: FirebaseSessionCoordinating = FirebaseSessionCoordinator.shared,
        dateProvider: DateProviding = SystemDateProvider()
    ) {
        self.remoteStore = remoteStore
        self.sessionCoordinator = sessionCoordinator
        self.dateProvider = dateProvider
    }

    func fetchCurrentUserNotifications() async throws -> [NotificationRecord] {
        let session = resolvedSession()

        if shouldUseFallback(for: session) {
            return fallbackNotifications(for: session)
        }

        do {
            let records: [NotificationRecord] = try await remoteStore.fetchUserSubcollection(
                userID: session.id,
                subcollection: .notifications,
                orderBy: FirestoreDocumentField.sentAt,
                descending: true
            )

            return records.isEmpty ? fallbackNotifications(for: session) : records
        } catch let error as FirestoreRemoteStoreError where error == .unavailable {
            return fallbackNotifications(for: session)
        }
    }

    func markNotificationAsRead(_ notification: NotificationRecord) async throws -> NotificationRecord {
        let updated = NotificationRecord(
            id: notification.id,
            userID: notification.userID,
            hotelID: notification.hotelID,
            type: notification.type,
            title: notification.title,
            body: notification.body,
            relatedDocumentPath: notification.relatedDocumentPath,
            deepLinkRoute: notification.deepLinkRoute,
            isRead: true,
            sentAt: notification.sentAt,
            readAt: notification.readAt ?? dateProvider.now,
            createdAt: notification.createdAt,
            updatedAt: dateProvider.now
        )

        let session = resolvedSession()

        if shouldUseFallback(for: session) {
            return storeFallback(updated, for: session)
        }

        let data = try FirestoreDateCoding.preparedNotificationData(from: updated)
        do {
            try await remoteStore.setDocument(
                at: FirestorePath.userSubcollectionDocument(
                    userID: session.id,
                    subcollection: .notifications,
                    documentID: updated.id
                ),
                data: data,
                merge: true
            )

            return updated
        } catch let error as FirestoreRemoteStoreError where error == .unavailable {
            return storeFallback(updated, for: session)
        }
    }
}

private extension NotificationFeedService {
    func resolvedSession() -> UserSession {
        sessionCoordinator.resolvedSession()
    }

    func shouldUseFallback(for session: UserSession) -> Bool {
        sessionCoordinator.canUseFallback(for: session) || !remoteStore.isAvailable()
    }

    func fallbackNotifications(for session: UserSession) -> [NotificationRecord] {
        if let existing = fallbackNotificationsByUserID[session.id] {
            return existing.sorted { $0.sentAt > $1.sentAt }
        }

        let seeded = sampleNotifications(for: session)
        fallbackNotificationsByUserID[session.id] = seeded
        return seeded.sorted { $0.sentAt > $1.sentAt }
    }

    func storeFallback(_ notification: NotificationRecord, for session: UserSession) -> NotificationRecord {
        var notifications = fallbackNotifications(for: session).filter { $0.id != notification.id }
        notifications.append(notification)
        fallbackNotificationsByUserID[session.id] = notifications
        return notification
    }

    func sampleNotifications(for session: UserSession) -> [NotificationRecord] {
        let now = Date()

        return [
            NotificationRecord(
                id: "notification-sample-001",
                userID: session.id,
                hotelID: "cinnamon-thiya",
                type: .booking,
                title: "Experience confirmed",
                body: "Your sunset river cruise is confirmed for 5:30 PM this evening.",
                relatedDocumentPath: FirestorePath.hotelSubcollection(hotelID: "cinnamon-thiya", subcollection: .bookings) + "/booking-sample-001",
                deepLinkRoute: "bookings",
                isRead: false,
                sentAt: Calendar.current.date(byAdding: .minute, value: -8, to: now) ?? now,
                readAt: nil,
                createdAt: Calendar.current.date(byAdding: .minute, value: -8, to: now),
                updatedAt: Calendar.current.date(byAdding: .minute, value: -8, to: now)
            ),
            NotificationRecord(
                id: "notification-sample-002",
                userID: session.id,
                hotelID: "cinnamon-thiya",
                type: .dining,
                title: "Dining order update",
                body: "Your in-room dinner order is now out for delivery.",
                relatedDocumentPath: FirestorePath.hotelSubcollection(hotelID: "cinnamon-thiya", subcollection: .diningOrders) + "/dining-order-sample-001",
                deepLinkRoute: "dining",
                isRead: true,
                sentAt: Calendar.current.date(byAdding: .minute, value: -32, to: now) ?? now,
                readAt: Calendar.current.date(byAdding: .minute, value: -25, to: now),
                createdAt: Calendar.current.date(byAdding: .minute, value: -32, to: now),
                updatedAt: Calendar.current.date(byAdding: .minute, value: -25, to: now)
            ),
            NotificationRecord(
                id: "notification-sample-003",
                userID: session.id,
                hotelID: "cinnamon-thiya",
                type: .billing,
                title: "Billing summary refreshed",
                body: "Your current folio now includes dinner at Lagoon Grill.",
                relatedDocumentPath: FirestorePath.hotelSubcollection(hotelID: "cinnamon-thiya", subcollection: .billingSummaries) + "/billing-sample-001",
                deepLinkRoute: "billing",
                isRead: false,
                sentAt: Calendar.current.date(byAdding: .hour, value: -2, to: now) ?? now,
                readAt: nil,
                createdAt: Calendar.current.date(byAdding: .hour, value: -2, to: now),
                updatedAt: Calendar.current.date(byAdding: .hour, value: -2, to: now)
            )
        ]
    }
}
