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

final class FirebaseManager {
    static let shared = FirebaseManager()

    private(set) var hasConfiguredFirebase = false

    private init() {
    }

    func configure() {
        guard !hasConfiguredFirebase else { return }

        #if canImport(FirebaseCore)
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        hasConfiguredFirebase = true
        #else
        assertionFailure(
            "Firebase SDKs are not available yet. Add FirebaseCore, FirebaseAuth, FirebaseFirestore, and FirebaseStorage through Swift Package Manager."
        )
        #endif
    }
}

