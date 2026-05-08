//
//  BookingServiceTests.swift
//  HotelCompanionTests
//
//  File: HotelCompanionTests/Services/BookingServiceTests.swift
//

import XCTest
@testable import HotelCompanion

final class BookingServiceTests: XCTestCase {
    func testCreateBookingWithZeroGuestsThrowsValidationError() async {
        let service = BookingService(
            repository: StubBookingRepository(),
            sessionCoordinator: StubSessionCoordinator(),
            dateProvider: FixedDateProvider(now: Date())
        )

        do {
            _ = try await service.createBooking(
                for: makeExperience(startDate: Date(), endDate: Date().addingTimeInterval(3600)),
                guestCount: 0
            )
            XCTFail("Expected invalid guest count error")
        } catch let error as BookingServiceError {
            switch error {
            case .invalidGuestCount:
                break
            default:
                XCTFail("Unexpected error: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testCreateBookingWithEndBeforeStartThrowsValidationError() async {
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(-1800)
        let service = BookingService(
            repository: StubBookingRepository(),
            sessionCoordinator: StubSessionCoordinator(),
            dateProvider: FixedDateProvider(now: startDate)
        )

        do {
            _ = try await service.createBooking(
                for: makeExperience(startDate: startDate, endDate: endDate),
                guestCount: 2
            )
            XCTFail("Expected invalid date range error")
        } catch let error as BookingServiceError {
            switch error {
            case .invalidDateRange:
                break
            default:
                XCTFail("Unexpected error: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testCancelBookingMarksBookingAsCancelled() async throws {
        let fixedNow = Date(timeIntervalSince1970: 1_715_000_000)
        let service = BookingService(
            repository: StubBookingRepository(),
            sessionCoordinator: StubSessionCoordinator(),
            dateProvider: FixedDateProvider(now: fixedNow)
        )
        let booking = makeBookingRecord(startDate: fixedNow, endDate: fixedNow.addingTimeInterval(3600))

        let cancelled = try await service.cancelBooking(booking)

        XCTAssertEqual(cancelled.status, .cancelled)
        XCTAssertEqual(cancelled.updatedAt, fixedNow)
    }

    func testRescheduleBookingNormalizesSecondsAndPreservesBookingIdentity() async throws {
        let fixedNow = Date(timeIntervalSince1970: 1_715_000_000)
        let service = BookingService(
            repository: StubBookingRepository(),
            sessionCoordinator: StubSessionCoordinator(),
            dateProvider: FixedDateProvider(now: fixedNow)
        )
        let booking = makeBookingRecord(
            startDate: fixedNow,
            endDate: fixedNow.addingTimeInterval(3600)
        )
        let rescheduledStart = Date(timeIntervalSince1970: 1_715_010_045)
        let rescheduledEnd = Date(timeIntervalSince1970: 1_715_013_072)

        let updated = try await service.rescheduleBooking(
            booking,
            startDate: rescheduledStart,
            endDate: rescheduledEnd
        )

        XCTAssertEqual(updated.id, booking.id)
        XCTAssertEqual(Calendar.current.component(.second, from: updated.startDate), 0)
        XCTAssertEqual(Calendar.current.component(.second, from: updated.endDate ?? rescheduledEnd), 0)
        XCTAssertEqual(updated.updatedAt, fixedNow)
    }

    func testRescheduleBookingWithEndBeforeStartThrowsValidationError() async {
        let fixedNow = Date(timeIntervalSince1970: 1_715_000_000)
        let service = BookingService(
            repository: StubBookingRepository(),
            sessionCoordinator: StubSessionCoordinator(),
            dateProvider: FixedDateProvider(now: fixedNow)
        )
        let booking = makeBookingRecord(
            startDate: fixedNow,
            endDate: fixedNow.addingTimeInterval(3600)
        )

        do {
            _ = try await service.rescheduleBooking(
                booking,
                startDate: fixedNow.addingTimeInterval(7200),
                endDate: fixedNow.addingTimeInterval(7100)
            )
            XCTFail("Expected invalid date range error")
        } catch let error as BookingServiceError {
            switch error {
            case .invalidDateRange:
                break
            default:
                XCTFail("Unexpected error: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
