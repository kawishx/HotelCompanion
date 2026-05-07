//
//  UserProfileService.swift
//  HotelCompanion
//
//  File: Core/Firebase/Firestore/Profile/UserProfileService.swift
//

import Foundation

protocol UserProfileServicing {
    func fetchCurrentUserProfile() async throws -> UserProfileRecord?
}

enum UserProfileServiceError: LocalizedError {
    case unauthenticated

    var errorDescription: String? {
        switch self {
        case .unauthenticated:
            return "Sign in with a guest account to load your profile."
        }
    }
}

final class UserProfileService: UserProfileServicing {
    static let shared = UserProfileService()

    private let remoteStore: FirestoreRemoteStoring
    private let sessionCoordinator: FirebaseSessionCoordinating

    init(
        remoteStore: FirestoreRemoteStoring = FirestoreRemoteStore.shared,
        sessionCoordinator: FirebaseSessionCoordinating = FirebaseSessionCoordinator.shared
    ) {
        self.remoteStore = remoteStore
        self.sessionCoordinator = sessionCoordinator
    }

    func fetchCurrentUserProfile() async throws -> UserProfileRecord? {
        guard let session = sessionCoordinator.currentSession, !session.isGuest else {
            return nil
        }

        guard remoteStore.isAvailable() else {
            return sampleProfile(for: session.id, email: session.email)
        }

        if let profile = try await remoteStore.fetchDocument(
            at: FirestorePath.user(session.id),
            as: UserProfileRecord.self
        ) {
            return profile
        }

        return sampleProfile(for: session.id, email: session.email)
    }
}

private extension UserProfileService {
    func sampleProfile(for userID: String, email: String?) -> UserProfileRecord {
        UserProfileRecord(
            id: userID,
            primaryHotelID: "cinnamon-thiya",
            fullName: "Kawish Jayawardena",
            email: email ?? "guest@cinnamoncompanion.app",
            phoneNumber: "+94 77 123 4567",
            loyaltyTier: "Gold Member",
            preferredLocaleIdentifier: Locale.current.identifier,
            preferredCurrencyCode: "LKR",
            profileImagePath: nil,
            notificationPreferences: NotificationPreferences(
                bookingUpdatesEnabled: true,
                diningUpdatesEnabled: true,
                conciergeUpdatesEnabled: true,
                promotionalMessagesEnabled: false
            ),
            accessibilityPreferences: AccessibilityPreferences(
                largeTextPreferred: false,
                reducedMotionPreferred: false,
                voiceAssistancePreferred: false
            ),
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
