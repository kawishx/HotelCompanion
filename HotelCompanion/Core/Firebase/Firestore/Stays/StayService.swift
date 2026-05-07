//
//  StayService.swift
//  HotelCompanion
//
//  File: Core/Firebase/Firestore/Stays/StayService.swift
//

import Foundation

protocol StayServicing {
    func fetchCurrentStay() async throws -> StayRecord?
}

final class StayService: StayServicing {
    static let shared = StayService()

    private let remoteStore: FirestoreRemoteStoring
    private let sessionCoordinator: FirebaseSessionCoordinating

    init(
        remoteStore: FirestoreRemoteStoring = FirestoreRemoteStore.shared,
        sessionCoordinator: FirebaseSessionCoordinating = FirebaseSessionCoordinator.shared
    ) {
        self.remoteStore = remoteStore
        self.sessionCoordinator = sessionCoordinator
    }

    func fetchCurrentStay() async throws -> StayRecord? {
        guard let session = sessionCoordinator.currentSession, !session.isGuest else {
            return nil
        }

        guard remoteStore.isAvailable() else {
            return sampleStay(for: session)
        }

        let stays: [StayRecord] = try await remoteStore.fetchCollectionGroup(
            subcollection: .stays,
            filters: [
                .equalTo(field: FirestoreDocumentField.guestUserID, value: session.id),
                .inValues(field: FirestoreDocumentField.status, values: [StayStatus.upcoming.rawValue, StayStatus.checkedIn.rawValue])
            ],
            orderBy: "checkInDate",
            descending: false,
            limit: 1
        )

        if let stay = stays.first {
            return stay
        }

        return sampleStay(for: session)
    }
}

private extension StayService {
    func sampleStay(for session: UserSession) -> StayRecord {
        StayRecord(
            id: "stay-sample-cinnamon-thiya-001",
            hotelID: "cinnamon-thiya",
            guestUserID: session.id,
            guest: GuestSnapshot(
                userID: session.id,
                fullName: session.displayName ?? "Kawish Jayawardena",
                email: session.email,
                phoneNumber: "+94 77 123 4567"
            ),
            bookingID: "booking-cinnamon-thiya-001",
            confirmationCode: "CTH-48291",
            room: RoomSnapshot(
                roomNumber: "508",
                roomType: "Oceanfront Suite",
                wingName: "South Wing",
                floorLabel: "Level 5"
            ),
            adultCount: 2,
            childCount: 0,
            checkInDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            checkOutDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
            status: .checkedIn,
            specialNotes: "Late checkout has been pre-approved until 2:00 PM.",
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
