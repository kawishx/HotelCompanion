//
//  FirestoreDocumentMapperTests.swift
//  HotelCompanionTests
//
//  File: HotelCompanionTests/Firestore/FirestoreDocumentMapperTests.swift
//

import XCTest
@testable import HotelCompanion

final class FirestoreDocumentMapperTests: XCTestCase {
    func testDecodeUserProfileRecordFromRawDictionary() throws {
        let rawData: [String: Any] = [
            "primaryHotelID": "cinnamon-thiya",
            "fullName": "Kawish Jayawardena",
            "email": "guest@example.com",
            "phoneNumber": "+94 77 123 4567",
            "loyaltyTier": "Gold",
            "preferredLocaleIdentifier": "en_LK",
            "preferredCurrencyCode": "LKR",
            "profileImagePath": "profiles/guest-user/avatar.jpg",
            "notificationPreferences": [
                "bookingUpdatesEnabled": true,
                "diningUpdatesEnabled": true,
                "conciergeUpdatesEnabled": false,
                "promotionalMessagesEnabled": false
            ],
            "accessibilityPreferences": [
                "largeTextPreferred": true,
                "reducedMotionPreferred": false,
                "voiceAssistancePreferred": true
            ],
            "createdAt": 1_715_000_000.0,
            "updatedAt": 1_715_000_100.0
        ]

        let profile = try FirestoreDocumentMapper.decode(
            UserProfileRecord.self,
            from: rawData,
            documentID: "guest-user"
        )

        XCTAssertEqual(profile.id, "guest-user")
        XCTAssertEqual(profile.email, "guest@example.com")
        XCTAssertEqual(profile.notificationPreferences.bookingUpdatesEnabled, true)
        XCTAssertEqual(profile.accessibilityPreferences.voiceAssistancePreferred, true)
    }

    func testFirestoreMappableInitializesServiceRequestFromDictionary() {
        let rawData: [String: Any] = [
            "id": "request-001",
            "hotelID": "cinnamon-thiya",
            "guestUserID": "guest-user",
            "guest": [
                "userID": "guest-user",
                "fullName": "Test Guest",
                "email": "guest@example.com",
                "phoneNumber": NSNull()
            ],
            "stayID": NSNull(),
            "roomNumber": "508",
            "requestType": "maintenance",
            "note": "Air conditioning is noisy",
            "uploadedImageURL": "https://example.com/image.jpg",
            "priority": "high",
            "status": "open",
            "assignedTeamName": NSNull(),
            "createdAt": 1_715_000_000.0,
            "updatedAt": 1_715_000_100.0,
            "resolvedAt": NSNull()
        ]

        let request = ServiceRequestRecord(dictionary: rawData)

        XCTAssertEqual(request?.id, "request-001")
        XCTAssertEqual(request?.roomNumber, "508")
        XCTAssertEqual(request?.uploadedImageURL?.absoluteString, "https://example.com/image.jpg")
        XCTAssertEqual(request?.priority, .high)
    }

    func testFirestoreMappableDictionaryEncodesURLAndDatesForServiceRequestRecord() {
        let createdAt = Date(timeIntervalSince1970: 1_715_000_000)
        let record = ServiceRequestRecord(
            id: "request-002",
            hotelID: "cinnamon-thiya",
            guestUserID: "guest-user",
            guest: GuestSnapshot(
                userID: "guest-user",
                fullName: "Test Guest",
                email: "guest@example.com",
                phoneNumber: nil
            ),
            stayID: "stay-001",
            roomNumber: "604",
            requestType: .maintenance,
            note: "Bathroom light is flickering",
            uploadedImageURL: URL(string: "https://example.com/issue.jpg"),
            priority: .normal,
            status: .acknowledged,
            assignedTeamName: "Engineering",
            createdAt: createdAt,
            updatedAt: createdAt,
            resolvedAt: nil
        )

        let dictionary = record.asDictionary

        XCTAssertEqual(dictionary["id"] as? String, "request-002")
        XCTAssertEqual(dictionary["uploadedImageURL"] as? String, "https://example.com/issue.jpg")
        XCTAssertEqual(dictionary["createdAt"] as? Double, createdAt.timeIntervalSince1970)
    }
}
