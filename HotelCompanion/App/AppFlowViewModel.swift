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

    func showOnboarding() {
        currentFlow = .onboarding
    }

    func showLogin() {
        currentFlow = .login
    }

    func enterApp() {
        currentFlow = .mainTabs
    }
}

