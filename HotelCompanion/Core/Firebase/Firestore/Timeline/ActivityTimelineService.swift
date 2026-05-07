//
//  ActivityTimelineService.swift
//  HotelCompanion
//
//  File: Core/Firebase/Firestore/Timeline/ActivityTimelineService.swift
//

import Foundation

protocol ActivityTimelineServicing {
    func fetchCurrentUserTimeline() async throws -> [ActivityTimelineRecord]
}

final class ActivityTimelineService: ActivityTimelineServicing {
    static let shared = ActivityTimelineService()

    private let remoteStore: FirestoreRemoteStoring
    private let sessionCoordinator: FirebaseSessionCoordinating
    private let bookingService: BookingServicing
    private let diningOrderService: DiningOrderServicing
    private let serviceRequestService: ServiceRequestServicing
    private let conciergeRequestService: ConciergeRequestServicing
    private let stayService: StayServicing

    init(
        remoteStore: FirestoreRemoteStoring = FirestoreRemoteStore.shared,
        sessionCoordinator: FirebaseSessionCoordinating = FirebaseSessionCoordinator.shared,
        bookingService: BookingServicing = BookingService.shared,
        diningOrderService: DiningOrderServicing = DiningOrderService.shared,
        serviceRequestService: ServiceRequestServicing = ServiceRequestService.shared,
        conciergeRequestService: ConciergeRequestServicing = ConciergeRequestService.shared,
        stayService: StayServicing = StayService.shared
    ) {
        self.remoteStore = remoteStore
        self.sessionCoordinator = sessionCoordinator
        self.bookingService = bookingService
        self.diningOrderService = diningOrderService
        self.serviceRequestService = serviceRequestService
        self.conciergeRequestService = conciergeRequestService
        self.stayService = stayService
    }

    func fetchCurrentUserTimeline() async throws -> [ActivityTimelineRecord] {
        let session = resolvedSession()

        if !shouldUseFallback(for: session) {
            do {
                let records: [ActivityTimelineRecord] = try await remoteStore.fetchUserSubcollection(
                    userID: session.id,
                    subcollection: .activityTimeline,
                    orderBy: FirestoreDocumentField.occurredAt,
                    descending: true
                )

                if !records.isEmpty {
                    return records
                }
            } catch let error as FirestoreRemoteStoreError where error == .unavailable {
            }
        }

        return try await synthesizedTimeline(for: session)
    }
}

private extension ActivityTimelineService {
    func resolvedSession() -> UserSession {
        sessionCoordinator.resolvedSession()
    }

    func shouldUseFallback(for session: UserSession) -> Bool {
        sessionCoordinator.canUseFallback(for: session) || !remoteStore.isAvailable()
    }

