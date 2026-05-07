//
//  ConciergeRequestService.swift
//  HotelCompanion
//
//  File: Core/Firebase/Firestore/Concierge/ConciergeRequestService.swift
//

import Foundation

protocol ConciergeRequestServicing {
    func fetchCurrentUserConciergeRequests() async throws -> [ConciergeRequestRecord]
    func createConciergeRequest(
        requestType: ConciergeRequestType,
        title: String,
        detail: String,
        requestedFor: Date?,
        partySize: Int?
    ) async throws -> ConciergeRequestRecord
    func updateRequestStatus(
        _ request: ConciergeRequestRecord,
        status: ConciergeRequestStatus
    ) async throws -> ConciergeRequestRecord
}

enum ConciergeRequestServiceError: LocalizedError {
    case emptyTitle
    case emptyDetail

    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "Add a short title for your concierge request."
        case .emptyDetail:
            return "Add a few details so the concierge team knows how to help."
        }
    }
}

final class ConciergeRequestService: ConciergeRequestServicing {
    static let shared = ConciergeRequestService()

    private let remoteStore: FirestoreRemoteStoring
    private let sessionCoordinator: FirebaseSessionCoordinating
    private let hotelContextResolver: HotelContextResolving
    private let dateProvider: DateProviding
    private var fallbackRequestsByUserID: [String: [ConciergeRequestRecord]] = [:]

    init(
        remoteStore: FirestoreRemoteStoring = FirestoreRemoteStore.shared,
        sessionCoordinator: FirebaseSessionCoordinating = FirebaseSessionCoordinator.shared,
        hotelContextResolver: HotelContextResolving = HotelContextResolver.shared,
        dateProvider: DateProviding = SystemDateProvider()
    ) {
        self.remoteStore = remoteStore
        self.sessionCoordinator = sessionCoordinator
        self.hotelContextResolver = hotelContextResolver
        self.dateProvider = dateProvider
    }

    func fetchCurrentUserConciergeRequests() async throws -> [ConciergeRequestRecord] {
        let session = resolvedSession()

        if shouldUseFallback(for: session) {
            return fallbackRequests(for: session)
        }

        do {
            let records: [ConciergeRequestRecord] = try await remoteStore.fetchCollectionGroup(
                subcollection: .conciergeRequests,
                filters: [.equalTo(field: FirestoreDocumentField.guestUserID, value: session.id)],
                orderBy: FirestoreDocumentField.createdAt,
                descending: true,
                limit: nil
            )

            return records.isEmpty ? fallbackRequests(for: session) : records
        } catch let error as FirestoreRemoteStoreError where error == .unavailable {
            return fallbackRequests(for: session)
        }
    }

    func createConciergeRequest(
        requestType: ConciergeRequestType,
        title: String,
        detail: String,
        requestedFor: Date?,
        partySize: Int?
    ) async throws -> ConciergeRequestRecord {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDetail = detail.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty else {
            throw ConciergeRequestServiceError.emptyTitle
        }

        guard !trimmedDetail.isEmpty else {
            throw ConciergeRequestServiceError.emptyDetail
        }

        let session = resolvedSession()
        let hotelContext = await hotelContextResolver.resolveCurrentHotelContext()
        let now = dateProvider.now

        let request = ConciergeRequestRecord(
            id: UUID().uuidString,
            hotelID: hotelContext.hotelID,
            guestUserID: session.id,
            guest: sessionCoordinator.guestSnapshot(for: session),
            stayID: hotelContext.stay?.id,
            requestType: requestType,
            status: .submitted,
            title: trimmedTitle,
            detail: trimmedDetail,
            requestedFor: requestedFor,
            partySize: partySize,
            contactMethod: "In App",
            responseNotes: nil,
            createdAt: now,
            updatedAt: now
        )

        if shouldUseFallback(for: session) {
            return storeFallback(request, for: session)
        }

        let data = try FirestoreDateCoding.preparedConciergeRequestData(from: request)
        do {
            try await remoteStore.setDocument(
                at: FirestorePath.hotelSubcollectionDocument(
                    hotelID: request.hotelID,
                    subcollection: .conciergeRequests,
                    documentID: request.id
                ),
                data: data,
                merge: false
            )

            return request
        } catch let error as FirestoreRemoteStoreError where error == .unavailable {
            return storeFallback(request, for: session)
        }
    }

