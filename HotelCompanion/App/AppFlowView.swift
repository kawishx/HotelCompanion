//
//  AppFlowView.swift
//  HotelCompanion
//
//  File: App/AppFlowView.swift
//

import SwiftUI

struct AppFlowView: View {
    @StateObject private var viewModel = AppFlowViewModel()

    var body: some View {
        Group {
            switch viewModel.currentFlow {
            case .splash:
                SplashView {
                    viewModel.showOnboarding()
                }
            case .onboarding:
                OnboardingView {
                    viewModel.showLogin()
                }
            case .login:
                LoginView(
                    onGuestContinue: viewModel.enterApp,
                    onSignIn: viewModel.enterApp
                )
            case .mainTabs:
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.35), value: viewModel.currentFlow)
    }
}

#Preview {
    AppFlowView()
}

