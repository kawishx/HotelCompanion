//
//  FirestoreStatusEnums.swift
//  HotelCompanion
//
//  File: Core/Firebase/Firestore/Models/FirestoreStatusEnums.swift
//

import Foundation

enum HotelAccessStatus: String, Codable, CaseIterable, Sendable {
    case invited
    case active
    case revoked
    case archived
}

enum StayStatus: String, Codable, CaseIterable, Sendable {
    case upcoming
    case checkedIn
    case checkedOut
    case cancelled
    case noShow
}

enum BookingCategory: String, Codable, CaseIterable, Sendable {
    case room
    case experience
    case transport
    case spa
    case dining
    case other
}

enum BookingStatus: String, Codable, CaseIterable, Sendable {
    case draft
    case pending
    case confirmed
    case cancelled
    case completed
    case noShow
}

enum ServiceRequestCategory: String, Codable, CaseIterable, Sendable {
    case housekeeping
    case maintenance
    case roomSetup
    case amenities
    case other
}

enum ServiceRequestPriority: String, Codable, CaseIterable, Sendable {
    case low
    case normal
    case high
    case urgent
}

enum ServiceRequestStatus: String, Codable, CaseIterable, Sendable {
    case open
    case acknowledged
    case inProgress
    case resolved
    case closed
    case cancelled
}

enum DiningOrderStatus: String, Codable, CaseIterable, Sendable {
    case pending
    case accepted
    case preparing
    case ready
    case outForDelivery
    case delivered
    case cancelled
}

enum DiningDeliveryType: String, Codable, CaseIterable, Sendable {
    case roomService
    case restaurantPickup
    case poolsideDelivery
}

enum ConciergeRequestType: String, Codable, CaseIterable, Sendable {
    case transport
    case reservation
    case excursion
    case celebration
    case airportTransfer
    case other
}

enum ConciergeRequestStatus: String, Codable, CaseIterable, Sendable {
    case submitted
    case reviewing
    case confirmed
    case fulfilled
    case cancelled
}

enum NotificationType: String, Codable, CaseIterable, Sendable {
    case booking
    case dining
    case service
    case concierge
    case billing
    case geofence
    case system
}

enum ActivityEventType: String, Codable, CaseIterable, Sendable {
    case accountCreated
    case bookingConfirmed
    case checkInCompleted
    case checkOutCompleted
    case roomAssigned
    case serviceRequested
    case diningOrdered
    case conciergeRequested
    case paymentPosted
    case favoriteSaved
    case notificationOpened
}

enum BillingStatus: String, Codable, CaseIterable, Sendable {
    case open
    case partiallyPaid
    case paid
    case refunded
    case voided
}

enum FavoriteAttractionCategory: String, Codable, CaseIterable, Sendable {
    case beach
    case restaurant
    case touristSpot
    case shopping
    case other
}
