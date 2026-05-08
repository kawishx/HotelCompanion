//
//  RecommendationEngineTests.swift
//  HotelCompanionTests
//
//  File: HotelCompanionTests/Logic/RecommendationEngineTests.swift
//

import XCTest
@testable import HotelCompanion

final class RecommendationEngineTests: XCTestCase {
    func testEveningRecommendationPrefersSunsetExperience() {
        let context = RecommendationContext(
            activeStay: ActiveStaySummary(
                hotelName: "Cinnamon Thiya",
                roomType: "Oceanfront Suite",
                dateRange: "21 Apr - 24 Apr",
                reservationCode: "CC48291",
                highlight: "Late checkout approved."
            ),
            upcomingBooking: nil,
            currentDate: Date(timeIntervalSince1970: 1_715_157_200) // 2024-05-09 17:00:00 UTC
        )

        let recommendation = RecommendationEngine.makeRecommendation(for: context)

        XCTAssertEqual(recommendation.summary, "Reserve a sunset river cruise for this evening.")
        XCTAssertEqual(recommendation.actionTitle, "Book This Experience")
    }

    func testDepartureDayRecommendationPrefersTransferAdjacentDining() {
        let context = RecommendationContext(
            activeStay: ActiveStaySummary(
                hotelName: "Cinnamon Thiya",
                roomType: "Oceanfront Suite",
                dateRange: "21 Apr - 24 Apr",
                reservationCode: "CC48291",
                highlight: "Late checkout approved."
            ),
            upcomingBooking: UpcomingBookingPreview(
                title: "Airport Transfer",
                dateRange: "24 Apr • 2:30 PM",
                detail: "Private transfer."
            ),
            currentDate: Date(timeIntervalSince1970: 1_715_128_400) // 2024-05-09 09:00:00 UTC
        )

        let recommendation = RecommendationEngine.makeRecommendation(for: context)

        XCTAssertEqual(recommendation.actionTitle, "Plan Departure Dining")
        XCTAssertTrue(recommendation.summary.contains("breakfast"))
    }

    func testFallbackRecommendationPrefersWellnessPlan() {
        let context = RecommendationContext(
            activeStay: ActiveStaySummary(
                hotelName: "Cinnamon Thiya",
                roomType: "Oceanfront Suite",
                dateRange: "21 Apr - 24 Apr",
                reservationCode: "CC48291",
                highlight: "Late checkout approved."
            ),
            upcomingBooking: UpcomingBookingPreview(
                title: "Private Dinner",
                dateRange: "23 Apr • 8:00 PM",
                detail: "Chef's tasting menu."
            ),
            currentDate: Date(timeIntervalSince1970: 1_715_128_400)
        )

        let recommendation = RecommendationEngine.makeRecommendation(for: context)

        XCTAssertEqual(recommendation.actionTitle, "Reserve Wellness")
        XCTAssertTrue(recommendation.summary.localizedCaseInsensitiveContains("wellness"))
    }
}
