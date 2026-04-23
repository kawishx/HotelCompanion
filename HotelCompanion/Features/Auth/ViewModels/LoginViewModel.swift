//
//  LoginViewModel.swift
//  HotelCompanion
//
//  File: Features/Auth/ViewModels/LoginViewModel.swift
//

import Combine
import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published private(set) var biometricKind: BiometricKind = .none
    @Published private(set) var isBiometricAvailable = false
    @Published var biometricErrorMessage: String?

    private let biometricAuthManager: BiometricAuthManager

    init(biometricAuthManager: BiometricAuthManager = .shared) {
        self.biometricAuthManager = biometricAuthManager
        refreshBiometricState()
    }

    var canSignIn: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty
    }

    var isBiometricLoginEnabled: Bool {
        biometricAuthManager.isBiometricLoginEnabled
    }

    var shouldShowBiometricButton: Bool {
        isBiometricAvailable && isBiometricLoginEnabled
    }

    var biometricButtonTitle: String {
        "Use \(biometricKind.displayName)"
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

    func authenticateWithBiometrics() async -> Bool {
        biometricErrorMessage = nil
        refreshBiometricState()

        let result = await biometricAuthManager.authenticateUser(
            reason: "Sign in to Cinnamon Companion securely."
        )

        switch result {
        case .success:
            return true
        case .failure(let message):
            biometricErrorMessage = message
            return false
        }
    }
}
