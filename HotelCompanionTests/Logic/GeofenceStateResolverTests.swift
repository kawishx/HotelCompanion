//
//  GeofenceStateResolverTests.swift
//  HotelCompanionTests
//
//  File: HotelCompanionTests/Logic/GeofenceStateResolverTests.swift
//

import CoreLocation
import XCTest
@testable import HotelCompanion

final class GeofenceStateResolverTests: XCTestCase {
    func testEnteredHotelSnapshotSetsInsideStateAndWelcomeMessage() {
        let snapshot = GeofenceStateResolver.snapshot(for: .enteredHotel, hotelName: "Cinnamon Thiya")

        XCTAssertEqual(snapshot.regionState, .inside)
        XCTAssertEqual(snapshot.lastEvent, .didEnterHotel)
        XCTAssertTrue(snapshot.statusMessage.contains("Welcome to Cinnamon Thiya"))
    }

    func testDeniedAuthorizationReturnsSettingsGuidance() {
        let message = GeofenceStateResolver.statusMessage(
            for: .denied,
            isMonitoringHotelRegion: false,
            currentRegionState: .unknown
        )

        XCTAssertTrue(message.contains("Enable Always Location in Settings"))
    }
}
