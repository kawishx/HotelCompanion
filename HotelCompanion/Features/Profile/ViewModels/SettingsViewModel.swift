//
//  SettingsViewModel.swift
//  HotelCompanion
//
//  File: Features/Profile/ViewModels/SettingsViewModel.swift
//

import Combine
import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var isBiometricLoginEnabled = false
    @Published private(set) var biometricKind: BiometricKind = .none
    @Published private(set) var availabilityMessage = ""

    private let biometricAuthManager: BiometricAuthManager

    init(biometricAuthManager: BiometricAuthManager? = nil) {
        self.biometricAuthManager = biometricAuthManager ?? .shared
        refresh()
    }

    func refresh() {
        isBiometricLoginEnabled = biometricAuthManager.isBiometricLoginEnabled

        let availability = biometricAuthManager.checkBiometricAvailability()
        switch availability {
        case .available(let kind):
            biometricKind = kind
            availabilityMessage = "\(kind.displayName) is available on this device."
        case .unavailable(let message):
            biometricKind = biometricAuthManager.biometricType()
            availabilityMessage = message
        }
    }

    func updateBiometricPreference(isEnabled: Bool) {
        let availability = biometricAuthManager.checkBiometricAvailability()

        switch availability {
        case .available:
            biometricAuthManager.isBiometricLoginEnabled = isEnabled
            isBiometricLoginEnabled = isEnabled
        case .unavailable(let message):
            biometricAuthManager.isBiometricLoginEnabled = false
            isBiometricLoginEnabled = false
            availabilityMessage = message
        }
    }
}
