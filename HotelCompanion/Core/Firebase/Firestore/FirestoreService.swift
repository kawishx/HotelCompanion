//
//  FirestoreService.swift
//  HotelCompanion
//
//  File: Core/Firebase/Firestore/FirestoreService.swift
//

import Foundation

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

protocol FirestoreServicing {
    func isConfigured() -> Bool

    #if canImport(FirebaseFirestore)
    var db: Firestore { get }
    #endif
}

final class FirestoreService: FirestoreServicing {
    static let shared = FirestoreService()

    #if canImport(FirebaseFirestore)
    let db: Firestore

    private init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }
    #else
    private init() {
    }
    #endif

    func isConfigured() -> Bool {
        #if canImport(FirebaseFirestore)
        return true
        #else
        return false
        #endif
    }
}
