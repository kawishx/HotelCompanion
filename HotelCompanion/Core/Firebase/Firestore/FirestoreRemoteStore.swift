//
//  FirestoreRemoteStore.swift
//  HotelCompanion
//
//  File: Core/Firebase/Firestore/FirestoreRemoteStore.swift
//

import Foundation

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

enum FirestoreQueryFilter {
    case equalTo(field: String, value: Any)
    case inValues(field: String, values: [Any])
}

enum FirestoreRemoteStoreError: LocalizedError, Equatable {
    case unavailable

    var errorDescription: String? {
        switch self {
        case .unavailable:
            return "Cloud Firestore is not configured yet."
        }
    }
}

@MainActor
protocol FirestoreRemoteStoring {
    func isAvailable() -> Bool
    func fetchDocument<T: Decodable>(at path: String, as type: T.Type) async throws -> T?
    func fetchCollectionGroup<T: Decodable>(
        subcollection: FirestoreHotelSubcollection,
        filters: [FirestoreQueryFilter],
        orderBy: String?,
        descending: Bool,
        limit: Int?
    ) async throws -> [T]
    func fetchUserSubcollection<T: Decodable>(
        userID: String,
        subcollection: FirestoreUserSubcollection,
        orderBy: String,
        descending: Bool
    ) async throws -> [T]
    func setDocument(at path: String, data: [String: Any], merge: Bool) async throws
    func deleteDocument(at path: String) async throws
}

@MainActor
final class FirestoreRemoteStore: FirestoreRemoteStoring {
    static let shared = FirestoreRemoteStore()

    private let firestoreService: FirestoreServicing

    init(firestoreService: FirestoreServicing = FirestoreService.shared) {
        self.firestoreService = firestoreService
    }

    func isAvailable() -> Bool {
        firestoreService.isConfigured()
    }

    func fetchDocument<T: Decodable>(at path: String, as type: T.Type) async throws -> T? {
        #if canImport(FirebaseFirestore)
        guard firestoreService.isConfigured() else {
            throw FirestoreRemoteStoreError.unavailable
        }

        let snapshot = try await firestoreService.db.document(path).getDocument()

        guard let data = snapshot.data() else {
            return nil
        }

        return try FirestoreDocumentMapper.decode(
            type,
            from: data,
            documentID: snapshot.documentID
        )
        #else
        throw FirestoreRemoteStoreError.unavailable
        #endif
    }

    func fetchCollectionGroup<T: Decodable>(
        subcollection: FirestoreHotelSubcollection,
        filters: [FirestoreQueryFilter],
        orderBy: String? = nil,
        descending: Bool = false,
        limit: Int? = nil
    ) async throws -> [T] {
        #if canImport(FirebaseFirestore)
        guard firestoreService.isConfigured() else {
            throw FirestoreRemoteStoreError.unavailable
        }

        var query: Query = firestoreService.db.collectionGroup(subcollection.rawValue)

        for filter in filters {
            switch filter {
            case .equalTo(let field, let value):
                query = query.whereField(field, isEqualTo: value)
            case .inValues(let field, let values):
                query = query.whereField(field, in: values)
            }
        }

        if let orderBy {
            query = query.order(by: orderBy, descending: descending)
        }

        if let limit {
            query = query.limit(to: limit)
        }

        let snapshot = try await query.getDocuments()
        return try snapshot.documents.map { document in
            try FirestoreDocumentMapper.decode(
                T.self,
                from: document.data(),
                documentID: document.documentID
            )
        }
        #else
        throw FirestoreRemoteStoreError.unavailable
        #endif
    }

    func fetchUserSubcollection<T: Decodable>(
        userID: String,
        subcollection: FirestoreUserSubcollection,
        orderBy: String,
        descending: Bool
    ) async throws -> [T] {
        #if canImport(FirebaseFirestore)
        guard firestoreService.isConfigured() else {
            throw FirestoreRemoteStoreError.unavailable
        }

        let snapshot = try await firestoreService.db
            .collection(FirestorePath.userSubcollection(
                userID: userID,
                subcollection: subcollection
            ))
            .order(by: orderBy, descending: descending)
            .getDocuments()

        return try snapshot.documents.map { document in
            try FirestoreDocumentMapper.decode(
                T.self,
                from: document.data(),
                documentID: document.documentID
            )
        }
        #else
        throw FirestoreRemoteStoreError.unavailable
        #endif
    }

    func setDocument(at path: String, data: [String: Any], merge: Bool = false) async throws {
        #if canImport(FirebaseFirestore)
        guard firestoreService.isConfigured() else {
            throw FirestoreRemoteStoreError.unavailable
        }

        try await firestoreService.db.document(path).setData(data, merge: merge)
        #else
        throw FirestoreRemoteStoreError.unavailable
        #endif
    }

    func deleteDocument(at path: String) async throws {
        #if canImport(FirebaseFirestore)
        guard firestoreService.isConfigured() else {
            throw FirestoreRemoteStoreError.unavailable
        }

        try await firestoreService.db.document(path).delete()
        #else
        throw FirestoreRemoteStoreError.unavailable
        #endif
    }
}
