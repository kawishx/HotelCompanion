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
    private let biometricAuthManager = BiometricAuthManager.shared

    var body: some View {
        Group {
            switch viewModel.currentFlow {
            case .splash:
                SplashView {
                    viewModel.completeSplash(
                        session: authViewModel.userSession,
                        shouldRequireBiometricUnlock: biometricAuthManager.shouldRequireBiometricUnlock(for: authViewModel.userSession)
                    )
                }
            case .onboarding:
                OnboardingView {
                    viewModel.showLogin()
                }
            case .login:
                LoginView()
            case .biometricUnlock:
                BiometricUnlockView(
                    sessionTitle: authViewModel.sessionSubtitle,
                    biometricKind: biometricAuthManager.biometricType()
                ) {
                    viewModel.completeBiometricUnlock()
                } onUseAnotherAccount: {
                    _ = authViewModel.signOut()
                    viewModel.signOutToLogin()
                }
            case .mainTabs:
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.35), value: viewModel.currentFlow)
        .environmentObject(authViewModel)
        .onChange(of: authViewModel.userSession) { _, session in
            viewModel.handleAuthenticationState(
                session,
                shouldRequireBiometricUnlock: biometricAuthManager.shouldRequireBiometricUnlock(for: session)
            )
        }
    }
}

#Preview {
    AppFlowView()
}
