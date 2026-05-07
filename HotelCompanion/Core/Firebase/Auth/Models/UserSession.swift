//
//  UserSession.swift
//  HotelCompanion
//
//  File: Core/Firebase/Auth/Models/UserSession.swift
//

import Foundation

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

struct UserSession: Equatable, Identifiable {
    let id: String
    let email: String?
    let displayName: String?
    let isGuest: Bool

    var greetingName: String {
        if let displayName, !displayName.isEmpty {
            return displayName
        }

        if let email, !email.isEmpty {
            return email
        }

        return isGuest ? "Guest" : "Cinnamon Guest"
    }

    static let guest = UserSession(
        id: "guest-session",
        email: nil,
        displayName: "Guest",
        isGuest: true
    )
}

#if canImport(FirebaseAuth)
extension UserSession {
    init(firebaseUser: User) {
        self.init(
            id: firebaseUser.uid,
            email: firebaseUser.email,
            displayName: firebaseUser.displayName,
            isGuest: false
        )
    }
}
#endif
