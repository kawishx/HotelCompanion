//
//  HomeModels.swift
//  HotelCompanion
//
//  File: Features/Home/Models/HomeModels.swift
//

import Foundation

enum HomeQuickActionRoute: String, Hashable, Identifiable {
    case myStay
    case requestService
    case bookExperience
    case orderFood
    case exploreNearby
    case concierge

    var id: String { rawValue }
}

struct ActiveStaySummary: Equatable {
    let hotelName: String
    let roomType: String
    let dateRange: String
    let reservationCode: String
    let highlight: String
}

struct SmartRecommendation: Equatable {
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
    let route: HomeQuickActionRoute
}

struct UpcomingBookingPreview: Equatable {
    let title: String
    let dateRange: String
    let detail: String
}
