//
//  BookingRepository.swift
//  HotelCompanion
//
//  File: Core/Firebase/Firestore/Bookings/BookingRepository.swift
//

import Foundation

protocol BookingRepositorying {
    func isRemoteAvailable() -> Bool
    func fetchBookings(for guestUserID: String) async throws -> [BookingRecord]
    func createBooking(_ booking: BookingRecord) async throws -> BookingRecord
    func updateBooking(_ booking: BookingRecord) async throws -> BookingRecord
}

enum BookingRepositoryError: LocalizedError, Equatable {
    case firestoreUnavailable

    var errorDescription: String? {
        switch self {
        case .firestoreUnavailable:
            return "Cloud Firestore is not configured yet."
        }
    }
}

final class BookingRepository: BookingRepositorying {
    static let shared = BookingRepository()

    private let remoteStore: FirestoreRemoteStoring

    init(remoteStore: FirestoreRemoteStoring = FirestoreRemoteStore.shared) {
        self.remoteStore = remoteStore
    }

    func isRemoteAvailable() -> Bool {
        remoteStore.isAvailable()
    }

    func fetchBookings(for guestUserID: String) async throws -> [BookingRecord] {
        guard remoteStore.isAvailable() else {
            throw BookingRepositoryError.firestoreUnavailable
        }

        do {
            return try await remoteStore.fetchCollectionGroup(
                subcollection: .bookings,
                filters: [.equalTo(field: FirestoreDocumentField.guestUserID, value: guestUserID)],
                orderBy: "startDate",
                descending: false,
                limit: nil
            )
        } catch let error as FirestoreRemoteStoreError where error == .unavailable {
            throw BookingRepositoryError.firestoreUnavailable
        }
    }

    func createBooking(_ booking: BookingRecord) async throws -> BookingRecord {
        guard remoteStore.isAvailable() else {
            throw BookingRepositoryError.firestoreUnavailable
        }

        let data = try FirestoreDateCoding.preparedBookingData(from: booking)
        do {
            try await remoteStore.setDocument(
                at: FirestorePath.hotelSubcollectionDocument(
                    hotelID: booking.hotelID,
                    subcollection: .bookings,
                    documentID: booking.id
                ),
                data: data,
                merge: false
            )
        } catch let error as FirestoreRemoteStoreError where error == .unavailable {
            throw BookingRepositoryError.firestoreUnavailable
        }

        return booking
    }

    func updateBooking(_ booking: BookingRecord) async throws -> BookingRecord {
        guard remoteStore.isAvailable() else {
            throw BookingRepositoryError.firestoreUnavailable
        }

        let data = try FirestoreDateCoding.preparedBookingData(from: booking)
        do {
            try await remoteStore.setDocument(
                at: FirestorePath.hotelSubcollectionDocument(
                    hotelID: booking.hotelID,
                    subcollection: .bookings,
                    documentID: booking.id
                ),
                data: data,
                merge: true
            )
        } catch let error as FirestoreRemoteStoreError where error == .unavailable {
            throw BookingRepositoryError.firestoreUnavailable
        }

        return booking
    }
}
