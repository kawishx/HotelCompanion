//
//  HomeViewModel.swift
//  HotelCompanion
//
//  File: Features/Home/ViewModels/HomeViewModel.swift
//

import Combine
import Foundation

final class HomeViewModel: ObservableObject {
    @Published private(set) var greetingTitle = "Good afternoon, Kawish"
    @Published private(set) var greetingSubtitle = "Your stay at Cinnamon Bentota Beach is unfolding beautifully."
    @Published private(set) var activeStay = ActiveStaySummary(
        hotelName: "Cinnamon Bentota Beach",
        roomType: "Oceanfront Suite",
        dateRange: "21 Apr - 24 Apr",
        reservationCode: "Reservation CC48291",
        highlight: "Late checkout has been pre-approved until 2:00 PM."
    )
    @Published private(set) var recommendation = SmartRecommendation(
        title: "Smart recommendation",
        summary: "Reserve a sunset river cruise for this evening.",
        detail: "It aligns with your itinerary, keeps travel minimal, and pairs perfectly with your dinner reservation at 8:00 PM.",
        systemImage: "sparkles.square.fill",
        actionTitle: "Book This Experience"
    )
    @Published private(set) var quickActions: [HomeQuickAction] = [
        HomeQuickAction(title: "My Stay", systemImage: "bed.double.fill", accessibilityLabel: "Open My Stay", route: .myStay),
        HomeQuickAction(title: "Request Service", systemImage: "bell.badge.fill", accessibilityLabel: "Request guest service", route: .requestService),
        HomeQuickAction(title: "Book Experience", systemImage: "sparkles", accessibilityLabel: "Book an experience", route: .bookExperience),
        HomeQuickAction(title: "Order Food", systemImage: "fork.knife", accessibilityLabel: "Order food", route: .orderFood),
        HomeQuickAction(title: "Explore Nearby", systemImage: "map.fill", accessibilityLabel: "Explore nearby places", route: .exploreNearby),
        HomeQuickAction(title: "Concierge", systemImage: "message.fill", accessibilityLabel: "Contact concierge", route: .concierge)
    ]
    @Published private(set) var upcomingBooking = UpcomingBookingPreview(
        title: "Airport Transfer",
        dateRange: "24 Apr • 2:30 PM",
        detail: "Private departure transfer to Bandaranaike International Airport."
    )
    @Published private(set) var notifications: [AppNotificationItem]

    init(notificationManager: NotificationManager = .shared, currentDate: Date = Date()) {
        notifications = Array(notificationManager.mockNotifications().prefix(2))
        recommendation = RecommendationEngine.makeRecommendation(
            for: RecommendationContext(
                activeStay: activeStay,
                upcomingBooking: upcomingBooking,
                currentDate: currentDate
            )
        )
    }
}
