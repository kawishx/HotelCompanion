//
//  RecommendationEngine.swift
//  HotelCompanion
//
//  File: Features/Home/Services/RecommendationEngine.swift
//

import Foundation

struct RecommendationContext {
    let activeStay: ActiveStaySummary
    let upcomingBooking: UpcomingBookingPreview?
    let currentDate: Date
}

enum RecommendationEngine {
    static func makeRecommendation(for context: RecommendationContext) -> SmartRecommendation {
        let hour = Calendar.current.component(.hour, from: context.currentDate)

        if (16...19).contains(hour) {
            return SmartRecommendation(
                title: "Smart recommendation",
                summary: "Reserve a sunset river cruise for this evening.",
                detail: "It aligns with your itinerary, keeps travel minimal, and pairs perfectly with your dinner reservation at 8:00 PM.",
                systemImage: "sparkles.square.fill",
                actionTitle: "Book This Experience"
            )
        }

        if let upcomingBooking = context.upcomingBooking,
           upcomingBooking.title.localizedCaseInsensitiveContains("Airport Transfer") {
            return SmartRecommendation(
                title: "Smart recommendation",
                summary: "Confirm your departure lounge breakfast.",
                detail: "Your upcoming airport transfer makes an in-room breakfast or takeaway morning set a seamless addition to checkout day.",
                systemImage: "car.fill.badge.clock",
                actionTitle: "Plan Departure Dining"
            )
        }

        return SmartRecommendation(
            title: "Smart recommendation",
            summary: "Schedule an oceanfront wellness ritual tomorrow morning.",
            detail: "A calm early session complements your current stay pace and leaves the rest of the day open for dining and nearby exploration.",
            systemImage: "leaf.circle.fill",
            actionTitle: "Reserve Wellness"
        )
    }
}
