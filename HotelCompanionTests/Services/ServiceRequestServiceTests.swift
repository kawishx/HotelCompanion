//
//  ServiceRequestServiceTests.swift
//  HotelCompanionTests
//
//  File: HotelCompanionTests/Services/ServiceRequestServiceTests.swift
//

import XCTest
@testable import HotelCompanion

final class ServiceRequestServiceTests: XCTestCase {
    @MainActor
    func testCreateServiceRequestWithEmptyNoteThrowsValidationError() async {
        let service = ServiceRequestService(
            remoteStore: UnavailableRemoteStore(),
            sessionCoordinator: StubSessionCoordinator(),
            hotelContextResolver: StubHotelContextResolver(
                hotelContext: HotelContext(hotelID: "cinnamon-thiya", stay: nil)
            ),
            dateProvider: FixedDateProvider(now: Date())
        )

        do {
            _ = try await service.createServiceRequest(
                requestType: .maintenance,
                note: "   ",
                roomNumber: nil,
                uploadedImageURL: nil,
                priority: .high
            )
            XCTFail("Expected empty note error")
        } catch let error as ServiceRequestServiceError {
            switch error {
            case .emptyNote:
                break
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    @MainActor
    func testCreateServiceRequestTrimsRoomNumberAndStoresResolvedContext() async throws {
        let fixedNow = Date(timeIntervalSince1970: 1_715_000_000)
        let service = ServiceRequestService(
            remoteStore: UnavailableRemoteStore(),
            sessionCoordinator: StubSessionCoordinator(),
            hotelContextResolver: StubHotelContextResolver(
                hotelContext: HotelContext(hotelID: "cinnamon-thiya", stay: nil)
            ),
            dateProvider: FixedDateProvider(now: fixedNow)
        )

        let created = try await service.createServiceRequest(
            requestType: .maintenance,
            note: " Air conditioning is noisy ",
            roomNumber: " 508 ",
            uploadedImageURL: nil,
            priority: .urgent
        )

        XCTAssertEqual(created.roomNumber, "508")
        XCTAssertEqual(created.note, "Air conditioning is noisy")
        XCTAssertEqual(created.priority, .urgent)
        XCTAssertEqual(created.status, .open)
        XCTAssertEqual(created.createdAt, fixedNow)
    }

    @MainActor
    func testUpdateRequestStatusToResolvedSetsResolvedAt() async throws {
        let fixedNow = Date(timeIntervalSince1970: 1_715_000_000)
        let service = ServiceRequestService(
            remoteStore: UnavailableRemoteStore(),
            sessionCoordinator: StubSessionCoordinator(),
            hotelContextResolver: StubHotelContextResolver(
                hotelContext: HotelContext(hotelID: "cinnamon-thiya", stay: nil)
            ),
            dateProvider: FixedDateProvider(now: fixedNow)
        )
        let request = ServiceRequestRecord(
            id: "request-001",
            hotelID: "cinnamon-thiya",
            guestUserID: "guest-user",
            guest: GuestSnapshot(userID: "guest-user", fullName: "Test Guest", email: "guest@example.com", phoneNumber: nil),
            stayID: nil,
            roomNumber: "508",
            requestType: .maintenance,
            note: "Air conditioning is noisy",
            uploadedImageURL: nil,
            priority: .high,
            status: .open,
            assignedTeamName: nil,
            createdAt: fixedNow.addingTimeInterval(-600),
            updatedAt: fixedNow.addingTimeInterval(-600),
            resolvedAt: nil
        )

        let updated = try await service.updateRequestStatus(request, status: .resolved)

        XCTAssertEqual(updated.status, .resolved)
        XCTAssertEqual(updated.resolvedAt, fixedNow)
        XCTAssertEqual(updated.updatedAt, fixedNow)
    }
}
