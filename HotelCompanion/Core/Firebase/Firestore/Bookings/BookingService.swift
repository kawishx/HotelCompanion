//
//  BookingService.swift
//  HotelCompanion
//
//  File: Core/Firebase/Firestore/Bookings/BookingService.swift
//

import Foundation

protocol BookingServicing {
    func fetchCurrentUserBookings() async throws -> [BookingRecord]
    func createBooking(for experience: ExperienceBooking, guestCount: Int) async throws -> BookingRecord
    func updateBooking(_ booking: BookingRecord) async throws -> BookingRecord
    func cancelBooking(_ booking: BookingRecord) async throws -> BookingRecord
    func rescheduleBooking(_ booking: BookingRecord, startDate: Date, endDate: Date?) async throws -> BookingRecord
}

enum BookingServiceError: LocalizedError {
    case invalidGuestCount
    case invalidDateRange

    var errorDescription: String? {
        switch self {
        case .invalidGuestCount:
            return "Select at least one guest before confirming the booking."
        case .invalidDateRange:
            return "Choose a valid booking date and time range."
        }
    }
}

final class BookingService: BookingServicing {
    static let shared = BookingService()

    private let repository: BookingRepositorying
    private let sessionCoordinator: FirebaseSessionCoordinating
    private let dateProvider: DateProviding
    private var fallbackBookingsByUserID: [String: [BookingRecord]] = [:]

    init(
        repository: BookingRepositorying = BookingRepository.shared,
        sessionCoordinator: FirebaseSessionCoordinating = FirebaseSessionCoordinator.shared,
        dateProvider: DateProviding = SystemDateProvider()
    ) {
        self.repository = repository
        self.sessionCoordinator = sessionCoordinator
        self.dateProvider = dateProvider
    }

    func fetchCurrentUserBookings() async throws -> [BookingRecord] {
        let session = resolvedSession()

        if shouldUseFallback(for: session) {
            return fallbackBookings(for: session)
        }

        do {
            return try await repository.fetchBookings(for: session.id)
        } catch let error as BookingRepositoryError where error == .firestoreUnavailable {
            return fallbackBookings(for: session)
        }
    }

    func createBooking(for experience: ExperienceBooking, guestCount: Int) async throws -> BookingRecord {
        guard guestCount > 0 else {
            throw BookingServiceError.invalidGuestCount
        }

        guard experience.endDate >= experience.startDate else {
            throw BookingServiceError.invalidDateRange
        }

        let session = resolvedSession()
        let confirmationCode = makeConfirmationCode()
        let bookingID = UUID().uuidString
        let normalizedStartDate = FirestoreDateCoding.normalizedBookingDate(experience.startDate)
        let normalizedEndDate = FirestoreDateCoding.normalizedBookingDate(experience.endDate)
        let createdAt = dateProvider.now

        let booking = BookingRecord(
            id: bookingID,
            hotelID: experience.hotelID,
            guestUserID: session.id,
            guest: sessionCoordinator.guestSnapshot(for: session),
            stayID: nil,
            experienceID: experience.experienceID,
            category: .experience,
            status: .confirmed,
            title: experience.title,
            summary: experience.summary,
            confirmationCode: confirmationCode,
            qrPayloadSource: makeQRPayloadSource(
                hotelID: experience.hotelID,
                bookingID: bookingID,
                experienceID: experience.experienceID,
                confirmationCode: confirmationCode,
                guestUserID: session.id
            ),
            startDate: normalizedStartDate,
            endDate: normalizedEndDate,
            guestCount: guestCount,
            totalAmount: nil,
            sourceChannel: "ios-app",
            createdAt: createdAt,
            updatedAt: createdAt
        )

        if shouldUseFallback(for: session) {
            var bookings = fallbackBookings(for: session)
            bookings.append(booking)
            fallbackBookingsByUserID[session.id] = bookings.sorted(by: { $0.startDate < $1.startDate })
            return booking
        }

        do {
            return try await repository.createBooking(booking)
        } catch let error as BookingRepositoryError where error == .firestoreUnavailable {
            var bookings = fallbackBookings(for: session)
            bookings.append(booking)
            fallbackBookingsByUserID[session.id] = bookings.sorted(by: { $0.startDate < $1.startDate })
            return booking
        }
    }

    func updateBooking(_ booking: BookingRecord) async throws -> BookingRecord {
        let updated = BookingRecord(
            id: booking.id,
            hotelID: booking.hotelID,
            guestUserID: booking.guestUserID,
            guest: booking.guest,
            stayID: booking.stayID,
            experienceID: booking.experienceID,
            category: booking.category,
            status: booking.status,
            title: booking.title,
            summary: booking.summary,
            confirmationCode: booking.confirmationCode,
            qrPayloadSource: booking.qrPayloadSource,
            startDate: FirestoreDateCoding.normalizedBookingDate(booking.startDate),
            endDate: booking.endDate.map(FirestoreDateCoding.normalizedBookingDate),
            guestCount: booking.guestCount,
            totalAmount: booking.totalAmount,
            sourceChannel: booking.sourceChannel,
            createdAt: booking.createdAt,
            updatedAt: dateProvider.now
        )

        let session = resolvedSession()

        if shouldUseFallback(for: session) {
            return storeFallback(updated, for: session)
        }

        do {
            return try await repository.updateBooking(updated)
        } catch let error as BookingRepositoryError where error == .firestoreUnavailable {
            return storeFallback(updated, for: session)
        }
    }

