//
//  FirebaseSessionCoordinator.swift
//  HotelCompanion
//
//  File: Core/Firebase/Shared/FirebaseSessionCoordinator.swift
//

import Foundation

protocol FirebaseSessionCoordinating {
    var currentSession: UserSession? { get }

    func resolvedSession() -> UserSession
    func authenticatedSession() throws -> UserSession
    func canUseFallback(for session: UserSession) -> Bool
    func guestSnapshot(for session: UserSession) -> GuestSnapshot
}

enum FirebaseSessionCoordinatorError: LocalizedError {
    case unauthenticated

    var errorDescription: String? {
        switch self {
        case .unauthenticated:
            return "Sign in to continue with this Firebase-backed action."
        }
    }
}

final class FirebaseSessionCoordinator: FirebaseSessionCoordinating {
    static let shared = FirebaseSessionCoordinator()

    private let authService: AuthServicing
    private let firestoreService: FirestoreServicing

    init(
        authService: AuthServicing = AuthService.shared,
        firestoreService: FirestoreServicing = FirestoreService.shared
    ) {
        self.authService = authService
        self.firestoreService = firestoreService
    }

    var currentSession: UserSession? {
        authService.currentSession
    }

    func resolvedSession() -> UserSession {
        authService.currentSession ?? .guest
    }

    func authenticatedSession() throws -> UserSession {
        guard let session = authService.currentSession, !session.isGuest else {
            throw FirebaseSessionCoordinatorError.unauthenticated
        }

        return session
    }

    func canUseFallback(for session: UserSession) -> Bool {
        session.isGuest || !firestoreService.isConfigured()
    }

    func guestSnapshot(for session: UserSession) -> GuestSnapshot {
        GuestSnapshot(
            userID: session.id,
            fullName: session.displayName ?? "Cinnamon Guest",
            email: session.email,
            phoneNumber: nil
        )
    }
}
