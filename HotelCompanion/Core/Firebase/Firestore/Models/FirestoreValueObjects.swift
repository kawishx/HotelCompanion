//
//  FirestoreValueObjects.swift
//  HotelCompanion
//
//  File: Core/Firebase/Firestore/Models/FirestoreValueObjects.swift
//

import Foundation

struct AddressSnapshot: Codable, Hashable, Sendable {
    let line1: String
    let line2: String?
    let city: String
    let stateOrProvince: String?
    let postalCode: String?
    let countryCode: String
}

struct GeoCoordinateSnapshot: Codable, Hashable, Sendable {
    let latitude: Double
    let longitude: Double
}

struct MoneyAmount: Codable, Hashable, Sendable {
    let currencyCode: String
    let amountMinorUnits: Int
}

struct RoomSnapshot: Codable, Hashable, Sendable {
    let roomNumber: String?
    let roomType: String
    let wingName: String?
    let floorLabel: String?
}

struct GuestSnapshot: Codable, Hashable, Sendable {
    let userID: String
    let fullName: String
    let email: String?
    let phoneNumber: String?
}

struct DiningOrderItem: Codable, Hashable, Sendable, Identifiable {
    let id: String
    let menuItemID: String?
    let name: String
    let quantity: Int
    let unitPrice: MoneyAmount
    let notes: String?
}

struct BillingLineItem: Codable, Hashable, Sendable, Identifiable {
    let id: String
    let title: String
    let category: String
    let quantity: Int
    let amount: MoneyAmount
    let postedAt: Date?
}

struct AttachmentReference: Codable, Hashable, Sendable, Identifiable {
    let id: String
    let storagePath: String
    let fileName: String
    let contentType: String?
    let uploadedAt: Date?
}

struct AttractionSnapshot: Codable, Hashable, Sendable {
    let attractionID: String?
    let title: String
    let category: FavoriteAttractionCategory
    let shortLocationName: String
    let distanceMeters: Double?
    let imageURL: URL?
    let coordinate: GeoCoordinateSnapshot?
}

struct NotificationPreferences: Codable, Hashable, Sendable {
    let bookingUpdatesEnabled: Bool
    let diningUpdatesEnabled: Bool
    let conciergeUpdatesEnabled: Bool
    let promotionalMessagesEnabled: Bool
}

struct AccessibilityPreferences: Codable, Hashable, Sendable {
    let largeTextPreferred: Bool
    let reducedMotionPreferred: Bool
    let voiceAssistancePreferred: Bool
}
