//
//  FirestoreDateCoding.swift
//  HotelCompanion
//
//  File: Core/Firebase/Firestore/FirestoreDateCoding.swift
//

import Foundation

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

enum FirestoreDateCoding {
    static func normalizedBookingDate(_ date: Date) -> Date {
        let calendar = Calendar.current
        return calendar.date(bySetting: .second, value: 0, of: date) ?? date
    }

    static func requiredTimestamp(_ date: Date) -> Any {
        #if canImport(FirebaseFirestore)
        Timestamp(date: date)
        #else
        date.timeIntervalSince1970
        #endif
    }

    static func optionalTimestampValue(_ date: Date?) -> Any {
        if let date {
            #if canImport(FirebaseFirestore)
            return Timestamp(date: date)
            #else
            return date.timeIntervalSince1970
            #endif
        }

        return NSNull()
    }

    static func persistedTimestampValue(_ date: Date?) -> Any {
        if let date {
            #if canImport(FirebaseFirestore)
            return Timestamp(date: date)
            #else
            return date.timeIntervalSince1970
            #endif
        }

        #if canImport(FirebaseFirestore)
        return FieldValue.serverTimestamp()
        #else
        return Date().timeIntervalSince1970
        #endif
    }

    static func preparedBookingData(from booking: BookingRecord) throws -> [String: Any] {
        var data = try FirestoreDocumentMapper.encode(booking)

        data["startDate"] = requiredTimestamp(booking.startDate)
        data["endDate"] = optionalTimestampValue(booking.endDate)
        data["createdAt"] = persistedTimestampValue(booking.createdAt)
        data["updatedAt"] = persistedTimestampValue(booking.updatedAt)

        data.removeValue(forKey: "id")
        return data
    }

    static func preparedServiceRequestData(from request: ServiceRequestRecord) throws -> [String: Any] {
        var data = try FirestoreDocumentMapper.encode(request)

        data["createdAt"] = persistedTimestampValue(request.createdAt)
        data["updatedAt"] = persistedTimestampValue(request.updatedAt)
        data["resolvedAt"] = optionalTimestampValue(request.resolvedAt)

        data.removeValue(forKey: "id")
        return data
    }

    static func preparedDiningOrderData(from order: DiningOrderRecord) throws -> [String: Any] {
        var data = try FirestoreDocumentMapper.encode(order)

        data["requestedFor"] = optionalTimestampValue(order.requestedFor)
        data["createdAt"] = persistedTimestampValue(order.createdAt)
        data["updatedAt"] = persistedTimestampValue(order.updatedAt)
        data["fulfilledAt"] = optionalTimestampValue(order.fulfilledAt)

        data.removeValue(forKey: "id")
        return data
    }

    static func preparedConciergeRequestData(from request: ConciergeRequestRecord) throws -> [String: Any] {
        var data = try FirestoreDocumentMapper.encode(request)

        data["requestedFor"] = optionalTimestampValue(request.requestedFor)
        data["createdAt"] = persistedTimestampValue(request.createdAt)
        data["updatedAt"] = persistedTimestampValue(request.updatedAt)

        data.removeValue(forKey: "id")
        return data
    }

    static func preparedNotificationData(from notification: NotificationRecord) throws -> [String: Any] {
        var data = try FirestoreDocumentMapper.encode(notification)

        data["sentAt"] = requiredTimestamp(notification.sentAt)
        data["readAt"] = optionalTimestampValue(notification.readAt)
        data["createdAt"] = persistedTimestampValue(notification.createdAt)
        data["updatedAt"] = persistedTimestampValue(notification.updatedAt)

        data.removeValue(forKey: "id")
        return data
    }

    static func preparedActivityTimelineData(from event: ActivityTimelineRecord) throws -> [String: Any] {
        var data = try FirestoreDocumentMapper.encode(event)

        data["occurredAt"] = requiredTimestamp(event.occurredAt)
        data["createdAt"] = persistedTimestampValue(event.createdAt)

        data.removeValue(forKey: "id")
        return data
    }

    static func preparedBillingSummaryData(from summary: BillingSummaryRecord) throws -> [String: Any] {
        var data = try FirestoreDocumentMapper.encode(summary)

        data["issuedAt"] = requiredTimestamp(summary.issuedAt)
        data["dueAt"] = optionalTimestampValue(summary.dueAt)
        data["createdAt"] = persistedTimestampValue(summary.createdAt)
        data["updatedAt"] = persistedTimestampValue(summary.updatedAt)
        data["lineItems"] = summary.lineItems.map { lineItem in
            var lineItemData = (try? FirestoreDocumentMapper.encode(lineItem)) ?? [:]
            lineItemData["postedAt"] = optionalTimestampValue(lineItem.postedAt)
            return lineItemData
        }

        data.removeValue(forKey: "id")
        return data
    }

    static func preparedSavedAttractionData(from attraction: SavedAttractionRecord) throws -> [String: Any] {
        var data = try FirestoreDocumentMapper.encode(attraction)

        data["savedAt"] = requiredTimestamp(attraction.savedAt)
        data["createdAt"] = persistedTimestampValue(attraction.createdAt)
        data["updatedAt"] = persistedTimestampValue(attraction.updatedAt)

        data.removeValue(forKey: "id")
        return data
    }
}
