//
//  FirebaseManager.swift
//  HotelCompanion
//
//  File: Core/Firebase/AppConfiguration/FirebaseManager.swift
//

import Foundation

#if canImport(FirebaseCore)
import FirebaseCore
#endif

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

#if canImport(FirebaseStorage)
import FirebaseStorage
#endif

final class FirebaseManager {
    static let shared = FirebaseManager()

    private(set) var hasConfiguredFirebase = false

    private init() {}

    func configure() {
        guard !hasConfiguredFirebase else { return }

        #if canImport(FirebaseCore)
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        hasConfiguredFirebase = true
        print("✅ Firebase configured successfully")
        #else
        print("⚠️ Firebase SDK products are not linked yet. Add Firebase package products to the app target in Xcode.")
        #endif
    }
}
