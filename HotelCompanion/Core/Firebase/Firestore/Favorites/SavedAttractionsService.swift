//
//  SavedAttractionsService.swift
//  HotelCompanion
//
//  File: Core/Firebase/Firestore/Favorites/SavedAttractionsService.swift
//

import Foundation

protocol SavedAttractionsServicing {
    func fetchCurrentUserSavedAttractions() async throws -> [SavedAttractionRecord]
    func saveAttraction(_ attraction: SavedAttractionRecord) async throws -> SavedAttractionRecord
    func removeSavedAttraction(_ attraction: SavedAttractionRecord) async throws
}

final class SavedAttractionsService: SavedAttractionsServicing {
    static let shared = SavedAttractionsService()

    private let remoteStore: FirestoreRemoteStoring
    private let sessionCoordinator: FirebaseSessionCoordinating
    private var fallbackSavedAttractionsByUserID: [String: [SavedAttractionRecord]] = [:]

    init(
        remoteStore: FirestoreRemoteStoring = FirestoreRemoteStore.shared,
        sessionCoordinator: FirebaseSessionCoordinating = FirebaseSessionCoordinator.shared
    ) {
        self.remoteStore = remoteStore
        self.sessionCoordinator = sessionCoordinator
    }

    func fetchCurrentUserSavedAttractions() async throws -> [SavedAttractionRecord] {
        let session = resolvedSession()

        if shouldUseFallback(for: session) {
            return fallbackSavedAttractions(for: session)
        }

        do {
            return try await remoteStore.fetchUserSubcollection(
                userID: session.id,
                subcollection: .savedAttractions,
                orderBy: FirestoreDocumentField.savedAt,
                descending: true
            )
        } catch let error as FirestoreRemoteStoreError where error == .unavailable {
            return fallbackSavedAttractions(for: session)
        }
    }

    func saveAttraction(_ attraction: SavedAttractionRecord) async throws -> SavedAttractionRecord {
        let session = resolvedSession()

        if shouldUseFallback(for: session) {
            return storeFallback(attraction, for: session)
        }

        let data = try FirestoreDateCoding.preparedSavedAttractionData(from: attraction)
        do {
            try await remoteStore.setDocument(
                at: FirestorePath.userSubcollectionDocument(
                    userID: session.id,
                    subcollection: .savedAttractions,
                    documentID: attraction.id
                ),
                data: data,
                merge: true
            )

            return attraction
        } catch let error as FirestoreRemoteStoreError where error == .unavailable {
            return storeFallback(attraction, for: session)
        }
    }

    func removeSavedAttraction(_ attraction: SavedAttractionRecord) async throws {
        let session = resolvedSession()

        if shouldUseFallback(for: session) {
            fallbackSavedAttractionsByUserID[session.id] = fallbackSavedAttractions(for: session).filter { $0.id != attraction.id }
            return
        }

        do {
            try await remoteStore.deleteDocument(
                at: FirestorePath.userSubcollectionDocument(
                    userID: session.id,
                    subcollection: .savedAttractions,
                    documentID: attraction.id
                )
            )
        } catch let error as FirestoreRemoteStoreError where error == .unavailable {
            fallbackSavedAttractionsByUserID[session.id] = fallbackSavedAttractions(for: session).filter { $0.id != attraction.id }
        }
    }
}

private extension SavedAttractionsService {
    func resolvedSession() -> UserSession {
        sessionCoordinator.resolvedSession()
    }

    func shouldUseFallback(for session: UserSession) -> Bool {
        sessionCoordinator.canUseFallback(for: session) || !remoteStore.isAvailable()
    }

    func fallbackSavedAttractions(for session: UserSession) -> [SavedAttractionRecord] {
        if let existing = fallbackSavedAttractionsByUserID[session.id] {
            return existing.sorted { $0.savedAt > $1.savedAt }
        }

        fallbackSavedAttractionsByUserID[session.id] = []
        return []
    }

    func storeFallback(_ attraction: SavedAttractionRecord, for session: UserSession) -> SavedAttractionRecord {
        var items = fallbackSavedAttractions(for: session).filter { $0.id != attraction.id }
        items.append(attraction)
        fallbackSavedAttractionsByUserID[session.id] = items
        return attraction
    }
}
