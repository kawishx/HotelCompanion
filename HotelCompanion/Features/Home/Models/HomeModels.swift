//
//  HomeModels.swift
//  HotelCompanion
//
//  File: Features/Home/Models/HomeModels.swift
//

import Foundation

struct ActiveStaySummary {
    let hotelName: String
    let roomType: String
    let dateRange: String
    let reservationCode: String
    let highlight: String
}

struct SmartRecommendation {
    let title: String
    let summary: String
    let detail: String
    let systemImage: String
    let actionTitle: String
}

struct HomeQuickAction: Identifiable {
    let id = UUID()
    let title: String
    let systemImage: String
    let accessibilityLabel: String
}

struct UpcomingBookingPreview {
    let title: String
    let dateRange: String
    let detail: String
}

struct NotificationPreview: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let timeLabel: String
    let systemImage: String
    let isUnread: Bool
}