    func updateRequestStatus(
        _ request: ConciergeRequestRecord,
        status: ConciergeRequestStatus
    ) async throws -> ConciergeRequestRecord {
        let updatedRequest = ConciergeRequestRecord(
            id: request.id,
            hotelID: request.hotelID,
            guestUserID: request.guestUserID,
            guest: request.guest,
            stayID: request.stayID,
            requestType: request.requestType,
            status: status,
            title: request.title,
            detail: request.detail,
            requestedFor: request.requestedFor,
            partySize: request.partySize,
            contactMethod: request.contactMethod,
            responseNotes: request.responseNotes,
            createdAt: request.createdAt,
            updatedAt: dateProvider.now
        )

        let session = resolvedSession()

        if shouldUseFallback(for: session) {
            return storeFallback(updatedRequest, for: session)
        }

        let data = try FirestoreDateCoding.preparedConciergeRequestData(from: updatedRequest)
        do {
            try await remoteStore.setDocument(
                at: FirestorePath.hotelSubcollectionDocument(
                    hotelID: updatedRequest.hotelID,
                    subcollection: .conciergeRequests,
                    documentID: updatedRequest.id
                ),
                data: data,
                merge: true
            )

            return updatedRequest
        } catch let error as FirestoreRemoteStoreError where error == .unavailable {
            return storeFallback(updatedRequest, for: session)
        }
    }
}

private extension ConciergeRequestService {
    func resolvedSession() -> UserSession {
        sessionCoordinator.resolvedSession()
    }

    func shouldUseFallback(for session: UserSession) -> Bool {
        sessionCoordinator.canUseFallback(for: session) || !remoteStore.isAvailable()
    }

    func fallbackRequests(for session: UserSession) -> [ConciergeRequestRecord] {
        if let existing = fallbackRequestsByUserID[session.id] {
            return existing.sorted { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }
        }

        let seeded = sampleRequests(for: session)
        fallbackRequestsByUserID[session.id] = seeded
        return seeded.sorted { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }
    }

    func storeFallback(_ request: ConciergeRequestRecord, for session: UserSession) -> ConciergeRequestRecord {
        var requests = fallbackRequests(for: session).filter { $0.id != request.id }
        requests.append(request)
        fallbackRequestsByUserID[session.id] = requests
        return request
    }

    func sampleRequests(for session: UserSession) -> [ConciergeRequestRecord] {
        let now = Date()

        return [
            ConciergeRequestRecord(
                id: "concierge-request-sample-001",
                hotelID: "cinnamon-thiya",
                guestUserID: session.id,
                guest: GuestSnapshot(
                    userID: session.id,
                    fullName: session.displayName ?? "Kawish Jayawardena",
                    email: session.email,
                    phoneNumber: nil
                ),
                stayID: "stay-sample-cinnamon-thiya-001",
                requestType: .reservation,
                status: .confirmed,
                title: "Dinner reservation at Park Street Mews",
                detail: "Reserve a quiet outdoor table for two at 8:00 PM.",
                requestedFor: Calendar.current.date(byAdding: .hour, value: 5, to: now),
                partySize: 2,
                contactMethod: "In App",
                responseNotes: "A table has been held under your suite reservation.",
                createdAt: Calendar.current.date(byAdding: .hour, value: -8, to: now),
                updatedAt: Calendar.current.date(byAdding: .hour, value: -2, to: now)
            )
        ]
    }
}
