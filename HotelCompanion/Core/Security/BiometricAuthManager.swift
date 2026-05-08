//
//  BiometricAuthManager.swift
//  HotelCompanion
//
//  File: Core/Security/BiometricAuthManager.swift
//

import Foundation
import LocalAuthentication

enum BiometricKind: Equatable {
    case none
    case faceID
    case touchID

    var displayName: String {
        switch self {
        case .none:
            return "Biometrics"
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        }
    }

    var systemImageName: String {
        switch self {
        case .none:
            return "lock.shield"
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        }
    }
}

enum BiometricAvailability: Equatable {
    case available(BiometricKind)
    case unavailable(String)
}

enum BiometricAuthError: LocalizedError, Equatable {
    case message(String)

    var errorDescription: String? {
        switch self {
        case .message(let message):
            return message
        }
    }
}

final class BiometricAuthManager {
    static let shared = BiometricAuthManager()

    private enum Keys {
        static let biometricLoginEnabled = "biometric_login_enabled"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var isBiometricLoginEnabled: Bool {
        get { userDefaults.bool(forKey: Keys.biometricLoginEnabled) }
        set { userDefaults.set(newValue, forKey: Keys.biometricLoginEnabled) }
    }

    func biometricType() -> BiometricKind {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)

        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        case .none:
            return .none
        @unknown default:
            return .none
        }
    }

    func checkBiometricAvailability() -> BiometricAvailability {
        let context = LAContext()
        var error: NSError?

        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        let type = context.biometryType

        if canEvaluate {
            switch type {
            case .faceID:
                return .available(.faceID)
            case .touchID:
                return .available(.touchID)
            case .none:
                return .unavailable("Biometric authentication is not configured on this device.")
            @unknown default:
                return .unavailable("Biometric authentication is unavailable.")
            }
        }

        if let error {
            return .unavailable(userFriendlyMessage(for: error))
        }

        return .unavailable("Biometric authentication is unavailable.")
    }

    func authenticateUser(reason: String) async -> Result<Void, BiometricAuthError> {
        let context = LAContext()
        context.localizedCancelTitle = "Use Password Instead"

        var error: NSError?
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)

        guard canEvaluate else {
            if let error {
                return .failure(.message(userFriendlyMessage(for: error)))
            }

            return .failure(.message("Biometric authentication is unavailable right now."))
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )

            return success ? .success(()) : .failure(.message("Authentication could not be completed."))
        } catch {
            let nsError = error as NSError
            return .failure(.message(userFriendlyMessage(for: nsError)))
        }
    }

    func userFriendlyMessage(for error: NSError) -> String {
        guard error.domain == LAError.errorDomain,
              let code = LAError.Code(rawValue: error.code) else {
            return "Something went wrong while checking biometrics. Please try again."
        }

        switch code {
        case .authenticationFailed:
            return "Your identity could not be verified. Please try again."
        case .userCancel:
            return "Biometric sign in was cancelled."
        case .userFallback:
            return "Please sign in with your password instead."
        case .systemCancel:
            return "Biometric sign in was interrupted by the system."
        case .passcodeNotSet:
            return "Set a device passcode to use biometric sign in."
        case .biometryNotAvailable:
            return "This device does not support Face ID or Touch ID."
        case .biometryNotEnrolled:
            return "Set up Face ID or Touch ID in Settings to use biometric sign in."
        case .biometryLockout:
            return "Biometric authentication is locked. Unlock with your device passcode first."
        case .invalidContext:
            return "Biometric authentication is temporarily unavailable."
        case .notInteractive:
            return "Biometric authentication requires an active device session."
        default:
            return "Biometric authentication could not be completed. Please try again."
        }
    }
}
