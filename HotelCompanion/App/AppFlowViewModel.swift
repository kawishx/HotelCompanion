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

    func completeSplash(hasActiveSession: Bool) {
        currentFlow = hasActiveSession ? .mainTabs : .onboarding
    }

    func showLogin() {
        currentFlow = .login
    }

    func handleAuthenticationState(_ session: UserSession?) {
        if session != nil {
            currentFlow = .mainTabs
        } else if currentFlow == .mainTabs {
            currentFlow = .login
        }
    }
}
