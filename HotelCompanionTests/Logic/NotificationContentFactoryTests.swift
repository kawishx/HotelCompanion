//
//  NotificationContentFactoryTests.swift
//  HotelCompanionTests
//
//  File: HotelCompanionTests/Logic/NotificationContentFactoryTests.swift
//

import XCTest
@testable import HotelCompanion

final class NotificationContentFactoryTests: XCTestCase {
    func testBookingReminderPayloadUsesSafeMinimumTimeInterval() {
        let payload = NotificationContentFactory.bookingReminder(
            bookingTitle: "Oceanfront Suite",
            reminderBody: "Check-in begins tomorrow.",
            timeInterval: 0.25
        )

        XCTAssertEqual(payload.title, "Booking Reminder")
        XCTAssertEqual(payload.body, "Oceanfront Suite: Check-in begins tomorrow.")
        XCTAssertEqual(payload.timeInterval, 1)
        XCTAssertEqual(payload.userInfo["type"], "bookingReminder")
        XCTAssertTrue(payload.identifier.hasPrefix("booking-reminder-"))
    }

    func testGeofenceExitPayloadIncludesHotelNameAndType() {
        let payload = NotificationContentFactory.geofenceExit(hotelName: "Cinnamon Thiya")

        XCTAssertEqual(payload.userInfo["type"], "geofenceExit")
        XCTAssertTrue(payload.body.contains("Cinnamon Thiya"))
    }

    func testFoodOrderStatusPayloadUsesProvidedContent() {
        let payload = NotificationContentFactory.foodOrderStatus(
            orderTitle: "Lagoon Grill Order",
            statusMessage: "Your order is out for delivery.",
            timeInterval: 15
        )

        XCTAssertEqual(payload.title, "Food Order Update")
        XCTAssertEqual(payload.body, "Lagoon Grill Order: Your order is out for delivery.")
        XCTAssertEqual(payload.timeInterval, 15)
        XCTAssertEqual(payload.userInfo["type"], "foodOrderStatus")
    }
}