    func synthesizedTimeline(for session: UserSession) async throws -> [ActivityTimelineRecord] {
        async let bookingsTask = bookingService.fetchCurrentUserBookings()
        async let diningTask = diningOrderService.fetchCurrentUserOrders()
        async let serviceRequestsTask = serviceRequestService.fetchCurrentUserServiceRequests()
        async let conciergeTask = conciergeRequestService.fetchCurrentUserConciergeRequests()
        async let stayTask = stayService.fetchCurrentStay()

        let bookings = (try? await bookingsTask) ?? []
        let diningOrders = (try? await diningTask) ?? []
        let serviceRequests = (try? await serviceRequestsTask) ?? []
        let conciergeRequests = (try? await conciergeTask) ?? []
        let stay = try? await stayTask

        var events: [ActivityTimelineRecord] = []

        if let stay {
            events.append(
                ActivityTimelineRecord(
                    id: "timeline-stay-\(stay.id)",
                    userID: session.id,
                    hotelID: stay.hotelID,
                    eventType: stay.status == .checkedOut ? .checkOutCompleted : (stay.status == .checkedIn ? .checkInCompleted : .roomAssigned),
                    title: stay.status == .checkedOut ? "Check-out completed" : (stay.status == .checkedIn ? "Check-in completed" : "Stay scheduled"),
                    detail: "Suite \(stay.room.roomNumber ?? "assigned") at Cinnamon Thiya is linked to your current stay.",
                    sourceModule: "stay",
                    relatedDocumentPath: FirestorePath.hotelSubcollection(hotelID: stay.hotelID, subcollection: .stays) + "/\(stay.id)",
                    occurredAt: stay.status == .checkedOut ? stay.checkOutDate : (stay.updatedAt ?? stay.checkInDate),
                    createdAt: stay.createdAt
                )
            )

            events.append(
                ActivityTimelineRecord(
                    id: "timeline-room-\(stay.id)",
                    userID: session.id,
                    hotelID: stay.hotelID,
                    eventType: .roomAssigned,
                    title: "Room assigned",
                    detail: "\(stay.room.roomType) \(stay.room.roomNumber.map { "Room \($0)" } ?? "") is ready for your stay.",
                    sourceModule: "stay",
                    relatedDocumentPath: FirestorePath.hotelSubcollection(hotelID: stay.hotelID, subcollection: .stays) + "/\(stay.id)",
                    occurredAt: stay.createdAt ?? stay.checkInDate,
                    createdAt: stay.createdAt
                )
            )
        }

        for booking in bookings {
            events.append(
                ActivityTimelineRecord(
                    id: "timeline-booking-\(booking.id)",
                    userID: session.id,
                    hotelID: booking.hotelID,
                    eventType: .bookingConfirmed,
                    title: booking.title,
                    detail: booking.summary ?? "Booking confirmed for \(booking.startDate.formatted(date: .abbreviated, time: .shortened)).",
                    sourceModule: "bookings",
                    relatedDocumentPath: FirestorePath.hotelSubcollection(hotelID: booking.hotelID, subcollection: .bookings) + "/\(booking.id)",
                    occurredAt: booking.updatedAt ?? booking.createdAt ?? booking.startDate,
                    createdAt: booking.createdAt
                )
            )
        }

        for order in diningOrders {
            events.append(
                ActivityTimelineRecord(
                    id: "timeline-dining-\(order.id)",
                    userID: session.id,
                    hotelID: order.hotelID,
                    eventType: .diningOrdered,
                    title: "Dining order at \(order.venueName)",
                    detail: "\(order.items.reduce(0) { $0 + $1.quantity }) item(s) • \(order.deliveryLocationLabel)",
                    sourceModule: "dining",
                    relatedDocumentPath: FirestorePath.hotelSubcollection(hotelID: order.hotelID, subcollection: .diningOrders) + "/\(order.id)",
                    occurredAt: order.updatedAt ?? order.createdAt ?? Date(),
                    createdAt: order.createdAt
                )
            )
        }

        for request in serviceRequests {
            events.append(
                ActivityTimelineRecord(
                    id: "timeline-service-\(request.id)",
                    userID: session.id,
                    hotelID: request.hotelID,
                    eventType: .serviceRequested,
                    title: "Service request: \(request.requestType.rawValue.capitalized)",
                    detail: request.note,
                    sourceModule: "service",
                    relatedDocumentPath: FirestorePath.hotelSubcollection(hotelID: request.hotelID, subcollection: .serviceRequests) + "/\(request.id)",
                    occurredAt: request.updatedAt ?? request.createdAt ?? Date(),
                    createdAt: request.createdAt
                )
            )
        }

        for request in conciergeRequests {
            events.append(
                ActivityTimelineRecord(
                    id: "timeline-concierge-\(request.id)",
                    userID: session.id,
                    hotelID: request.hotelID,
                    eventType: .conciergeRequested,
                    title: request.title,
                    detail: request.detail,
                    sourceModule: "concierge",
                    relatedDocumentPath: FirestorePath.hotelSubcollection(hotelID: request.hotelID, subcollection: .conciergeRequests) + "/\(request.id)",
                    occurredAt: request.updatedAt ?? request.createdAt ?? Date(),
                    createdAt: request.createdAt
                )
            )
        }

        return events.sorted { $0.occurredAt > $1.occurredAt }
    }
}
