//
//  AppNotificationItem.swift
//  HotelCompanion
//
//  File: Core/Notifications/AppNotificationItem.swift
//

import Foundation

enum AppNotificationCategory: String {
    case booking
    case foodOrder
    case geofence
    case service
    case concierge
    case billing
    case general

    var title: String {
        switch self {
        case .booking:
            return "Booking"
        case .foodOrder:
            return "Food Order"
        case .geofence:
            return "Arrival & Exit"
        case .service:
            return "Service"
        case .concierge:
            return "Concierge"
        case .billing:
            return "Billing"
        case .general:
            return "General"
        }
    }

    var systemImage: String {
        switch self {
        case .booking:
            return "calendar.badge.clock"
        case .foodOrder:
            return "fork.knife.circle.fill"
        case .geofence:
            return "location.circle.fill"
        case .service:
            return "bell.badge.fill"
        case .concierge:
            return "message.circle.fill"
        case .billing:
            return "creditcard.circle.fill"
        case .general:
            return "bell.fill"
        }
    }
}

struct AppNotificationItem: Identifiable {
    let id: String
    let title: String
    let message: String
    let timeLabel: String
    let category: AppNotificationCategory
    let isUnread: Bool

    init(
        id: String = UUID().uuidString,
        title: String,
        message: String,
        timeLabel: String,
        category: AppNotificationCategory,
        isUnread: Bool
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.timeLabel = timeLabel
        self.category = category
        self.isUnread = isUnread
    }
}
