//
//  AppFlowView.swift
//  HotelCompanion
//
//  File: App/AppFlowView.swift
//

import SwiftUI

struct AppFlowView: View {
    @StateObject private var viewModel = AppFlowViewModel()
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        Group {
            switch viewModel.currentFlow {
            case .splash:
                SplashView {
                    viewModel.completeSplash(hasActiveSession: authViewModel.isAuthenticated)
                }
            case .onboarding:
                OnboardingView {
                    viewModel.showLogin()
                }
            case .login:
                LoginView()
            case .mainTabs:
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.35), value: viewModel.currentFlow)
        .environmentObject(authViewModel)
        .onChange(of: authViewModel.userSession) { _, session in
            viewModel.handleAuthenticationState(session)
        }
    }
}

#Preview {
    AppFlowView()
}
