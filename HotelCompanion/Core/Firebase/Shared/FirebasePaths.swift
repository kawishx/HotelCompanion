//
//  FirebasePaths.swift
//  HotelCompanion
//
//  File: Core/Firebase/Shared/FirebasePaths.swift
//

import Foundation

enum FirestoreCollection: String {
    case hotels
    case users
}

enum FirestoreHotelSubcollection: String {
    case stays
    case bookings
    case serviceRequests
    case diningOrders
    case conciergeRequests
    case billingSummaries
}

enum FirestoreUserSubcollection: String {
    case hotelMemberships
    case notifications
    case activityTimeline
    case savedAttractions
}

enum FirestoreDocumentField {
    static let hotelID = "hotelID"
    static let userID = "userID"
    static let guestUserID = "guestUserID"
    static let stayID = "stayID"
    static let bookingID = "bookingID"
    static let createdAt = "createdAt"
    static let updatedAt = "updatedAt"
    static let status = "status"
    static let sentAt = "sentAt"
    static let occurredAt = "occurredAt"
    static let savedAt = "savedAt"
    static let issuedAt = "issuedAt"
}

enum FirestorePath {
    static func hotel(_ hotelID: String) -> String {
        "\(FirestoreCollection.hotels.rawValue)/\(hotelID)"
    }

    static func hotelSubcollection(
        hotelID: String,
        subcollection: FirestoreHotelSubcollection
    ) -> String {
        "\(hotel(hotelID))/\(subcollection.rawValue)"
    }

    static func user(_ userID: String) -> String {
        "\(FirestoreCollection.users.rawValue)/\(userID)"
    }

    static func userSubcollection(
        userID: String,
        subcollection: FirestoreUserSubcollection
    ) -> String {
        "\(user(userID))/\(subcollection.rawValue)"
    }

    static func hotelSubcollectionDocument(
        hotelID: String,
        subcollection: FirestoreHotelSubcollection,
        documentID: String
    ) -> String {
        "\(hotelSubcollection(hotelID: hotelID, subcollection: subcollection))/\(documentID)"
    }

    static func userSubcollectionDocument(
        userID: String,
        subcollection: FirestoreUserSubcollection,
        documentID: String
    ) -> String {
        "\(userSubcollection(userID: userID, subcollection: subcollection))/\(documentID)"
    }
}

enum FirebaseStoragePath {
    static let profileImages = "profile-images"
    static let bookingDocuments = "booking-documents"
    static let idDocuments = "id-documents"
    static let maintenanceUploads = "maintenance-uploads"
}
