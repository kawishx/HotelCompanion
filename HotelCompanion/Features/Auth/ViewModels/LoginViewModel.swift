//
//  LoginViewModel.swift
//  HotelCompanion
//
//  File: Features/Auth/ViewModels/LoginViewModel.swift
//

import Combine
import Foundation

enum LoginMode: String, CaseIterable, Identifiable {
    case signIn
    case signUp

    var id: String { rawValue }

    var title: String {
        switch self {
        case .signIn:
            return "Sign In"
        case .signUp:
            return "Create Account"
        }
    }

    var subtitle: String {
        switch self {
        case .signIn:
            return "Access your stay details, dining requests, and personalized travel moments."
        case .signUp:
            return "Create your Cinnamon Companion account for a more personalized stay experience."
        }
    }

    var primaryActionTitle: String {
        switch self {
        case .signIn:
            return "Sign In"
        case .signUp:
            return "Create Account"
        }
    }

    var primaryActionSystemImage: String {
        switch self {
        case .signIn:
            return "arrow.right.circle.fill"
        case .signUp:
            return "person.crop.circle.badge.plus"
        }
    }

    var switchPrompt: String {
        switch self {
        case .signIn:
            return "Need an account?"
        case .signUp:
            return "Already have an account?"
        }
    }

    var switchActionTitle: String {
        switch self {
        case .signIn:
            return "Create one"
        case .signUp:
            return "Sign in"
        }
    }
}

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var mode: LoginMode = .signIn
    @Published private(set) var biometricKind: BiometricKind = .none
    @Published private(set) var isBiometricAvailable = false
    @Published var biometricErrorMessage: String?

    private let biometricAuthManager: BiometricAuthManager

    init(biometricAuthManager: BiometricAuthManager? = nil) {
        let resolvedBiometricAuthManager = biometricAuthManager ?? .shared

        self.biometricAuthManager = resolvedBiometricAuthManager
        refreshBiometricState()
    }

    var canSignIn: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty
    }

    var isBiometricLoginEnabled: Bool {
        biometricAuthManager.isBiometricLoginEnabled
    }

    var biometricButtonTitle: String {
        "Use \(biometricKind.displayName)"
    }

    var shouldShowBiometricButton: Bool {
        isBiometricAvailable && isBiometricLoginEnabled && mode == .signIn
    }

    var primaryActionTitle: String {
        mode.primaryActionTitle
    }

    var primaryActionSystemImage: String {
        mode.primaryActionSystemImage
    }

    var heroTitle: String {
        mode.title
    }

    var heroSubtitle: String {
        mode.subtitle
    }

    func refreshBiometricState() {
        let availability = biometricAuthManager.checkBiometricAvailability()

        switch availability {
        case .available(let kind):
            biometricKind = kind
            isBiometricAvailable = true
        case .unavailable:
            biometricKind = biometricAuthManager.biometricType()
            isBiometricAvailable = false
        }
    }

    func toggleMode() {
        mode = mode == .signIn ? .signUp : .signIn
        biometricErrorMessage = nil
    }

    func authenticateWithBiometrics(using authViewModel: AuthViewModel) async -> Bool {
        biometricErrorMessage = nil
        refreshBiometricState()

        let result = await biometricAuthManager.authenticateUser(
            reason: "Sign in to Cinnamon Companion securely."
        )

        switch result {
        case .success:
            if authViewModel.isAuthenticated {
                return true
            }

            guard canSignIn else {
                biometricErrorMessage = "Use biometrics after a previous sign-in, or enter your email and password to continue."
                return false
            }

            return await authViewModel.signIn(email: email, password: password)
        case .failure(let error):
            biometricErrorMessage = error.localizedDescription
            return false
        }
    }
}
