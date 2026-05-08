//
//  TestDoubles.swift
//  HotelCompanionTests
//
//  File: HotelCompanionTests/Support/TestDoubles.swift
//

import Foundation
import XCTest
@testable import HotelCompanion

struct FixedDateProvider: DateProviding {
    let now: Date
}

final class StubBookingRepository: BookingRepositorying {
    var isRemoteAvailableValue = false
    var fetchedBookings: [BookingRecord] = []
    var createdBookings: [BookingRecord] = []
    var updatedBookings: [BookingRecord] = []

    func isRemoteAvailable() -> Bool {
        isRemoteAvailableValue
    }

    func fetchBookings(for guestUserID: String) async throws -> [BookingRecord] {
        fetchedBookings
    }

    func createBooking(_ booking: BookingRecord) async throws -> BookingRecord {
        createdBookings.append(booking)
        return booking
    }

    func updateBooking(_ booking: BookingRecord) async throws -> BookingRecord {
        updatedBookings.append(booking)
        return booking
    }
}

final class StubSessionCoordinator: FirebaseSessionCoordinating {
    var currentSession: UserSession?
    var fallbackAllowed = true

    init(currentSession: UserSession? = UserSession(id: "guest-user", email: "guest@example.com", displayName: "Guest", isGuest: false)) {
        self.currentSession = currentSession
    }

    func resolvedSession() -> UserSession {
        currentSession ?? .guest
    }

    func authenticatedSession() throws -> UserSession {
        if let currentSession, !currentSession.isGuest {
            return currentSession
        }

        throw FirebaseSessionCoordinatorError.unauthenticated
    }

    func canUseFallback(for session: UserSession) -> Bool {
        fallbackAllowed
    }

    func guestSnapshot(for session: UserSession) -> GuestSnapshot {
        GuestSnapshot(
            userID: session.id,
            fullName: session.displayName ?? "Guest User",
            email: session.email,
            phoneNumber: nil
        )
    }
}

struct StubHotelContextResolver: HotelContextResolving {
    let hotelContext: HotelContext

    func resolveCurrentHotelContext(defaultHotelID: String) async -> HotelContext {
        hotelContext
    }
}

@MainActor
final class UnavailableRemoteStore: FirestoreRemoteStoring {
    func isAvailable() -> Bool {
        false
    }

    func fetchDocument<T: Decodable>(at path: String, as type: T.Type) async throws -> T? {
        nil
    }

    func fetchCollectionGroup<T: Decodable>(
        subcollection: FirestoreHotelSubcollection,
        filters: [FirestoreQueryFilter],
        orderBy: String?,
        descending: Bool,
        limit: Int?
    ) async throws -> [T] {
        []
    }

    func fetchUserSubcollection<T: Decodable>(
        userID: String,
        subcollection: FirestoreUserSubcollection,
        orderBy: String,
        descending: Bool
    ) async throws -> [T] {
        []
    }

    func setDocument(at path: String, data: [String: Any], merge: Bool) async throws {
    }

    func deleteDocument(at path: String) async throws {
    }
}

func makeExperience(
    startDate: Date,
    endDate: Date,
    title: String = "Sunset River Cruise"
) -> ExperienceBooking {
    ExperienceBooking(
        hotelID: "cinnamon-thiya",
        title: title,
        category: "Experience",
        summary: "Curated river cruise.",
        location: "Jetty",
        startDate: startDate,
        endDate: endDate
    )
}

func makeBookingRecord(
    startDate: Date,
    endDate: Date?,
    status: BookingStatus = .confirmed
) -> BookingRecord {
    BookingRecord(
        id: "booking-001",
        hotelID: "cinnamon-thiya",
        guestUserID: "guest-user",
        guest: GuestSnapshot(userID: "guest-user", fullName: "Test Guest", email: "guest@example.com", phoneNumber: nil),
        stayID: nil,
        experienceID: "experience-001",
        category: .experience,
        status: status,
        title: "Sunset River Cruise",
        summary: "Curated river cruise.",
        confirmationCode: "CTH-001",
        qrPayloadSource: "payload",
        startDate: startDate,
        endDate: endDate,
        guestCount: 2,
        totalAmount: nil,
        sourceChannel: "test",
        createdAt: startDate,
        updatedAt: startDate
    )
}

func makeBillingSummary() -> BillingSummaryRecord {
    BillingSummaryRecord(
        id: "billing-001",
        hotelID: "cinnamon-thiya",
        guestUserID: "guest-user",
        guest: GuestSnapshot(userID: "guest-user", fullName: "Test Guest", email: "guest@example.com", phoneNumber: nil),
        stayID: "stay-001",
        folioNumber: "FOLIO-001",
        status: .open,
        lineItems: [
            BillingLineItem(id: "room-1", title: "Oceanfront Suite", category: "room", quantity: 3, amount: MoneyAmount(currencyCode: "LKR", amountMinorUnits: 145000), postedAt: Date()),
            BillingLineItem(id: "food-1", title: "Breakfast", category: "food", quantity: 2, amount: MoneyAmount(currencyCode: "LKR", amountMinorUnits: 12450), postedAt: Date()),
            BillingLineItem(id: "service-1", title: "Transfer", category: "service", quantity: 1, amount: MoneyAmount(currencyCode: "LKR", amountMinorUnits: 6000), postedAt: Date())
        ],
        subtotalAmount: MoneyAmount(currencyCode: "LKR", amountMinorUnits: 163450),
        taxAmount: MoneyAmount(currencyCode: "LKR", amountMinorUnits: 16345),
        discountAmount: nil,
        totalAmount: MoneyAmount(currencyCode: "LKR", amountMinorUnits: 179795),
        balanceDueAmount: MoneyAmount(currencyCode: "LKR", amountMinorUnits: 179795),
        issuedAt: Date(),
        dueAt: nil,
        createdAt: Date(),
        updatedAt: Date()
    )
}
