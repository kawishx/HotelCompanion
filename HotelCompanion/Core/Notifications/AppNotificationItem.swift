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
        case .general:
            return "bell.fill"
        }
    }
}

struct AppNotificationItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let timeLabel: String
    let category: AppNotificationCategory
    let isUnread: Bool
}

