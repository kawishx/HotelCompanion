//
//  FirestoreDomainModels.swift
//  HotelCompanion
//
//  File: Core/Firebase/Firestore/Models/FirestoreDomainModels.swift
//

import Foundation

struct HotelProperty: Identifiable, Codable, FirestoreMappable, Sendable {
    let id: String
    let brandID: String?
    let name: String
    let shortCode: String
    let city: String
    let countryCode: String
    let timeZoneIdentifier: String
    let currencyCode: String
    let address: AddressSnapshot
    let coordinate: GeoCoordinateSnapshot
    let isActive: Bool
    let createdAt: Date?
    let updatedAt: Date?
}

struct UserProfileRecord: Identifiable, Codable, FirestoreMappable, Sendable {
    let id: String
    let primaryHotelID: String?
    let fullName: String
    let email: String
    let phoneNumber: String?
    let loyaltyTier: String?
    let preferredLocaleIdentifier: String
    let preferredCurrencyCode: String
    let profileImagePath: String?
    let notificationPreferences: NotificationPreferences
    let accessibilityPreferences: AccessibilityPreferences
    let createdAt: Date?
    let updatedAt: Date?
}

struct UserHotelMembershipRecord: Identifiable, Codable, FirestoreMappable, Sendable {
    let id: String
    let hotelID: String
    let permissionStatus: HotelAccessStatus
    let isPrimaryHotel: Bool
    let invitedAt: Date?
    let grantedAt: Date?
    let lastSeenAt: Date?
    let createdAt: Date?
    let updatedAt: Date?
}

struct StayRecord: Identifiable, Codable, FirestoreMappable, Sendable {
    let id: String
    let hotelID: String
    let guestUserID: String
    let guest: GuestSnapshot
    let bookingID: String?
    let confirmationCode: String
    let room: RoomSnapshot
    let adultCount: Int
    let childCount: Int
    let checkInDate: Date
    let checkOutDate: Date
    let status: StayStatus
    let specialNotes: String?
    let createdAt: Date?
    let updatedAt: Date?
}

struct BookingRecord: Identifiable, Codable, FirestoreMappable, Sendable {
    let id: String
    let hotelID: String
    let guestUserID: String
    let guest: GuestSnapshot
    let stayID: String?
    let experienceID: String?
    let category: BookingCategory
    let status: BookingStatus
    let title: String
    let summary: String?
    let confirmationCode: String
    let qrPayloadSource: String
    let startDate: Date
    let endDate: Date?
    let guestCount: Int
    let totalAmount: MoneyAmount?
    let sourceChannel: String?
    let createdAt: Date?
    let updatedAt: Date?
}

struct ServiceRequestRecord: Identifiable, Codable, FirestoreMappable, Sendable {
    let id: String
    let hotelID: String
    let guestUserID: String
    let guest: GuestSnapshot
    let stayID: String?
    let roomNumber: String?
    let requestType: ServiceRequestCategory
    let note: String
    let uploadedImageURL: URL?
    let priority: ServiceRequestPriority
    let status: ServiceRequestStatus
    let assignedTeamName: String?
    let createdAt: Date?
    let updatedAt: Date?
    let resolvedAt: Date?
}

struct DiningOrderRecord: Identifiable, Codable, FirestoreMappable, Sendable {
    let id: String
    let hotelID: String
    let guestUserID: String
    let guest: GuestSnapshot
    let stayID: String?
    let venueName: String
    let deliveryType: DiningDeliveryType
    let deliveryLocationLabel: String
    let roomNumber: String?
    let items: [DiningOrderItem]
    let specialInstructions: String?
    let status: DiningOrderStatus
    let subtotalAmount: MoneyAmount
    let taxAmount: MoneyAmount
    let totalAmount: MoneyAmount
    let requestedFor: Date?
    let createdAt: Date?
    let updatedAt: Date?
    let fulfilledAt: Date?
}

struct ConciergeRequestRecord: Identifiable, Codable, FirestoreMappable, Sendable {
    let id: String
    let hotelID: String
    let guestUserID: String
    let guest: GuestSnapshot
    let stayID: String?
    let requestType: ConciergeRequestType
    let status: ConciergeRequestStatus
    let title: String
    let detail: String
    let requestedFor: Date?
    let partySize: Int?
    let contactMethod: String?
    let responseNotes: String?
    let createdAt: Date?
    let updatedAt: Date?
}

struct NotificationRecord: Identifiable, Codable, FirestoreMappable, Sendable {
    let id: String
    let userID: String
    let hotelID: String?
    let type: NotificationType
    let title: String
    let body: String
    let relatedDocumentPath: String?
    let deepLinkRoute: String?
    let isRead: Bool
    let sentAt: Date
    let readAt: Date?
    let createdAt: Date?
    let updatedAt: Date?
}

struct ActivityTimelineRecord: Identifiable, Codable, FirestoreMappable, Sendable {
    let id: String
    let userID: String
    let hotelID: String?
    let eventType: ActivityEventType
    let title: String
    let detail: String
    let sourceModule: String
    let relatedDocumentPath: String?
    let occurredAt: Date
    let createdAt: Date?
}

struct BillingSummaryRecord: Identifiable, Codable, FirestoreMappable, Sendable {
    let id: String
    let hotelID: String
    let guestUserID: String
    let guest: GuestSnapshot
    let stayID: String
    let folioNumber: String
    let status: BillingStatus
    let lineItems: [BillingLineItem]
    let subtotalAmount: MoneyAmount
    let taxAmount: MoneyAmount
    let discountAmount: MoneyAmount?
    let totalAmount: MoneyAmount
    let balanceDueAmount: MoneyAmount
    let issuedAt: Date
    let dueAt: Date?
    let createdAt: Date?
    let updatedAt: Date?
}

struct SavedAttractionRecord: Identifiable, Codable, FirestoreMappable, Sendable {
    let id: String
    let userID: String
    let hotelID: String?
    let attraction: AttractionSnapshot
    let notes: String?
    let savedAt: Date
    let createdAt: Date?
    let updatedAt: Date?
}
