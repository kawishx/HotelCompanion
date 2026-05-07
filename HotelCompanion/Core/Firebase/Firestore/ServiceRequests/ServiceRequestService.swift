//
//  ServiceRequestService.swift
//  HotelCompanion
//
//  File: Core/Firebase/Firestore/ServiceRequests/ServiceRequestService.swift
//

import Foundation

protocol ServiceRequestServicing {
    func fetchCurrentUserServiceRequests() async throws -> [ServiceRequestRecord]
    func createServiceRequest(
        requestType: ServiceRequestCategory,
        note: String,
        roomNumber: String?,
        uploadedImageURL: URL?,
        priority: ServiceRequestPriority
    ) async throws -> ServiceRequestRecord
    func updateRequestStatus(
        _ request: ServiceRequestRecord,
        status: ServiceRequestStatus
    ) async throws -> ServiceRequestRecord
}

enum ServiceRequestServiceError: LocalizedError {
    case emptyNote

    var errorDescription: String? {
        switch self {
        case .emptyNote:
            return "Add a short note describing the service issue before submitting."
        }
    }
}

final class ServiceRequestService: ServiceRequestServicing {
    static let shared = ServiceRequestService()

    private let remoteStore: FirestoreRemoteStoring
    private let sessionCoordinator: FirebaseSessionCoordinating
    private let hotelContextResolver: HotelContextResolving
    private let dateProvider: DateProviding
    private var fallbackRequestsByUserID: [String: [ServiceRequestRecord]] = [:]

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

    func fetchCurrentUserServiceRequests() async throws -> [ServiceRequestRecord] {
        let session = resolvedSession()

        if shouldUseFallback(for: session) {
            return fallbackRequests(for: session)
        }

        do {
            return try await remoteStore.fetchCollectionGroup(
                subcollection: .serviceRequests,
                filters: [.equalTo(field: FirestoreDocumentField.guestUserID, value: session.id)],
                orderBy: FirestoreDocumentField.createdAt,
                descending: true,
                limit: nil
            )
        } catch let error as FirestoreRemoteStoreError where error == .unavailable {
            return fallbackRequests(for: session)
        }
    }

    func createServiceRequest(
        requestType: ServiceRequestCategory,
        note: String,
        roomNumber: String?,
        uploadedImageURL: URL?,
        priority: ServiceRequestPriority
    ) async throws -> ServiceRequestRecord {
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedNote.isEmpty else {
            throw ServiceRequestServiceError.emptyNote
        }

        let session = resolvedSession()
        let hotelContext = await hotelContextResolver.resolveCurrentHotelContext()
        let now = dateProvider.now

        let request = ServiceRequestRecord(
            id: UUID().uuidString,
            hotelID: hotelContext.hotelID,
            guestUserID: session.id,
            guest: sessionCoordinator.guestSnapshot(for: session),
            stayID: hotelContext.stay?.id,
            roomNumber: normalizedRoomNumber(roomNumber),
            requestType: requestType,
            note: trimmedNote,
            uploadedImageURL: uploadedImageURL,
            priority: priority,
            status: .open,
            assignedTeamName: nil,
            createdAt: now,
            updatedAt: now,
            resolvedAt: nil
        )

        if shouldUseFallback(for: session) {
            return storeFallback(request, for: session)
        }

        let data = try FirestoreDateCoding.preparedServiceRequestData(from: request)
        do {
            try await remoteStore.setDocument(
                at: FirestorePath.hotelSubcollectionDocument(
                    hotelID: request.hotelID,
                    subcollection: .serviceRequests,
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
        _ request: ServiceRequestRecord,
        status: ServiceRequestStatus
    ) async throws -> ServiceRequestRecord {
        let updatedRequest = ServiceRequestRecord(
            id: request.id,
            hotelID: request.hotelID,
            guestUserID: request.guestUserID,
            guest: request.guest,
            stayID: request.stayID,
            roomNumber: request.roomNumber,
            requestType: request.requestType,
            note: request.note,
            uploadedImageURL: request.uploadedImageURL,
            priority: request.priority,
            status: status,
            assignedTeamName: request.assignedTeamName,
            createdAt: request.createdAt,
            updatedAt: dateProvider.now,
            resolvedAt: status == .resolved ? dateProvider.now : request.resolvedAt
        )

        let session = resolvedSession()

        if shouldUseFallback(for: session) {
            return storeFallback(updatedRequest, for: session)
        }

        let data = try FirestoreDateCoding.preparedServiceRequestData(from: updatedRequest)
        do {
            try await remoteStore.setDocument(
                at: FirestorePath.hotelSubcollectionDocument(
                    hotelID: updatedRequest.hotelID,
                    subcollection: .serviceRequests,
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

private extension ServiceRequestService {
    func resolvedSession() -> UserSession {
        sessionCoordinator.resolvedSession()
    }

    func shouldUseFallback(for session: UserSession) -> Bool {
        sessionCoordinator.canUseFallback(for: session) || !remoteStore.isAvailable()
    }

    func fallbackRequests(for session: UserSession) -> [ServiceRequestRecord] {
        if let existing = fallbackRequestsByUserID[session.id] {
            return existing.sorted {
                ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast)
            }
        }

        let seeded = sampleRequests(for: session)
        fallbackRequestsByUserID[session.id] = seeded
        return seeded.sorted {
            ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast)
        }
    }

    func storeFallback(_ request: ServiceRequestRecord, for session: UserSession) -> ServiceRequestRecord {
        var requests = fallbackRequests(for: session).filter { $0.id != request.id }
        requests.append(request)
        fallbackRequestsByUserID[session.id] = requests
        return request
    }

    func sampleRequests(for session: UserSession) -> [ServiceRequestRecord] {
        let now = Date()

        return [
            ServiceRequestRecord(
                id: "service-request-sample-001",
                hotelID: "cinnamon-thiya",
                guestUserID: session.id,
                guest: GuestSnapshot(
                    userID: session.id,
                    fullName: session.displayName ?? "Kawish Jayawardena",
                    email: session.email,
                    phoneNumber: nil
                ),
                stayID: "stay-sample-cinnamon-thiya-001",
                roomNumber: "508",
                requestType: .maintenance,
                note: "Air conditioning is not cooling properly in the bedroom.",
                uploadedImageURL: nil,
                priority: .high,
                status: .acknowledged,
                assignedTeamName: "Engineering",
                createdAt: Calendar.current.date(byAdding: .hour, value: -5, to: now),
                updatedAt: Calendar.current.date(byAdding: .hour, value: -3, to: now),
                resolvedAt: nil
            ),
            ServiceRequestRecord(
                id: "service-request-sample-002",
                hotelID: "cinnamon-thiya",
                guestUserID: session.id,
                guest: GuestSnapshot(
                    userID: session.id,
                    fullName: session.displayName ?? "Kawish Jayawardena",
                    email: session.email,
                    phoneNumber: nil
                ),
                stayID: "stay-sample-cinnamon-thiya-001",
                roomNumber: "508",
                requestType: .amenities,
                note: "Please send two additional bath towels.",
                uploadedImageURL: nil,
                priority: .normal,
                status: .resolved,
                assignedTeamName: "Housekeeping",
                createdAt: Calendar.current.date(byAdding: .day, value: -1, to: now),
                updatedAt: Calendar.current.date(byAdding: .hour, value: -18, to: now),
                resolvedAt: Calendar.current.date(byAdding: .hour, value: -18, to: now)
            )
        ]
    }

    func normalizedRoomNumber(_ roomNumber: String?) -> String? {
        let trimmed = roomNumber?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == true ? nil : trimmed
    }
}