    func cancelBooking(_ booking: BookingRecord) async throws -> BookingRecord {
        let updated = BookingRecord(
            id: booking.id,
            hotelID: booking.hotelID,
            guestUserID: booking.guestUserID,
            guest: booking.guest,
            stayID: booking.stayID,
            experienceID: booking.experienceID,
            category: booking.category,
            status: .cancelled,
            title: booking.title,
            summary: booking.summary,
            confirmationCode: booking.confirmationCode,
            qrPayloadSource: booking.qrPayloadSource,
            startDate: booking.startDate,
            endDate: booking.endDate,
            guestCount: booking.guestCount,
            totalAmount: booking.totalAmount,
            sourceChannel: booking.sourceChannel,
            createdAt: booking.createdAt,
            updatedAt: dateProvider.now
        )

        return try await updateBooking(updated)
    }

    func rescheduleBooking(_ booking: BookingRecord, startDate: Date, endDate: Date?) async throws -> BookingRecord {
        if let endDate, endDate < startDate {
            throw BookingServiceError.invalidDateRange
        }

        let updated = BookingRecord(
            id: booking.id,
            hotelID: booking.hotelID,
            guestUserID: booking.guestUserID,
            guest: booking.guest,
            stayID: booking.stayID,
            experienceID: booking.experienceID,
            category: booking.category,
            status: booking.status,
            title: booking.title,
            summary: booking.summary,
            confirmationCode: booking.confirmationCode,
            qrPayloadSource: booking.qrPayloadSource,
            startDate: FirestoreDateCoding.normalizedBookingDate(startDate),
            endDate: endDate.map(FirestoreDateCoding.normalizedBookingDate),
            guestCount: booking.guestCount,
            totalAmount: booking.totalAmount,
            sourceChannel: booking.sourceChannel,
            createdAt: booking.createdAt,
            updatedAt: dateProvider.now
        )

        return try await updateBooking(updated)
    }
}

private extension BookingService {
    func resolvedSession() -> UserSession {
        sessionCoordinator.resolvedSession()
    }

    func shouldUseFallback(for session: UserSession) -> Bool {
        sessionCoordinator.canUseFallback(for: session) || !repository.isRemoteAvailable()
    }

    func fallbackBookings(for session: UserSession) -> [BookingRecord] {
        if let existing = fallbackBookingsByUserID[session.id] {
            return existing
        }

        let seeded = sampleBookings(for: session)
        fallbackBookingsByUserID[session.id] = seeded
        return seeded
    }

    func sampleBookings(for session: UserSession) -> [BookingRecord] {
        let now = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: 1, to: now) ?? now
        let endDate = Calendar.current.date(byAdding: .hour, value: 2, to: startDate) ?? startDate
        let roomStart = Calendar.current.date(byAdding: .day, value: 4, to: now) ?? now
        let roomEnd = Calendar.current.date(byAdding: .day, value: 7, to: roomStart) ?? roomStart

        let guest = GuestSnapshot(
            userID: session.id,
            fullName: session.displayName ?? "Kawish Jayawardena",
            email: session.email,
            phoneNumber: nil
        )

        let experienceBooking = BookingRecord(
            id: "fallback-booking-experience-001",
            hotelID: "cinnamon-thiya",
            guestUserID: session.id,
            guest: guest,
            stayID: nil,
            experienceID: "experience-river-cruise",
            category: .experience,
            status: .confirmed,
            title: "Sunset River Cruise",
            summary: "A curated evening cruise with refreshments and guided local storytelling.",
            confirmationCode: "CTH-EXP-48291",
            qrPayloadSource: makeQRPayloadSource(
                hotelID: "cinnamon-thiya",
                bookingID: "fallback-booking-experience-001",
                experienceID: "experience-river-cruise",
                confirmationCode: "CTH-EXP-48291",
                guestUserID: session.id
            ),
            startDate: startDate,
            endDate: endDate,
            guestCount: 2,
            totalAmount: nil,
            sourceChannel: "fallback",
            createdAt: now,
            updatedAt: now
        )

        let roomBooking = BookingRecord(
            id: "fallback-booking-stay-001",
            hotelID: "cinnamon-thiya",
            guestUserID: session.id,
            guest: guest,
            stayID: "stay-sample-cinnamon-thiya-001",
            experienceID: nil,
            category: .room,
            status: .confirmed,
            title: "Oceanfront Suite",
            summary: "Three-night stay with breakfast and private check-in.",
            confirmationCode: "CTH-STAY-48292",
            qrPayloadSource: makeQRPayloadSource(
                hotelID: "cinnamon-thiya",
                bookingID: "fallback-booking-stay-001",
                experienceID: "stay",
                confirmationCode: "CTH-STAY-48292",
                guestUserID: session.id
            ),
            startDate: roomStart,
            endDate: roomEnd,
            guestCount: 2,
            totalAmount: nil,
            sourceChannel: "fallback",
            createdAt: now,
            updatedAt: now
        )

        return [experienceBooking, roomBooking].sorted(by: { $0.startDate < $1.startDate })
    }

    func storeFallback(_ booking: BookingRecord, for session: UserSession) -> BookingRecord {
        var bookings = fallbackBookings(for: session).filter { $0.id != booking.id }
        bookings.append(booking)
        fallbackBookingsByUserID[session.id] = bookings.sorted(by: { $0.startDate < $1.startDate })
        return booking
    }

    func makeConfirmationCode() -> String {
        "CTH-\(String(UUID().uuidString.prefix(8)).uppercased())"
    }

    func makeQRPayloadSource(
        hotelID: String,
        bookingID: String,
        experienceID: String,
        confirmationCode: String,
        guestUserID: String
    ) -> String {
        "cinnamon-booking|\(hotelID)|\(bookingID)|\(experienceID)|\(confirmationCode)|\(guestUserID)"
    }
}
