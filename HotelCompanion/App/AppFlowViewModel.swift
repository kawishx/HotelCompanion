//
//  AppFlowViewModel.swift
//  HotelCompanion
//
//  File: App/AppFlowViewModel.swift
//

import Combine
import Foundation

final class AppFlowViewModel: ObservableObject {
    @Published var currentFlow: AppFlow = .splash

    func completeSplash(session: UserSession?, shouldRequireBiometricUnlock: Bool) {
        guard session != nil else {
            currentFlow = .onboarding
            return
        }

        currentFlow = shouldRequireBiometricUnlock ? .biometricUnlock : .mainTabs
    }

    func showLogin() {
        currentFlow = .login
    }

    func completeBiometricUnlock() {
        currentFlow = .mainTabs
    }

    func handleAuthenticationState(_ session: UserSession?, shouldRequireBiometricUnlock: Bool) {
        guard session != nil else {
            if currentFlow == .mainTabs || currentFlow == .biometricUnlock {
                currentFlow = .login
            }
            return
        }

        switch currentFlow {
        case .splash:
            currentFlow = shouldRequireBiometricUnlock ? .biometricUnlock : .mainTabs
        case .login, .onboarding:
            currentFlow = .mainTabs
        case .biometricUnlock, .mainTabs:
            break
        }
    }

    func signOutToLogin() {
        if currentFlow != .login {
            currentFlow = .login
        }
    }
}
